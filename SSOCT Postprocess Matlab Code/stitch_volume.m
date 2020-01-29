clear all;

% mosaic parameters

Xsize=100;
Ysize=100;
Xoverlap=0.5;
Yoverlap=0.5;
Xtile=24;
Ytile=24;

% add path of functions
addpath('/projectnb/npbssmic/s/code/');
addpath('/projectnb/npbssmic/s/code/NIfTI_20140122');

%% get FIJI stitching info
filename = strcat('/projectnb/npbssmic/ns/190619_Thorlabs/aip/vol20/');
f=strcat(filename,'TileConfiguration.registered.txt');
coord = read_Fiji_coord(f,'aip');

%% coordinates correction
% use median corrdinates for all slices
% coord=squeeze(median(coord,1));

%% define coordinates for each tile

Xcen=zeros(size(coord,2),1);
Ycen=zeros(size(coord,2),1);
index=coord(1,:);

for ii=1:size(coord,2)
    Xcen(coord(1,ii))=round(coord(2,ii)/4);
    Ycen(coord(1,ii))=round(coord(3,ii)/4);
end


%% select tiles for sub-region volumetric stitching

Xcen=Xcen-min(Xcen);
Ycen=Ycen-min(Ycen);

Xcen=Xcen+Xsize/2;
Ycen=Ycen+Ysize/2;

% tile range -199~+200
stepx = Xoverlap*Xsize;
x = [0:stepx-1 repmat(stepx,1,(1-2*Xoverlap)*Xsize) stepx-1:-1:0]./stepx;
stepy = Yoverlap*Ysize;
y = [0:stepy-1 repmat(stepy,1,(1-2*Yoverlap)*Ysize) stepy-1:-1:0]./stepy;
[rampy,rampx]=meshgrid(x,y);
ramp=rampx.*rampy;      % blending mask


%% blending & mosaicing
    
Mosaic = zeros(max(Xcen)+Xsize/2 ,max(Ycen)+Ysize/2,15);
Masque = zeros(size(Mosaic));
Masque2 = zeros(size(Mosaic));

filename = strcat('/projectnb/npbssmic/ns/190619_Thorlabs/');
cd(filename);    

nslice=12;

nk = 400; nxRpt = 1; nx=400; nyRpt = 1; ny = 400;
dim=[nk nxRpt nx nyRpt ny];
     
for i=1:length(index)
     
    in = index(i);
    
    filename0=dir(strcat(num2str(nslice),'-',num2str(in),'-*.dat'));

    ifilePath=[filename,filename0(1).name];
    disp(['Start loading file ', datestr(now,'DD:HH:MM')]);
    
    slice = ReadDat_single(ifilePath, dim);
    slice = slice(131:190,:,:);
    temp=zeros(size(slice,1),size(slice,2)/4,size(slice,3)/4);
    
    for z=1:size(slice,1)
        temp(z,:,:)=imresize(squeeze(slice(z,:,:)),0.25);
    end
    
    %figure;imagesc(squeeze(temp(1,:,:)));colormap gray;
    
    vol = zeros(15,size(temp,2),size(temp,3));
    
    for z=1:size(vol,1)
        vol(z,:,:)=mean(temp((z-1)*4+1:z*4,:,:),1);
    end
    
    %figure;imagesc(squeeze(vol(1,:,:)));colormap gray;
    
    row = Xcen(in)-Xsize/2+1:Xcen(in)+Xsize/2;
    column = Ycen(in)-Ysize/2+1:Ycen(in)+Ysize/2;  
    
    
    for j=1:size(vol,1)
        Masque2(row,column,j)=ramp;
        Masque(row,column,j)=Masque(row,column,j)+Masque2(row,column,j);
        Mosaic(row,column,j)=Mosaic(row,column,j)+squeeze(vol(j,:,:))'.*Masque2(row,column,j);        
    end
    Mosaic(isnan(Mosaic(:)))=0;
end

Mosaic=Mosaic./Masque;

save(strcat('/projectnb/npbssmic/ns/190619_Thorlabs/nii/Mosaic',num2str(nslice),'.mat'),'Mosaic');
%nii=make_nii(Mosaic,[],[],64);
%save_nii(nii,'/projectnb/npbssmic/ns/190619_Thorlabs/nii/OCT_vol13.nii');