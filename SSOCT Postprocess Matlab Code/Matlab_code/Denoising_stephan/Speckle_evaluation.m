% addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
% addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
% addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
% addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
% addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
% addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
% addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
% addpath('/projectnb/npbssmic/s/Matlab_code');
% 
op = '/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/dist_corrected/volume/despeckle/'; 
cd(op);
% 
% info=imfinfo('co pol kernel smooth.tif');
% co=[];
% for i=1:60
%     image=imread('co pol kernel smooth.tif',i,'info',info);
%     co(:,:,i)=image;
% end
% co=co.^0.5;
info=imfinfo('cross pol kernel smooth.tif');
cross=[];
for i=1:60
    image=imread('cross pol kernel smooth.tif',i,'info',info);
    cross(:,:,i)=image;
end
cross=cross.^0.5;

% co=vol.^0.5;
% cross=vol2.^0.5;
speckle_co=zeros(size(co,1),size(co,2),6);
speckle_cross=zeros(size(co,1),size(co,2),6);
for x=1:500:size(co,1)
    x2=min(x+499,size(co,1));
    for y=1:500:size(co,2)
        y2=min(y+499,size(co,2));
        area_co=co(x:x2,y:y2,:);
        area_cross=cross(x:x2,y:y2,:);
        
            for z=[2 10 20 30 40 50]
                slice=squeeze(area_co(:,:,z));
                slice0=squeeze(area_co(:,:,2));
                mask=zeros(size(slice0));
                mask(slice0>7)=1;
%                 if mean(slice(:))>0
%                     s=std(slice(mask==1))/mean(slice(mask==1));
%                 else
%                     s=0;
%                 end
%                 speckle_co(x:x2,y:y2,floor(z/10)+1)=s.*mask;

               
                slice=squeeze(area_cross(:,:,z));
                if mean(slice(:))>0
                   s=std(slice(mask==1))/mean(slice(mask==1));
                else
                    s=0;
                end
                speckle_cross(x:x2,y:y2,floor(z/10)+1)=s.*mask;

            end

    end
end

for i=1:4
    figure(1);imagesc(speckle_cross(:,:,i));caxis([0.15,0.3]);colorbar;
    title(strcat('cross pol kernel smooth depth',num2str((i-1)*30),'um speckle contrast'));
    saveas(gcf, strcat(op,'speckle/cross pol kernel smooth depth',num2str((i-1)*30),'um speckle contrast.png'));
    close
end