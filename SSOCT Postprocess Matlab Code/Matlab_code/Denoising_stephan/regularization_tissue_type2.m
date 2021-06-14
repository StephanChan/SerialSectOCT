%% Example sample application
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');

id=str2num(id);

%% output folder
op = '/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/dist_corrected/volume/'; 
cd(op);
load('co1.mat');
vol=Ref.^2.*10000;
I=double(vol(3201:3700,351+(id-1)*500:350+id*500,1:60));
%% Optimization or MM-despeckle parameters
% lambda  - regularization parameter (fixed), dont need a loop, can
% remove the loop, optional user input if someone wants to change
lam = [100:100:5000]; 
step_size = 0.00001;%[0.000001:0.000001:0.0001];
speckle_ctt=zeros(7,60);
%% MM-despeckle
z=0;
for nz = [1 10 20 30 40 50 60] % parfor might work , loop for slices
    z=z+1;
    ink=0;
    for lambda=lam
        ink=ink+1;
        I2=squeeze(I(:,:,nz));
        tic
        p=gamfit(double(I2(:)));
        I_den = denoise_Tikhonov_ggd_mm(I2', lambda,step_size,I2',p(1),1/p(2),1,'off')';%*Imean;
        speckle_ctt(z,ink)=std(sqrt(I_den))/mean(sqrt(I_den));
        toc
    end
end

save(strcat(op,'despeckle/co pol denoised area',num2str(id),'speckle contrast.mat'),'speckle_ctt');

%% Save I_den
% save(strcat(op, 'I_den_cross.mat'), 'I_den'); 


% for t=1:size(vol,3)
%     mip=single(squeeze(squeeze(vol(:,:,t))));
%     tiffname=strcat(op,'cross pre-denoised.tif');
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