folder='/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/';
datapath=strcat(folder,'dist_corrected/'); 

% add subfunctions for the script. Change directory if not running on BU SCC
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');

cd(datapath);
filename0=dir(strcat('cross-1-*.dat')); % count #tiles per slice
ntile=length(filename0);
nslice=3; % define total number of slices

    njobs=20;
    section=ceil(ntile/njobs);
    % the $SGE-TASK-ID environment variable read in is CHARACTER, need to transfer to number
    id=str2num(id);
    istart=(id-1)*section+1;
    istop=id*section;
mkdir(strcat(folder,'denoised/vol',num2str(1)));
for islice=1
    Param_co=zeros(50,2);
    Param_cross=zeros(50,2);
    Param_sum=zeros(50,2);
    for iFile=istart:istop
        name=strsplit(filename0(iFile).name,'.');  
        name_dat=strsplit(name{1},'-');
        slice_index=islice;
        coord=num2str(iFile);
        % Xrpt and Yrpt are x and y scan repetition, default = 1
        Zsize = str2num(name_dat{4}); Xrpt = 1; Xsize=str2num(name_dat{5}); Yrpt = 1; Ysize = str2num(name_dat{6});
        dim1=[Zsize Xrpt Xsize Yrpt Ysize];     % tile size for reflectivity 
        name1=strcat('co-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat'); % gen file name for reflectivity
        name2=strcat('cross-',num2str(islice),'-',num2str(iFile),'-',num2str(Zsize),'-',num2str(Xsize),'-',num2str(Ysize),'.dat');
        % load reflectivity data
        ifilePath1 = [datapath,name1];
        ifilePath2 = [datapath,name2];
        co = ReadDat_int16(ifilePath1, dim1)./65535*2; 
        cross = ReadDat_int16(ifilePath2, dim1)./65535*2; 
        ref=sqrt(co.^2+cross.^2);
        message=strcat('Tile No. ',string(coord),' is read.', datestr(now,'DD:HH:MM'),'\n');
        fprintf(message);
        aip=squeeze(mean(cross,1));
        mask=zeros(size(aip));
        mask(aip>0.03)=1;
        
        aip3=squeeze(mean(co,1));
        mask3=zeros(size(aip3));
        mask3(aip3>0.05)=1;
        
        aip2=squeeze(mean(ref,1));
        mask2=zeros(size(aip2));
        mask2(aip2>0.06)=1;
        for z=1:50
            z
            slice=squeeze(cross(z+25,:,:));
            m=mean(slice(mask==1));
            pdEstimated = GeneralizedGamma();
            try
%                p = pdEstimated.fitDist(slice(mask==1)./m)
               p=gamfit(double(slice(mask==1)./m))
            catch
                p=[0 0];
            end
            Param_cross(z,:)=p;
            
            slice3=squeeze(co(z+25,:,:));
            m=mean(slice3(mask3==1));
            try
%                p = pdEstimated.fitDist(slice3(mask3==1)./m)
               p=gamfit(double(slice3(mask3==1)./m))
            catch
                p=[0 0];
            end
            Param_co(z,:)=p;
            
            slice2=squeeze(ref(z+25,:,:));
            m=mean(slice2(mask2==1));
            try
%                p = pdEstimated.fitDist(slice2(mask2==1)./m)
               p=gamfit(double(slice2(mask2==1)./m))
            catch
                p=[0 0];
            end
            Param_sum(z,:)=p;

        end
        save(strcat(folder,'denoised/vol1/','cross_param_gmma',coord,'.mat'),'Param_cross');
        save(strcat(folder,'denoised/vol1/','ref_param_gmma',coord,'.mat'),'Param_sum');
        save(strcat(folder,'denoised/vol1/','co_param_gmma',coord,'.mat'),'Param_co');
%         Optical_fitting(ref,id, coord, '/projectnb2/npbssmic/ns/201028_PSOCT_Ann_7688/', 3);
    end
end