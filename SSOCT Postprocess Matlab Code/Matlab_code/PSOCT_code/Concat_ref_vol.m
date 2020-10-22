function[]=Concat_ref_vol(num_slice, datapath)
% num_slice=60;
filename = strcat(datapath,'dist_corrected/volume/ref',num2str(1),'.mat');
load(filename);
volume=zeros(size(Ref,1),size(Ref,2),11*num_slice);

for islice=1:num_slice
    
    filename = strcat(datapath,'dist_corrected/volume/ref',num2str(islice),'.mat');
    load(filename);
    
%     Mosaic=Mosaic(:,2:1231,:);
    
%    Mosaic=10000.*(Mosaic-min(Mosaic(:)))+0.001;
    % simple linear normalization over depth

    %Mosaic=slide_win_norm(Mosaic,[10 10]);
    
    volume(:,:,(islice-1)*11+1:islice*11)=Ref;
    
    info=strcat('loading slice No.',num2str(islice),' is finished.\n');
    fprintf(info);
end

% save as TIFF
s=uint16(65535*(mat2gray(volume))); 
% s=single(volume/65535*180);
cd(strcat(datapath,'dist_corrected/volume/'));
clear options;
options.big = true; % Use BigTIFF format
saveastiff(s, 'ref.btf', options);
% tiffname=strcat(datapath,'dist_corrected/volume/ref.tif');
% for i=1:size(s,3)
%     t = Tiff(tiffname,'a');
%     image=squeeze(s(:,:,i));
%     tagstruct.ImageLength     = size(image,1);
%     tagstruct.ImageWidth      = size(image,2);
% %     tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
%     tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%     tagstruct.BitsPerSample   = 16;
%     tagstruct.SamplesPerPixel = 1;
%     tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%     tagstruct.Compression = Tiff.Compression.None;
%     tagstruct.Software        = 'MATLAB';
%     t.setTag(tagstruct);
%     t.write(image);
%     t.close();
% end
info=strcat('concatinating slices is finished.\n');
fprintf(info);