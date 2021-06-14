function[]=Save_png(slice,m,p,my_title)
n = 300*300*50;
% sample = gamrnd(p(1),p(2),n,1);
pdTrue = GeneralizedGamma(p(1), p(2) ,p(3));
sample = pdTrue.drawSample(n);
figure;histogram(area_co(:),100);hold on;histogram(sample,100,'DisplayStyle','Stairs','LineWidth',3);
legend({'true OCT','Gamma fitting'});title(my_title)
xlabel('normalized intensity')
xlim([0,4]);