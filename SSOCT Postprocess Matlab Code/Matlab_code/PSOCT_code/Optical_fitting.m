function Optical_fitting(I, s_seg, z_seg, datapath, zf)
% Fitting code for the data shared by Hui. 
% I: volume data for 1 tile
% s_seg: slice number
% Z_seg: tile number
% datapath: datapath for original data
% zf: focus depth matrix, X*Y dimension

cd(datapath);
opts = optimset('Display','off','TolFun',1e-10);
v=ones(3,3,3)./27;
I=convn(I,v,'same');
% depth to fit, tunable
fit_depth = round(80); 
% Z step size
Z_step=3.3;
% sensitivity roll-off correction
% w=2.2; % sensitivity roff-off constant, w=2.2 for 5x obj, w=2.22 for 10x obj
% I=rolloff_corr(I,w);

% the following indent lines are trying to find Z start pixel for fitting for
% unflat cut. The start pixel is defined by the average height of tissue
% surface. 
    sur=surprofile(I,'PSOCT');
    aip=squeeze(mean(I,1));
    mask=zeros(size(aip));
    mask(aip>0.06)=1;
    z0=round(mean(sur(mask==1)));
    if isnan(z0)
        z0=41;
    end 
    if z0>55
        z0=55;
    elseif z0<36
            z0=36;
    end
% for flat cut, define a constant depth as start of fitting
% z0=36;
% cut out the signal above tissue surface
I=I(z0:end,:,:);

% correct focus depth accordingly
% zf=zf-z0;
% zf=zf.*Z_step;

% The following indent lines average the whole tile and do a fitting, the purpose here is to find the
% average rayleigh range
%
% Or you can use a constant rayleigh range for all tiles

    mask2=zeros(size(I));
    for i=1:size(I,1)
        mask2(i,:,:)=mask;
    end
    k=mask2.*I;
    % Average attenuation for the full ROI
    mean_I = squeeze(mean(mean(k,2),3));
    mean_I = mean_I - mean(mean_I(end-5:end));
    % mean_I=flip(mean_I);
%     [m,x]=max(mean_I);
%     if x>100
%         x=100;
%     elseif x<20
%         x=20;
%     end
    x=50;
    ydata = double(mean_I(x:end-5)');
    z = (x:(length(ydata)+x-1))*Z_step;
    fun = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*zdata).*(1./(1+((zdata-p(3))./p(4)).^2)));
    lb = [0.00001 0.0001 2*Z_step 60];
    ub = [1 0.03 (x+130)*Z_step 180];
    est = lsqcurvefit(fun,[10 0.01 x*Z_step 30],z,ydata,lb,ub,opts);
     A = fun(est,z);
      % plotting intial fitting
        figure
        plot(z,ydata,'b.')
        hold on
        plot(z,A,'r-')
        xlabel('z (um)')
        ylabel('I')
        title('Four parameter fit of averaged data')
        dim = [0.2 0.2 0.3 0.3];
        str = {'Estimated values: ',['Relative back scattering: ',num2str(est(1),4)],['Scattering coefficient: ',...
            num2str(est(2)*1000,4),'mm^-^1'],['Focus depth: ',num2str(est(3),4),'um'],['Rayleigh estimate: ',num2str(round(est(4)),4),'um']};
        annotation('textbox',dim,'String',str,'FitBoxToText','on');

    %% Curve fitting for the whole image
    res = 10;  %A-line averaging factor
    est_pix = zeros(round(size(I,2)/res),round(size(I,3)/res),3);

    for i = 1:round(size(I,2)/res)
        for j = 1:round(size(I,3)/res)
            area = I(:,(i-1)*res+1:i*res,(j-1)*res+1:j*res);
            int = squeeze(mean(mean(area,2),3));
            int = (int - mean(int(end-5:end-2)));
            [m,xloc]=max(int);
            xloc=x;   % empirical start point of fitting is good enough for flat slice

            if m > 0.001
                ydata = double(int(xloc:end-5)');
                z = (xloc:(length(ydata)+xloc-1))*Z_step;
                fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-p(3))./(est(4))).^2))); % 3-parameter fitting using empirical rayleigh range
    %             fun_pix = @(p,zdata)sqrt(p(1).*exp(-2.*p(2).*(zdata)).*(1./(1+((zdata-est(3))./(est(4))).^2))); % 2-parameter fitting using tile-dependent zf and rayleigh range from above fitting

                % upper and lower bound for fitting parameters
                lb = [0.00001 0.0001 est(3)-30 ];
                ub=[1 0.01 est(3)+30 ];
                est_pix(i,j,:) = lsqcurvefit(fun_pix,[0.001 0.004 est(3)],z,ydata,lb,ub,opts);
            else
                est_pix(i,j,:) = [0 0 0];
            end
        end           
    end


    %% visualization & save

    us = 1000.*squeeze(est_pix(:,:,2));     % unit:mm-1
    savename=strcat('mus-',num2str(s_seg),'-',num2str(z_seg));%['mus_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg),'/',savename, '.mat'],'us');

    ub = squeeze(est_pix(:,:,1));
    savename=strcat('mub-',num2str(s_seg),'-',num2str(z_seg));%['mub_',num2str(s_seg),'_',num2str(z_seg)];
    save([datapath, '/fitting/vol', num2str(s_seg), '/', savename, '.mat'],'ub');