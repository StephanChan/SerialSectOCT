%% Set file location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datapath  = strcat('C:\Users\jryang\Desktop\Data\0126volume\aip\vol3\');
cd(datapath);
filename0=dir('*.mat');

for i=1:length(filename0)
    load(filename0(i).name);
    coord=strsplit(filename0(i).name,'.');
    
    index=str2num(coord{1});
    aip = uint16(65535*(mat2gray(aip)));        % change this line if using mip
    
    tiffname=strcat(num2str(index),'_aip.tif');

    t = Tiff(tiffname,'w');
    tagstruct.ImageLength     = 400;%size(data,2);
    tagstruct.ImageWidth      = 400;%size(data,3);
    tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample   = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression     = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.Software        = 'MATLAB';
    t.setTag(tagstruct);
    t.write(aip);
    t.close();
end