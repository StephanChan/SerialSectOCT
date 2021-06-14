clear all;

%% ----------------------------------------- %%
% Note Jan 23:

% Current version of code does resampling, background extraction, 
% dispersion compensation, FFT and data stripping, MIP/AIP generation.

% Write to TIF images, stitching and blending was done in a seperate script.

% Will implement the surface finding function for data stripping soon.
% Current algorithm needs some further testing.

% Will also integrate write to TIF images, stitching and blending in the
% same script soon.

% - Jiarui Yang
%%%%%%%%%%%%%%%%%%%%%%%
%% set file path
datapath  = strcat('/projectnb/npbssmic/ns/210111_Ann_7694_tomato_lectin/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/Matlab_code/');

% get the directory of all image tiles
cd(datapath);

%% get data information
%% change these parameters to appropriate values!
%[dim, fNameBase,fIndex]=GetNameInfoRaw(filename0(iFile).name);
nk = 2048; nxRpt = 1; nx=400; nyRpt = 1; ny = 1;
dim=[nk nxRpt nx nyRpt ny];

% s=zeros(400,400,400);
filename0=dir(strcat('RAW-*.dat'));

for i=1:length(filename0)
    ifilePath=[datapath,filename0(i).name];
    disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
    [data_ori] = ReadDat_int16(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx
    disp(['Raw_Lamda data of file. ', ' Calculating RR ... ',datestr(now,'DD:HH:MM')]);
    data=Dat2RR(data_ori,-0.24);
    if nyRpt==2
        % reorganize RR
        RR(:,:,:,1)=data(:,1:2:end,:);
        RR(:,:,:,2)=data(:,2:2:end,:);     
        dat=RR2AG(RR);
        slice=dat(1:600,:,:);
    else
        slice=abs(data(1:400,:,:));
    end
    % s=s+slice;
end

% save('angio.mat','slice');
% save as tiff

s=uint16(65535*(mat2gray(10.*log10(slice)))); 
tiffname=strcat('/projectnb/npbssmic/ns/210111_Ann_7694_tomato_lectin/slice_20x_400_r.24_28khz_2.tif');
for i=1:size(s,3)
    t = Tiff(tiffname,'a');
    image=squeeze(s(:,:,i));
    tagstruct.ImageLength     = size(image,1);
    tagstruct.ImageWidth      = size(image,2);
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(image);
    t.close();
end

