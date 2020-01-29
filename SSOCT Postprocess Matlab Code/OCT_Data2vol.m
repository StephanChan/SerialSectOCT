datapath  = strcat('/projectnb/npbssmic/ns/190628_Thorlabs/depth1/');
addpath('/projectnb/npbssmic/s/code');
cd(datapath);

filename0=dir('1-*.dat');

% add subfunctions for the script
% get the directory of all image tiles

for iFile=1:length(filename0)
    
    %% add MATLAB functions' path
    %addpath('D:\PROJ - OCT\CODE-BU\Functions') % Path on JTOPTICS
    % addpath('/projectnb/npboctiv/ns/Jianbo/OCT/CODE/BU-SCC/Functions') % Path on SCC server
    %load(filename0(iFile).name);
    %% get data information
     nk = 400; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
     dim=[nk nxRpt nx nyRpt ny];
     
     ifilePath=[datapath,filename0(iFile).name];
     disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
     [slice] = ReadDat_single(ifilePath, dim); % read raw data: nk_Nx_ny,Nx=nt*nx


     C=strsplit(filename0(iFile).name,'-');
     slice_index=C{1};
     coord=C{2};
     
     save(matname,'slice');
    
    disp(['Tile No. ',num2str(iFile),' is finished']);
end