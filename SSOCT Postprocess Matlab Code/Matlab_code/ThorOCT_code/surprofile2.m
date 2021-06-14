function sur=surprofile(slice,sys)

    % volumetric averaging smoothing
    n=3;
    v=ones(3,n,n)./(n*n*3);
    vol=convn(slice,v,'same');

    % define the number of B scans and the maximum possible depth of surface
    sizeY=size(vol,3);
    sizeX=size(vol,2);
    
    % define the starting pixel for surface finding
    if strcmp(sys,'PSOCT')
        start_pxl=3;
    elseif strcmp(sys,'Thorlabs')
        start_pxl=30;
    end
                                            
    % find edge using the first order derivative
    ds_factor=10;
    sur=zeros((sizeX/10),round(sizeY/10));
    for k=1:round(sizeY/10)
        bscan=squeeze(vol(:,:,((k-1)*ds_factor+1):(k*ds_factor)));
        for i=1:(sizeX/10)
            aline=squeeze(bscan(:,((i-1)*ds_factor+1):(i*ds_factor),:));
            aline=squeeze(mean(mean(aline,2),3));
            [m,z]=max(aline(start_pxl:end));
            z=min(z+20,size(vol,1)-5);
            if m>0.01
                loc=findchangepts(aline(start_pxl:z));
                loc=loc+start_pxl;
                sur(i,k)=loc;
            else
                sur(i,k)=0;
            end
        end
    end
end
