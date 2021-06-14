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
id=11;%str2num(id);
filename0=dir(strcat('co-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
njobs=1;
section=ceil(ntile/njobs);
% the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
istart=1;%(id-1)*section+1;
istop=section;
%% output folder
for islice=id
    for iFile=[26 52]%istart:istop
        % Generate filename, volume dimension before loading file
        % PSOCT Filename format:slice-tile-Z-X-Y-type.dat. Type can be A, B, AB, ref, ret
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        name1=strcat('co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        name2=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat');
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
        co=double(co.^2);
        cross=double(cross.^2);
        %% Optimization or MM-despeckle parameters
        % lambda  - regularization parameter (fixed), dont need a loop, can
        % remove theoop, optional user input if someone wants to change
        lam_co = [1:100:1000]; 
        lam_cross=[1:100:1000];
        step_size = 0.00001;%[0.000001:0.000001:0.0001];
        %% MM-despeckle
        resultco=zeros(size(co));
        resultcross=zeros(size(cross));
        for x=1:500:size(co,1)
            x2=min(x+499,size(co,2));
            for y=1:500:size(co,3)
                speckle_ct=zeros(2,length(lam_co));
                y2=min(y+499,size(co,2));
                area_co=co(:,x:x2,y:y2);
                area_cross=cross(:,x:x2,y:y2);
                area=mask(x:x2,y:y2);
                if sum(area(:))>3000
                    t=0;
                    for z=50%20:10:100
                        t=t+1;
                        for lam=1:length(lam_co)
                   
                            tic
                            slice=squeeze(area_co(z,:,:));
                            p=gamfit(double(slice(area==1)));
                            I= denoise_Tikhonov_ggd_mm(slice', lam_co(lam),step_size,slice',p(1),1/p(2),1,'off')';%*Imean;
    %                         resultco(x:x2,y:y2,z)=I;
                            speckle_ct(t,lam)=std(sqrt(I(:)))/mean(sqrt(I(:)));
                            toc

                            tic
                            slice=squeeze(area_cross(z,:,:));
                            p=gamfit(double(slice(area==1)));
                            I= denoise_Tikhonov_ggd_mm(slice', lam_cross(lam),step_size,slice',p(1),1/p(2),1,'off')';%*Imean;
%                             resultcross(x:x2,y:y2,z)=I;
                            speckle_ct(t+1,lam)=std(sqrt(I(:)))/mean(sqrt(I(:)));
                            toc
                        end
                    end
                end
                for i=1:9
                    figure(x+y*10);plot(lam_co,speckle_ct(i,:),'LineWidth',2);hold on;
                    figure(x+y*10+1);plot(lam_cross,speckle_ct(i+9,:),'LineWidth',2);hold on;
                end
            end
        end
%         name1=strcat('crocc-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-denoised.mat'); % gen file name for reflectivity
%         name2=strcat('co',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-denoised.mat');
%         
%         save(name2,'resultco');
%         save(name1,'resultcross');
    end
end

%% Save I_den
% save(strcat(op, 'I_den_cross.mat'), 'I_den'); 


% for t=1:60%size(vol,3)
%     mip=single(squeeze(squeeze(co(:,:,t))));
%     tiffname=strcat(op,'despeckle/co pol pre-denoised.tif');
%     t = Tiff(tiffname,'a');
%     tagstruct.ImageLength     = size(mip,1);
%     tagstruct.ImageWidth      = size(mip,2);
%     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 32;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.Compression     = Tiff.Compression.None;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(mip);
%     t.close();
% end