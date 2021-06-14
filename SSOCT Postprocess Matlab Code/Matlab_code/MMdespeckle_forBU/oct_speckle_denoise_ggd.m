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
id=str2num(id);
if id==2
    iteration=5
end
% id=id_list(id);
%% output folder
op = '/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/denoised/'; 
cd(op);
load('area_cross.mat');
vol=area_cross.*10000;
% Param=zeros(2,60);
% for z=1:60
%     slice=squeeze(area_co(:,:,z));
%     Param(:,z)=gamfit(double(slice(:)));
% end
% slice=vol(:,:,id);
% p=gamfit(double(slice(:)));
%% Add code to load your OCT data
% output should be storedin variable I with size (N1,N2,N3). N3 - depth, linear intensity
% Example:
% oct_data = '/autofs/space/vault_003/users/Hui/ProfileFitting/MicroBead1um_110916/Dil1/';
% files = dir(oct_data);
% y = load([oct_data files(num).name]);
% I = y.IJones1;
I=double(vol);
%% Parameters from GGD fitting
% a = 1.14;
% b = 1.20;
% e = 0.92;
% p=gamfit(double(area_cross(:)));
% a=p(1);
% b=1/p(2);
% e=1;
%% Optimization or MM-despeckle parameters
% lambda  - regularization parameter (fixed), dont need a loop, can
% remove the loop, optional user input if someone wants to change
% lambda = 0.007 (not normalized)
lam = 500;%[100:50:8000]; 
% lam=[10000];
% gradient descent step size - might have to tweak this value to work for
% your data. step_size = 1 (not normalized)
step_size = 0.00001;%[0.000001:0.000001:0.0001];
speckle_ctt=zeros(size(step_size));
% time_e=zeros(size(step_size));
%% MM-despeckle
ind = 0;
I_den=zeros([size(I(:,:,id)) length(step_size)]);
for lambda = lam
    lambda
    ind = ind+1 % for regularization
    fprintf('Denoising begin\n');
    indv = 0;
  
    for nz = id % parfor might work , loop for slices
        % Optional normalization. You can use Imean = 1; I2 = I(nx,:,nv);
        % to remove normalization.
        % Code is faster with normalization as it has to work with lower
        % value numbers.
%         Imean = mean(vect(I(:,:,nz)));
%         I2 = I(:,:,nz)/Imean; 
        I2=squeeze(I(:,:,nz));
        tic
        I_den(:,:,ind) = denoise_Tikhonov_ggd_mm(I2', lam,lambda,I2',p(1),1/p(2),1,'off')';%*Imean;
        elapsedTime=toc
        speckle_ctt(ind)=std(sqrt(I_den(:,:,ind)))/mean(sqrt(I_den(:,:,ind)));
        time_e(ind)=elapsedTime;
%         toc
    end
    disp('Done');
end
save(strcat('cross pol depth',num2str(id),'speckle contrast.mat'),'speckle_ctt');
save(strcat('cross pol depth',num2str(id),'elapsed time.mat'),'time_e');
%% Save I_den
% save(strcat(op, 'I_den.mat'), I_den); 

%% Save as tiff
% save original
% mip=single(squeeze(squeeze(I(:,:,23))));
% tiffname=strcat(op,'co_trial1_depth23.tif');
% t = Tiff(tiffname,'w');
% tagstruct.ImageLength     = size(mip,1);
% tagstruct.ImageWidth      = size(mip,2);
% tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
% tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
% tagstruct.BitsPerSample   = 32;
% tagstruct.SamplesPerPixel = 1;
% tagstruct.Compression     = Tiff.Compression.None;
% tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% tagstruct.Software        = 'MATLAB';
% t.setTag(tagstruct);
% t.write(mip);
% t.close();
% %same denoised
% for t=1:length(lam)
%     mip=single(squeeze(squeeze(I_den(:,:,t))));
%     tiffname=strcat(op,'co_trial1_depth23.tif');
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