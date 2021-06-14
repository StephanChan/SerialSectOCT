%% Example sample application

% clear all;
% close all;
% clc
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');
% id_list=[1 10 20 30 40 50 60];
id=1;%str2num(id);
% id=id_list(id);
%% output folder
op = '/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/denoised/'; 
cd(op);
load('area_cross.mat');
vol=area_cross.*10000;
Param=zeros(2,60);
speckle_pre=zeros(1,60);
for z=1:60
    slice=squeeze(vol(:,:,z));
    speckle_pre(z)=std(sqrt(vol(:,:,z)))/mean(sqrt(vol(:,:,z)));
    Param(:,z)=gamfit(double(slice(:)));
end
I=double(vol);
save(strcat('cross pol pre denoising speckle contrast.mat'),'speckle_pre');
%% Optimization or MM-despeckle parameters
% lambda  - regularization parameter (fixed), dont need a loop, can
% remove the loop, optional user input if someone wants to change
% lambda = 0.007 (not normalized)
lam = 500;%[100:50:8000]; 
step_size = 0.00001;%[0.000001:0.000001:0.0001];
speckle_ctt=zeros(1,60);
% time_e=zeros(size(step_size));
%% MM-despeckle
ind = 0;
I_den=zeros(500,500,60);
  
for nz = 1:60 % parfor might work , loop for slices
    I2=squeeze(I(:,:,nz));
    tic
    I_den(:,:,nz) = denoise_Tikhonov_ggd_mm(I2', lam,step_size,I2',Param(1,nz),1/Param(2,nz),1,'off')';%*Imean;
    speckle_ctt(nz)=std(sqrt(I_den(:,:,nz)))/mean(sqrt(I_den(:,:,nz)));
    toc
end

save(strcat('cross pol denoised','speckle contrast.mat'),'speckle_ctt');

%% Save I_den
save(strcat(op, 'I_den_cross.mat'), 'I_den'); 


for t=1:size(vol,3)
    mip=single(squeeze(squeeze(vol(:,:,t))));
    tiffname=strcat(op,'cross pre-denoised.tif');
    t = Tiff(tiffname,'a');
    tagstruct.ImageLength     = size(mip,1);
    tagstruct.ImageWidth      = size(mip,2);
    tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 32;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(mip);
    t.close();
end