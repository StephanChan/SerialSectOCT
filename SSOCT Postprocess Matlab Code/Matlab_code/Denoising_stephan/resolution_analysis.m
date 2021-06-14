%% Example sample application

%% Note?run this only after resolution?analysis?window.m
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');

folder = '/projectnb2/npbssmic/ns/210104_2x2x2cm_BA44_45/dist_corrected/'; 
datapath=folder;
mkdir(strcat(folder,'despeckle'));
cd(folder);
id=14;%str2num(id);
filename0=dir(strcat('co-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
njobs=1;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
istart=1;%(id-1)*section+1;
istop=section;
%% output folder
iFile=26;
% Generate filename, volume dimension before loading file
% PSOCT Filename format:slice-tile-Z-X-Y-type.dat. Type can be A, B, AB, ref, ret
name=strsplit(filename0(iFile).name,'.');  
name_dat=strsplit(name{1},'-');
slice_index=id;
coord=num2str(iFile);
% Xrpt and Yrpt are x and y scan repetition, default = 1
Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
name1=strcat('co-',num2str(id),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
name2=strcat('cross-',num2str(id),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat');
% load data
ifilePath = [datapath,name1];
co = ReadDat_int16(ifilePath, dim1);
ifilePath = [datapath,name2];
cross = ReadDat_int16(ifilePath, dim1);

message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
fprintf(message);

aip=squeeze(mean(co,1));
mask=zeros(size(aip));
mask(aip>1400)=1;
% convert to intensity
co=squeeze(double(co(40,:,:).^2));
cross=squeeze(double(cross(40,:,:).^2));
%% Optimization or MM-despeckle parameters
% lambda  - regularization parameter (fixed), dont need a loop, can
% remove theoop, optional user input if someone wants to change
co_low_bound=201;
co_up_bound=4001;
cross_low_bound=1;
cross_up_bound=4001;
window_size=[3 5 7];
lam_step=20;
step_size = 0.00001;%[0.000001:0.000001:0.0001];
%% MM-despeckle
lam_co_log=zeros(length(window_size),4);
lam_cross_log=zeros(length(window_size),4);
co_denoised_log=zeros(length(window_size),500,500);
cross_denoised_log=zeros(length(window_size),500,500);
co_speckle_log=zeros(length(window_size),4);
cross_speckle_log=zeros(length(window_size),4);
for x=1:500:1000
    d=mod(x,499);
    x2=min(x+499,size(co,2));
    for y=1:500:1000
        d=d+floor(y/250);
        y2=min(y+499,size(co,2));

        lam_co=co_low_bound;
        lam_cross=cross_low_bound;
        
        
        
        area_co=co(x:x2,y:y2);
        area_cross=cross(x:x2,y:y2);
        area=mask(x:x2,y:y2);
        t=0;
        speckle_prim=0.43;
        for window=window_size
            t=t+1;
%             speckle=co_speckle_window_log(t,d);
            speckle=cross_speckle_window_log(t,d);
            if sum(area(:))>3000
                stp1=1;
                dif1=0.004;
                while speckle_prim>speckle && lam_co<co_up_bound && lam_cross<cross_up_bound
                    dif=speckle_prim-speckle;
                    
                    stp=dif/(dif1-dif)*stp1
                    stp1=max(stp,0.2);
                    
%                      lam_co=lam_co+lam_step*max(stp,0.2);
                     lam_cross=lam_cross+lam_step*max(stp,0.2);
                     dif1=dif;
                        %tic
%                         slice=area_co;
%                         p=gamfit(double(slice(area==1)));
%                         I= denoise_Tikhonov_ggd_mm(slice', lam_co,step_size,slice',p(1),1/p(2),1,'off')';%*Imean;
%                         speckle_prim=std(sqrt(I(:)))/mean(sqrt(I(:)))
                        %toc

%                         tic
                        slice=area_cross;
                        p=gamfit(double(slice(area==1)));
                        I= denoise_Tikhonov_ggd_mm(slice', lam_cross,step_size,slice',p(1),1/p(2),1,'off')';%*Imean;
                        speckle_prim=std(sqrt(I(:)))/mean(sqrt(I(:)))
%                         toc
                end
%                 lam_co_log(t,d)=lam_co;
                lam_cross_log(t,d)=lam_cross;
%                 co_denoised_log(t,:,:)=I;
                cross_denoised_log(t,:,:)=I;
%                 co_speckle_log(t,d)=speckle_prim;
                cross_speckle_log(t,d)=speckle_prim;
            end

        end
%         save(strcat(folder,'despeckle/','19co lam log',num2str(x),num2str(y),'.mat'),'lam_co_log');
%         save(strcat(folder,'despeckle/','19co denoised log',num2str(x),num2str(y),'.mat'),'co_denoised_log');
%         save(strcat(folder,'despeckle/','19co speckle log',num2str(x),num2str(y),'.mat'),'co_speckle_log');
        save(strcat(folder,'despeckle/','19cross lam log',num2str(x),num2str(y),'.mat'),'lam_cross_log');
        save(strcat(folder,'despeckle/','19cross denoised log',num2str(x),num2str(y),'.mat'),'cross_denoised_log');
        save(strcat(folder,'despeckle/','19cross speckle log',num2str(x),num2str(y),'.mat'),'cross_speckle_log');
    end
end