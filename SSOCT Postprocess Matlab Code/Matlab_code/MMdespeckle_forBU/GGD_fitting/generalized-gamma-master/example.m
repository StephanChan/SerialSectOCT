% rng('default'); % For reproduceability.
% 
% pdTrue = GeneralizedGamma(2, 2 ,2);
% n = 1000000;
% sample = pdTrue.drawSample(n); % I/Imean
% 
% slice20=squeeze(ROI_WM(20,:,:));
% m=mean(slice20(:))
% pdEstimated = GeneralizedGamma();
% p = pdEstimated.fitDist(slice20(:)./m)

% pdTrue = GeneralizedGamma(p(1),1/p(2),1);
n = size(slice,1)*size(slice,2);%sum(mask2(:));
sample = gamrnd(p(1),p(2),n,1);%
% sample=pdTrue.drawSample(n); % I/Imean
% [a,b]=my_hist(slice(mask==1)./m,100);
% [c,d]=my_hist(sample,100);
% figure;bar(b,a./max(a));hold on;
% plot(d,c./max(c),'LineWidth',3);
figure;histogram(slice(area==1),100);hold on;histogram(sample,100,'DisplayStyle','Stairs','LineWidth',3);

legend({'true OCT cross pol(not normalized)','Gamma fitting(a=1.86,beta=9.2e-4)'});title('Gamma fitting of 1 plane at deeper grey matter')
xlabel('intensity')
xlim([0,4]);