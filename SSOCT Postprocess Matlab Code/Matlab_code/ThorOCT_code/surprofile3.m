function sur=surprofile(slice,sys)
    % for downsample tiles only
    % volumetric averaging smoothing
    n=3;
    v=ones(3,n,n)./(n*n*3);
    vol=convn(slice,v,'same');

    % define the number of B scans and the maximum possible depth of surface
    sizeY=size(vol,3);
    sizeX=size(vol,2);
    
    % define the starting pixel for surface finding
    if strcmp(sys,'PSOCT')
        start_pxl=6;
    elseif strcmp(sys,'Thorlabs')
        start_pxl=30;
    end
                                            
    % find edge using the first order derivative
    sur=zeros(sizeX,sizeY);
    for k=1:sizeY
        bscan=squeeze(vol(:,:,k));
        for i=1:sizeX
            aline=squeeze(bscan(:,i));
            [m z]=max(aline,[],1);
            z=min(z+30,length(aline));
            if max(aline(start_pxl:end))>1e-4
                loc=findchangepts(aline(start_pxl:z));                                              %changed by stephan on 191128
                loc=loc+start_pxl;
                sur(i,k)=loc;
            else
                sur(i,k)=0;
            end
        end
    end
end
