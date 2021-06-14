addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');

op = '/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/dist_corrected/volume/despeckle/'; 
cd(op);

vol2=[];
for i=1:6
    load(strcat('cross pol depth',num2str(i),'denoised.mat'))
    vol2(:,:,(i-1)*10+1:i*10)=resultcross;
end

for k=1:60%size(vol2,3)
    mip=single(squeeze(squeeze(vol2(:,:,k))));
    tiffname=strcat(op,'cross pol denoised.tif');
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

