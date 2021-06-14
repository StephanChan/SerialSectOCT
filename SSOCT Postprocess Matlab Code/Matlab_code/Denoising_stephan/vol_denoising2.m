%% Example sample application
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');
id_list=[1 10 20 30 40 50 60];
id=str2num(id);
id=id_list(id);
%% output folder
op = '/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/dist_corrected/volume/'; 
cd(op);
load('cross1.mat');
% vol=Ref.^2.*10000;
I2=double(Ref(601:3500,1501:2600,id).^2.*10000);
%% Optimization or MM-despeckle parameters
% lambda  - regularization parameter (fixed), dont need a loop, can
% remove the loop, optional user input if someone wants to change
lam = [2000:50:2600]; 
step_size = 0.00001;%[0.000001:0.000001:0.0001];
speckle_ctt=zeros(size(lam));
%% MM-despeckle
ink=0;
    for lambda=lam
        ink=ink+1;
%         I2=squeeze(I(:,:,nz));
        tic
        p=gamfit(double(I2(:)));
        I_den = denoise_Tikhonov_ggd_mm(I2', lambda,step_size,I2',p(1),1/p(2),1,'off')';%*Imean;
        speckle_ctt(1,ink)=std(sqrt(I_den))/mean(sqrt(I_den));
        toc
    end


save(strcat(op,'despeckle/cross pol denoised depth',num2str(id),'speckle contrast.mat'),'speckle_ctt');

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