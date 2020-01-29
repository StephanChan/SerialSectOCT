clear all;

%% ----------------------------------------- %%
% Note Jan 23:

% Current version of code does resampling, background extraction, 
% dispersion compensation, FFT and data stripping, MIP/AIP generation.

% Write to TIF images, stitching and blending was done in a seperate script.

% Will implement the surface finding function for data stripping soon.
% Current algorithm needs some further testing.

% Will also integrate write to TIF images, stitching and blending in the
% same script soon.

% - Jiarui Yang
%%%%%%%%%%%%%%%%%%%%%%%

%% set file path
datapath  = strcat('/projectnb/npbssmic/ns/Jiarui/0426volume/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/ns/Jiarui/code/Matlab_batch');

% get the directory of all image tiles
cd(datapath);
slice_range=[28 30:31];%:11;
tile_index=[145:151 168:174 191:197];
for j=1:length(slice_range)
for i=1:length(tile_index)
    filename0=dir(strcat('RAW-',num2str(slice_range(j)),'-',num2str(tile_index(i)),'*.dat'));
    %% add MATLAB functions' path
    %addpath('D:\PROJ - OCT\CODE-BU\Functions') % Path on JTOPTICS
    % addpath('/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/Functions') % Path on SCC server
    
    %% get data information
    %[dim, fNameBase,fIndex]=GetNameInfoRaw(filename0(iFile).name);
    nk = 2048; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
    dim=[nk nxRpt nx nyRpt ny];
    nz0 = nk/2;
    Nx=nxRpt*nx*nyRpt;
    dt = 1/47e3;
    
    %% File numbers
    %Num_file=1;  % number of file
    %LengthZ=400;  % extraction depth
    %Nspec=1;

    
    %% image reconstruction
    %%%%%%% used for calculating multiple subspectrum, eg. Nspec=[1 2 3 4 8]. set to 1 if calculating only one Nsepc, eg. Nspec=4. 
    %Num_pixel=floor(nk/Nspec); % number of pixels for each sub spectrum
    ifilePath=[datapath,filename0(1).name];
    disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
    [data_ori] = ReadDat_int16(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx
    disp(['Raw_Lamda data of file. ', ' Calculating RR ... ',datestr(now,'DD:HH:MM')]);
    data=Dat2RR(data_ori,-0.22);    % tune the second argument to get dispersion compensation
    dat=abs(data(:,:,:));           % calculate the magnitude of the FFT
    
%     I=squeeze(log10(dat(159,:,:)));
%     figure;imagesc(I);colormap gray;axis off;
    %dat=reshape(dat,[1024 400 1000]);
    
    %% data stripping (crop the depth of the image) and take the log of the image
     slice=dat(1:400,:,:);     % will be replaced by the surface finding function
     n=3;
     v=ones(3,n,n)./(n*n*3);
     w=convn(slice,v,'same');
     w=10*log10(w);
%    imagesc(squeeze(slice(:,200,:)));colormap gray;
%     matname=strcat('data-',coord,'.mat');
%     save(matname,'slice');
    
    % save the average A-line
%      avg=squeeze(mean(w,2));
%      save('avg_white.mat','avg');
%      figure;imagesc(avg);colormap gray;

    %% Generate AIP/MIP and save
    %avg_aline=squeeze(mean(mean(dat,2),3));
    %figure;plot(avg);
    %[m,index]=max(avg_aline);
    % get the tile index
    C=strsplit(filename0(1).name,'-');
    coord=strcat(C{3});
    slice_index=C{2};
    volname=strcat('/projectnb/npbssmic/ns/Jiarui/0426volume/volume/',slice_index,'-',coord,'.mat');
    save(volname,'w');
%     aip=squeeze(mean(slice(21:400,:,:),1));
%     mip=squeeze(max(slice(201:320,:,:),[],1));
%      imagesc(aip);colormap gray;
%      figure;imagesc(mip);colormap gray;
%     
%     % define the save path
%     avgname=strcat('/projectnb/npbssmic/ns/Jiarui/1219block/aip/vol1/',coord,'.mat');
%     mipname=strcat('/projectnb/npbssmic/ns/Jiarui/1219block/mip/vol1/',coord,'.mat');
%     save(mipname,'mip');
%     save(avgname,'aip');
end
end