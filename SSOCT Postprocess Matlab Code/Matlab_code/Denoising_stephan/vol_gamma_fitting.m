% fitting gamma distribution to intensity of cross, co and ref
addpath('/projectnb/npbssmic/s/Matlab_code/fitting_code');
addpath('/projectnb/npbssmic/s/Matlab_code/PostProcessing');
addpath('/projectnb/npbssmic/s/Matlab_code/PSOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/ThorOCT_code');
addpath('/projectnb/npbssmic/s/Matlab_code/Denoising_stephan');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/GGD_fitting/generalized-gamma-master/');
addpath('/projectnb/npbssmic/s/Matlab_code/MMdespeckle_forBU/');
addpath('/projectnb/npbssmic/s/Matlab_code');

folder='/projectnb2/npbssmic/ns/201124_PSOCT_amp_phase/';
datapath=strcat(folder,'dist_corrected/volume/'); 
cd(datapath)
load('co1_sd.mat');
co=Ref.^2;
load('cross1.mat');
cross=Ref.^2;
ref=co+cross;
clear('Ref')
pdEstimated = GeneralizedGamma();
t=0;
for x=301:300:1600
    t=t+1;
    area_co=co(x:x+299,1851:2150,:);
    area_cross=cross(x:x+299,1851:2150,:);
    area_ref=ref(x:x+299,1851:2150,:);
    Pco=zeros(50,3);
    Pcross=zeros(50,3);
    Pref=zeros(50,3);
    
    for z=1:100
        z
        slice=squeeze(area_co(:,:,z));
        m=mean(slice(:));
        try
            p = pdEstimated.fitDist(slice(:)./m)
        catch
            p=[0 0 0];
        end
%         p=gamfit(double(slice(:)./m))
        Pco(z,:)=p;
%         my_title=strcat('ROI ',num2str(t),'depth',num2str(z*3),'um co^2 histogram');
%         Save_png(slice,m,p,my_title);
%         saveas(1,strcat(my_title,'.png'))
%         close;
        
        slice=squeeze(area_cross(:,:,z));
        m=mean(slice(:));
        try
            p = pdEstimated.fitDist(slice(:)./m)
        catch
            p=[0 0 0 ];
        end
%         p=gamfit(double(slice(:)./m))
        Pcross(z,:)=p;
%         my_title=strcat('ROI ',num2str(t),'depth',num2str(z*3),'um cross^2 histogram');
%         Save_png(slice,m,p,my_title);
%         saveas(1,strcat(my_title,'.png'))
%         close;

        slice=squeeze(area_ref(:,:,z));
        m=mean(slice(:));
        try
            p = pdEstimated.fitDist(slice(:)./m)
        catch
            p=[0 0 0 ];
        end
%         p=gamfit(double(slice(:)./m))
%         my_title=strcat('ROI ',num2str(t),'depth',num2str(z*3),'um ref^2 histogram');
%         Save_png(slice,m,p,my_title);
%         saveas(1,strcat(my_title,'.png'))
%         close;
        Pref(z,:)=p;
    end
    save(strcat('Pco',num2str(t),'.mat'),'Pco');
    save(strcat('Pcross',num2str(t),'.mat'),'Pcross');
    save(strcat('Pref',num2str(t),'.mat'),'Pref');
end
    