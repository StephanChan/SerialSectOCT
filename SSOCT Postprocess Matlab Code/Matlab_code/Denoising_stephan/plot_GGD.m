for i=[4 ]
    cross_name=strcat('Pcross',num2str(i),'.mat');
    co_name=strcat('Pco',num2str(i),'.mat');
    ref_name=strcat('Pref',num2str(i),'.mat');

    load(cross_name);
    load(co_name);
    load(ref_name);
% load('P.mat')
    figure(1);plot(1:50,Pco(:,1),'LineWidth',3);hold on;
    figure(1);plot(1:50,Pcross(:,1),'LineWidth',3);hold on;
    figure(1);plot(1:50,Pref(:,1),'LineWidth',3);hold on;
%     figure(2);plot((1:100)*3,Pcross(:,2),'LineWidth',3);hold on;
%     figure(2);plot((1:100)*3,Pco(:,2),'LineWidth',3);hold on;
%     figure(2);plot((1:100)*3,Pref(:,2),'LineWidth',3);hold on;
%     figure(3);plot((1:50)*3,Param_cross(:,3),'LineWidth',3);hold on;
%     figure(3);plot((1:50)*3,Param_co(:,3),'LineWidth',3);hold on;
%     figure(3);plot((1:50)*3,Param_sum(:,3),'LineWidth',3);hold on;
end
figure(1);legend({'co pol^2','cross pol^2','reflectivity^2'});title(strcat('ROI',num2str(i),' alpha'));xlabel('depth(um)')
% saveas(1,strcat('0ROI',num2str(i),' alpha.png'));
% figure(2);legend({'cross pol','co pol','reflectivity'});title('tile18 beta');xlabel('depth(um)')
% figure(3);legend({'cross pol','co pol','reflectivity'});title('tile7 zeta');xlabel('depth(um)')
    