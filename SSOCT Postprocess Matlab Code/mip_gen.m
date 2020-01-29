clear all;

filepath='C:\Users\jryang\Desktop\Vibratome_data\0927\';
Xtile=14;
Ytile=13;

%% find max intensity for normalization
ma=zeros(4,1);

for i=1:Xtile
    for j=1:Ytile
        cordX=72.5+0.7*(i-1);
        cordY=27.6+0.7*(j-1);
        datapath  = strcat(filepath,num2str(cordX),'-',num2str(cordY),'\');
        cd(datapath);
        load('data.mat');
        index=Ytile*(i-1)+j;
        aip=squeeze(mean(slice(51:350,:,:),1));
        ma(index)=max(max(aip));
    end
end

MaxInt = max(ma);

for i=1:Xtile
    for j=1:Ytile
        cordX=72.5+0.7*(i-1);
        cordY=27.6+0.7*(j-1);
        datapath  = strcat(filepath,num2str(cordX),'-',num2str(cordY),'\');
        cd(datapath);
        load('data.mat');
        data=slice;
        
        index=Ytile*(i-1)+j;

%         mip=squeeze(max(data(50:end,:,:),[],1));
%         mip = uint16(65535*(mip./max(max(mip))));
        
        aip=squeeze(mean(data(51:350,:,:),1));
        aip=aip./MaxInt;
        aip = uint16(65532*mat2gray(aip));
        
%         tiffname=strcat(num2str((i-1)*4+j),'_mip.tif');
%     
%         t = Tiff(tiffname,'w');
%         tagstruct.ImageLength     = size(data,2);
%         tagstruct.ImageWidth      = size(data,3);
%         tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
%         tagstruct.BitsPerSample   = 16;
%         tagstruct.SamplesPerPixel = 1;
%         tagstruct.Compression     = Tiff.Compression.None;
%         tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%         tagstruct.Software        = 'MATLAB';
%         t.setTag(tagstruct);
%         t.write(mip);
%         t.close();
        
        tiffname=strcat(num2str(index),'_aip.tif');
    
        t = Tiff(tiffname,'w');
        tagstruct.ImageLength     = size(data,2);
        tagstruct.ImageWidth      = size(data,3);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 16;
        tagstruct.SamplesPerPixel = 1;
        tagstruct.Compression     = Tiff.Compression.None;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct);
        t.write(aip);
        t.close();
    
        message=strcat('tile No. ',num2str(i),'-',num2str(j),' is processed');
        disp(message);
    end
end
