%% Example sample application
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
id=12;%str2num(id);
filename0=dir(strcat('co-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
njobs=1;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
istart=1;%(id-1)*section+1;
istop=section;
%% output folder
iFile=19;
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

window_size=[3 5 7];

%% MM-despeckle     

co_windowed_log=zeros(length(window_size),1000,1000);
cross_windowed_log=zeros(length(window_size),1000,1000);
co_speckle_window_log=zeros(length(window_size),4);
cross_speckle_window_log=zeros(length(window_size),4);
t=0;
for window=window_size
    t=t+1;
    I=convn(co,ones(window,window)./window^2,'same');
    
    co_windowed_log(t,:,:)=sqrt(I);
    a=sqrt(I(1:500,1:500));
    co_speckle_window_log(t,1)=std(a(:))/mean(a(:));
    a=sqrt(I(501:1000,1:500));
    co_speckle_window_log(t,2)=std(a(:))/mean(a(:));
    a=sqrt(I(1:500,501:1000));
    co_speckle_window_log(t,3)=std(a(:))/mean(a(:));
    a=sqrt(I(501:1000,501:1000));
    co_speckle_window_log(t,4)=std(a(:))/mean(a(:));
    
    I=convn(cross,ones(window,window)./window^2,'same');
    
    cross_windowed_log(t,:,:)=sqrt(I);
    a=sqrt(I(1:500,1:500));
    cross_speckle_window_log(t,1)=std(a(:))/mean(a(:));
    a=sqrt(I(501:1000,1:500));
    cross_speckle_window_log(t,2)=std(a(:))/mean(a(:));
    a=sqrt(I(1:500,501:1000));
    cross_speckle_window_log(t,3)=std(a(:))/mean(a(:));
    a=sqrt(I(501:1000,501:1000));
    cross_speckle_window_log(t,4)=std(a(:))/mean(a(:));

end
        
save(strcat(folder,'despeckle/','19co windowed log','.mat'),'co_windowed_log');
save(strcat(folder,'despeckle/','19co speckle windowed log','.mat'),'co_speckle_window_log');
save(strcat(folder,'despeckle/','19cross windowed log','.mat'),'cross_windowed_log');
save(strcat(folder,'despeckle/','19cross speckle windowed log','.mat'),'cross_speckle_window_log');
