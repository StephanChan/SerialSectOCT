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
datapath  = strcat('/projectnb/npbssmic/ns/191004_phantom/16intralipid/');

% add subfunctions for the script
addpath('/projectnb/npbssmic/s/code');

% get the directory of all image tiles
cd(datapath);

numTile=10;

s=zeros(400,400,400);

for iFile=1:numTile
    
    %% add MATLAB functions' path
    %addpath('D:\PROJ - OCT\CODE-BU\Functions') % Path on JTOPTICS
    % addpath('/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/Functions') % Path on SCC server
    
    %% get data information
    %[dim, fNameBase,fIndex]=GetNameInfoRaw(filename0(iFile).name);
    nk = 2048; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
    dim=[nk nxRpt nx nyRpt ny];
    nz0 = nk/2;
    Nx=nxRpt*nx*nyRpt;
    dt = 1/47e3;
    
    filename0=dir(strcat('RAW-*.dat'));
    
    if ~isempty(filename0)
        ifilePath=[datapath,filename0(1).name];
        disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
        [data_ori] = ReadDat_int16(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx
        disp(['Raw_Lamda data of file. ', ' Calculating RR ... ',datestr(now,'DD:HH:MM')]);
        data=Dat2RR(data_ori,-0.22);
        dat=abs(data(:,:,:));

        % crop the depth of the image and take log
        slice=dat(1:400,:,:);
        % slice=10*log10(slice);

        C=strsplit(filename0(1).name,'-');
        coord=strsplit(C{7},'.');
        index=coord{1};
        
        matname=strcat(index,'.mat');
        save(matname,'slice');
        delete(ifilePath);
    end
    s=s+slice;
    
end

s=s./10;
save('avg.mat','s');