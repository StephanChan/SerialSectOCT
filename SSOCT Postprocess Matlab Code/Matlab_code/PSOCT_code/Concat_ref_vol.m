function[]=Concat_ref_vol(num_slice, datapath)
volume=[];
addpath('/projectnb/npbssmic/s/Matlab_code/NIfTI_20140122');
for islice=1:num_slice
    
    % filename = strcat(datapath,'dist_corrected/volume/ref',num2str(islice),'.mat');
    
    % for MGH I46 BA4445 sample
    filename = strcat(datapath,'volume/ref',num2str(islice),'.mat');
    
    load(filename);
    
%     Mosaic=Mosaic(:,2:1231,:);
    
%    Mosaic=10000.*(Mosaic-min(Mosaic(:)))+0.001;
    % simple linear normalization over depth

    %Mosaic=slide_win_norm(Mosaic,[10 10]);
    
    volume=cat(3,volume,Ref);
    
    % for MGH I46 BA4445 sample
    % volume=cat(3,volume,Mosaic);
    
    info=strcat('loading slice No.',num2str(islice),' is finished.\n');
    fprintf(info);
end

% save as TIFF
% s = uint8(255*(mat2gray(volume))); 
% % s=single(volume/65535*180);
% cd(strcat(datapath,'dist_corrected/volume/'));
% clear options;
% options.big = true; % Use BigTIFF format
% saveastiff(s, 'ref.btf', options);
% volume=uint8(255*(mat2gray(volume)));
% tiffname=strcat(datapath,'dist_corrected/volume/ref.tif');
% for i=1:size(volume,3)
%     t = Tiff(tiffname,'a');
%     image=squeeze(volume(:,:,i));
%     tagstruct.ImageLength     = size(image,1);
%     tagstruct.ImageWidth      = size(image,2);
% %     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 8;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Compression = Tiff.Compression.None;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(image);
%     t.close();
% end

% save as nifti
nii=make_nii(single(volume),[0.012 0.012 0.012],[0 0 0],32,'OCT volume for subject I46');
save_nii(nii,'/projectnb/npbssmic/ns/200103_PSOCT_2nd_BA44_45_dist_corrected/nii/sub-I46_ses-OCT.nii');

info=strcat('concatinating slices is finished.\n');
fprintf(info);