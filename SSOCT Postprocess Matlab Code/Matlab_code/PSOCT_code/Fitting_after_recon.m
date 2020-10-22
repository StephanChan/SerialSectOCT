datapath=strcat('/projectnb2/npbssmic/ns/200903_PSOCT/dist_corrected/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
filename0=dir(strcat('ref-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=60; % define total number of slices

    njobs=6;
    section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
    id=str2num(id);
    istart=(id-1)*section+1;
    istop=id*section;

for islice=1
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[232 1 1000 1 1000];     % tile size for reflectivity 
        name1=strcat('ref-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'-AB.dat'); % gen file name for reflectivity
        % load reflectivity data
        ifilePath = [datapath,name1];
        ref = ReadDat_single(ifilePath, dim1); 
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        Optical_fitting(ref,1, coord, '/projectnb2/npbssmic/ns/200903_PSOCT/', 3);
    end
end