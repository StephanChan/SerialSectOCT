folder='/projectnb2/npbssmic/ns/201018_PSOCT_30um_on_slide/';
cd(folder);
files=dir('*AB.dat');
num_files=length(files);
sum=zeros(300,1100,1100);

for i=1:64
    i
%     info = niftiinfo(strcat(folder,files(i).name));
%     sum = sum+niftiread(info);
%      load(files(i).name);
%      sum=sum+sqrt(IJones);
    ref = ReadDat_int16(strcat(folder,files(i).name), [300 1 1250 1 1100 ]);
    sum=sum+ref(:,106:1205,:)./65535*2;
end
save('sum_all.mat','sum')
% v=ones(3,3,3)./27;
% sum=convn(sum,v,'same');
% % sum=flip(sum,3);
% [m,x]=max(sum4,[],1);
% % x(x>std(x(:))*4)=mean(x(:));
surface=surprofile2(sum,'PSOCT');

mip=single(surface);
tiffname=strcat(folder,'/','surface.tif');
t = Tiff(tiffname,'w');
tagstruct.ImageLength     = size(mip,1);
tagstruct.ImageWidth      = size(mip,2);
tagstruct.SampleFormat    = Tiff.SampleFormat.IEEEFP;
tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample   = 32;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression     = Tiff.Compression.None;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software        = 'MATLAB';
t.setTag(tagstruct);
t.write(mip);
t.close();