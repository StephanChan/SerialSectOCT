%% Example sample application
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');

op = '/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/dist_corrected/volume/'; 
cd(op);
id_list=[0 10 20 30 40 50];
id=str2num(id);
name1=strcat(op,'despeckle/cross pol depth ',num2str(id),'denoised.mat');
name2=strcat(op,'despeckle/co pol depth ',num2str(id),'denoised.mat');
id=id_list(id);
%% output folder

load('co1.mat');
co=Ref;
load('cross1.mat');
cross=Ref;
aip=squeeze(mean(co,3));
mask=zeros(size(aip));
mask(aip>0.07)=1;
co=double(co(:,:,id+1:id+10).^2.*10000);
cross=double(cross(:,:,id+1:id+10).^2.*10000);
%% Optimization or MM-despeckle parameters
% lambda  - regularization parameter (fixed), dont need a loop, can
% remove theoop, optional user input if someone wants to change
lam_co = 2700;%[2000:50:2600]; 
lam_cross=900;
step_size = 0.00001;%[0.000001:0.000001:0.0001];
%% MM-despeckle
resultco=zeros(size(co));
resultcross=zeros(size(cross));
for x=1:500:size(co,1)
    x2=min(x+499,size(co,1));
    for y=1:500:size(co,2)
        y2=min(y+499,size(co,2));
        area_co=co(x:x2,y:y2,:);
        area_cross=cross(x:x2,y:y2,:);
        area=mask(x:x2,y:y2);
        if sum(area(:))>3000
            for z=1:10
%                 tic
%                 slice=squeeze(area_co(:,:,z));
%                 p=gamfit(double(slice(area==1)));
%                 I= denoise_Tikhonov_ggd_mm(slice', lam_co,step_size,slice',p(1),1/p(2),1,'off')';%*Imean;
%                 resultco(x:x2,y:y2,z)=I;
%                 toc
                
                tic
                slice=squeeze(area_cross(:,:,z));
                p=gamfit(double(slice(area==1)));
                I= denoise_Tikhonov_ggd_mm(slice', lam_cross,step_size,slice',p(1),1/p(2),1,'off')';%*Imean;
                resultcross(x:x2,y:y2,z)=I;
                toc
            end
        end
    end
end



% save(name2,'resultco');
save(name1,'resultcross');

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