
%% ----------------------------------------- %%
% Note Oct 1:

% Current version of code does FOV correction, grid correction & MIP/AIP generation.

% Write to TIF images, stitching and blending was done in a seperate script.

% - Jiarui Yang
%%%%%%%%%%%%%%%%%%%%%%%

%% set file path & system type

system = 'PSOCT';

datapath  = strcat('D:\191004\191015_PSOCT4\');
folder_curve='D:\191004\grid';
if(strcmp(system,'PSOCT'))
    fileID = fopen(strcat(folder_curve,'/grid matrix.bin'), 'r'); 
    grid_matrix = fread(fileID,'double');
    fclose(fileID);
    grid_matrix=reshape(grid_matrix, 4,1100,1100);
    load(strcat(folder_curve,'\curvature_B_flip.mat'));
end
% add subfunctions for the script
addpath('C:\Users\BOAS-USER\Documents\MATLAB\OCT post processing\');
cd(datapath);
% total number of slices
nslice=59;

% create folder for AIPs and MIPs
create_dir(nslice, datapath);

for iSlice=2:nslice
    % get the directory of all image tiles
    cd(datapath);
    filename0=dir(strcat(num2str(iSlice),'-*.dat'));
    
    for iFile=1:length(filename0)

        % get data information
         nk = 120; nxRpt = 1; nx=1250; nyRpt = 1; ny = 1100;
         dim=[nk nxRpt nx nyRpt ny];

         ifilePath=[datapath,filename0(iFile).name];
         disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
         slice = ReadDat_single(ifilePath, dim);
         
         % pre-processing for PSOCT
         if(strcmp(system,'PSOCT'))
             slice = slice(:, 115:nx-36, :); %specify FOV cut
             slice = FOV_curvature_correction(slice, curvature_B, nk-30, nx-150, ny); % specify z and x 
             slice = Grid_correction(slice, grid_matrix, 1070, 40, 1080, 30, nk-30); % specify x0,x1,y0,y1 and z
         end

         aip=squeeze(mean(slice(1:end,:,:),1)); %specify range for AIP
         mip=squeeze(max(slice(1:end,:,:),[],1));% specify range for MIP

         C=strsplit(filename0(iFile).name,'-');
         slice_index=C{1};
         coord=C{2};

         avgname=strcat(datapath,'aip/vol',slice_index,'/',coord,'.mat');
         mipname=strcat(datapath,'mip/vol',slice_index,'/',coord,'.mat');
         save(mipname,'mip');
         save(avgname,'aip');  

        aip = uint16(65535*(mat2gray(aip)));        % change this line if using mip

        tiffname=strcat(datapath,'aip/vol',slice_index,'/',coord,'_aip.tif');

        t = Tiff(tiffname,'w');
        tagstruct.SampleFormat    = 1;
        tagstruct.ImageLength     = size(slice,2);
        tagstruct.ImageWidth      = size(slice,3);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(aip);
        t.close();

        mip = uint16(65535*(mat2gray(mip)));        % change this line if using mip

        tiffname=strcat(datapath,'mip/vol',slice_index,'/',coord,'_mip.tif');

        t = Tiff(tiffname,'w');
        tagstruct.SampleFormat    = 1;
        tagstruct.ImageLength     = size(slice,2);
        tagstruct.ImageWidth      = size(slice,3);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(mip);
        t.close();

        disp(['Tile No. ',num2str(iFile),' is finished']);
    end

    disp(['Slice No. ',num2str(iSlice),' is finished']);

end