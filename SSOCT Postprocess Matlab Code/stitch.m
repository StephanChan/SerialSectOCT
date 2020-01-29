clear all;

block=zeros(1280,1280);

path='C:/Users/jryang/Desktop/Vibratome_data/0823blockface/';

% overlap rate
overlap = 0.3;

% initiate registration
ini=1;
flag=1;
optimizer = registration.optimizer.RegularStepGradientDescent;
optimizer.MinimumStepLength = 5e-3;
metric = registration.metric.MeanSquares;
            
for i=1%:4
    
    for j=1:2
        % load data and get dimension information
        filepath=strcat(path,num2str(i),'-',num2str(j));
        cd(filepath);
        load data.mat;
        dim=size(slice);
        
        % first tile, skip registration
        if ini==1
            ref=slice;
            reg_tile=slice;
            ini=0;
        end
        
        if j>1
            % registration based stitching
            tform = imregtform(slice(:,1:dim(1)*overlap,:),ref(:,dim(1)*(1-overlap)+1:end,:),'translation',optimizer,metric);
            reg_tile = imwarp(slice,tform);
        end
        
        % plot MIP for each tile
        refmap=squeeze(max(ref(1:200,:,:),[],1));
        map=squeeze(max(reg_tile(1:200,:,:),[],1));
        figure;imagesc(map);colorbar;colormap gray;
        
        if j==1
            % alignment of tiles
            block(1:400,400*(i-1)+1:400*i)=map;
        else
            % overlapping band
            block((dim(1)*(1-overlap))*(j-1)+1:(dim(1)*(1-overlap))*(j-1)+dim(1)*overlap,400*(i-1)+1:400*i)=max(map(1:overlap*dim(1),:),refmap((1-overlap)*dim(1)+1:end,:));
            % new tile
            block((dim(1)*(1-overlap))*(j-1)+dim(1)*overlap+1:(dim(1)*(1-overlap))*j+overlap*dim(1),400*(i-1)+1:400*i)=map(overlap*dim(1)+1:end,:);
        end
        
        % update reference
        ref=slice;
    end
end



figure;imagesc(block(1:680,1:400));colormap gray;caxis([100 50000]);title('MIP of 4x4 image tiles');...
    ylabel('Y axis (pxl)');xlabel('X axis (pxl)');

% aline profile
figure;plot(log2(movmean(slice(:,100,300),5)));xlabel('depth index(pxl)');ylabel('log intensity');title('A-line profile');
