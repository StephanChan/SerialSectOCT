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
    Param=zeros(3,15,3);
for x=301:300:4500
    t=t+1;
    area_co=co(x:x+299,1851:2150,6:55);
    area_cross=cross(x:x+299,1851:2150,6:55);
    area_ref=ref(x:x+299,1851:2150,6:55);
%     Pco=zeros(50,3);
%     Pcross=zeros(50,3);
%     Pref=zeros(50,3);

    for z=1:100

        slice=squeeze(area_co(:,:,z));
        m=mean(slice(:));
        area_co(:,:,z)=slice./m;
        
        slice=squeeze(area_cross(:,:,z));
        m=mean(slice(:));
        area_cross(:,:,z)=slice./m;
        
%         slice=squeeze(area_ref(:,:,z));
%         m=mean(slice(:));
%         area_ref(:,:,z)=slice./m;

    end
    
    try
        p = pdEstimated.fitDist(area_co(:))
    catch
        p=[0 0 0 ];
    end
    Param(1,t,:)=p;
    
    try
        p = pdEstimated.fitDist(area_cross(:))
    catch
        p=[0 0 0 ];
    end
    Param(2,t,:)=p;
    
    try
        p = pdEstimated.fitDist(area_ref(:))
    catch
        p=[0 0 0 ];
    end
    Param(3,t,:)=p;
    
%     save(strcat('Pco',num2str(t),'.mat'),'Pco');
%     save(strcat('Pcross',num2str(t),'.mat'),'Pcross');
%     save(strcat('Pref',num2str(t),'.mat'),'Pref');
end
% figure;plot(P(1,:,1));
% figure;plot(P(2,:,1));
% figure;plot(P(3,:,1));
save(strcat('Param','.mat'),'Param');