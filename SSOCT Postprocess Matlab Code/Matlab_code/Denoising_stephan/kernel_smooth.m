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
load('co1.mat');
co=Ref;
load('cross1.mat');
cross=Ref;
aip=squeeze(mean(co,3));
mask=zeros(size(aip));
mask(aip>0.07)=1;
cross=double(cross(:,:,1:60).^2.*10000.*mask);
co=double(co(:,:,1:60).^2.*10000.*mask);
co_kernel=zeros(size(co));
cross_kernel=zeros(size(cross));

tic
for x=1:size(co,1)
    x1=max(x-2,1);
    x2=min(x+3,size(co,1));
    for y=1:size(co,2)
        y1=max(y-2,1);
        y2=min(y+3,size(co,2));
        for z=1:60
            areaco=co(x1:x2,y1:y2,z);
            co_kernel(x,y,z)=mean(areaco(:));
%             areacross=cross(x1:x2,y1:y2,z);
%             cross_kernel(x,y,z)=mean(areacross(:));
        end
    end
end
toc

for t=1:60%size(vol,3)
    mip=single(squeeze(squeeze(co_kernel(:,:,t))));
    tiffname=strcat(op,'despeckle/co pol kernel smooth.tif');
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
        
% for t=1:60%size(vol,3)
%     mip=single(squeeze(squeeze(cross_kernel(:,:,t))));
%     tiffname=strcat(op,'despeckle/cross pol kernel smooth.tif');
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
%         