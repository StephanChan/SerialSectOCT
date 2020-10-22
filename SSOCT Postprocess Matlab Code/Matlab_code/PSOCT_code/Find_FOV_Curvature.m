function Find_FOV_Curvature(folder)
%script for finding FOV curvature
file_dir=folder;
cd(file_dir);
files=dir('*-50-*Mag.dat');
num_files=length(files);

file_split=strsplit(files(1).name,'.');
file_split2=strsplit(string(file_split(1)),'-');
z=str2double(file_split2{3});
x=str2double(file_split2{4})-50;
y=str2double(file_split2{5});
% curvature_A=zeros(x,y);
curvature_B=zeros(x,y);
% C_line_A=zeros(z,x,y);
C_line_B=zeros(z,x,y);
pixel_size_z=3;
pixel_size_x=3;
% A_i=0;
B_i=0;
for i=1:1
    display(strcat("processing: ",files(i).name));
%     file_split=strsplit(files(i).name,'.');
%     file_split2=strsplit(string(file_split(1)),'-');
    fileID = fopen(files(i).name); 
    raw_data = fread(fileID,'float');
    fclose(fileID);
    %y=length(raw_data)/x/z;
%     if string(file_split2(6)) == "A"
%         C_line_A=C_line_A+reshape(raw_data,z,x,y);
%         A_i=A_i+1;
%     else
        C_line_B=C_line_B+reshape(raw_data,z,x,y);
        B_i=B_i+1;
%     end
    
    %clear  raw_data
end

% if A_i>0
%     load(strcat(folder_bg,'\A_mag_bg.mat'));
%     C_line_A=C_line_A/A_i-A_mag;
% end
% 
% if B_i>0
%     load(strcat(folder_bg,'\B_mag_bg.mat'));
%     C_line_B=C_line_B/B_i-B_mag;
% end

%%
% if A_i>0
%     display("Finding curvature for channel A...");
%     [value,z0]=max(C_line_A(1:z,x/2,y/2));
%     for i=1:x
%         for j=1:y
%             m=max(z0-20,0);
%             M=min(z0+20,z);
%             [value,locs] = max(C_line_A(m:M,i,j));
%             curvature_A(i,j)=locs;
%         end
%     end
%     
% end

if B_i>0
    display("Finding curvature for channel B...");
    [value,z0]=max(C_line_B(1:z,x/2,y/2));
    for i=1:x
        for j=1:y
            m=max(z0-19,1);
            M=min(z0+19,z);
            [value,locs] = max(C_line_B(m:M,i,j));
           
            curvature_B(i,j)=locs;
        end
    end

end
%%
% if A_i>0
%     figure;imagesc((1:x)*pixel_size_x,(1:y)*pixel_size_x,curvature_A*pixel_size_z);
%     colorbar;
%     title('PSOCT FOV curvature A(um)');
%     xlabel('X(um)');
%     ylabel('Y(um)');
%     
%     [X,Y] = meshgrid(1:20:x,1:20:y);
%     figure;surf(X*pixel_size_x,Y*pixel_size_x,curvature_A(1:20:x,1:20:y)*pixel_size_z);
%     colorbar;
%     title('PSOCT FOV curvature A(um)');
%     xlabel('X(um) \rightarrow')
%     ylabel('\leftarrow Y(um)')
%     zlabel('Z(um) \rightarrow')
% end
% 
% if B_i>0
% %     figure;imagesc((1:x)*pixel_size_x,(1:y)*pixel_size_x,curvature_B*pixel_size_z);
% %     colorbar;
% %     title('PSOCT FOV curvature B(um)');
% %     xlabel('X(um)');
% %     ylabel('Y(um)');
%     
%     [X,Y] = meshgrid(1:20:x,1:20:y);
%     figure;surf(X*pixel_size_x,Y*pixel_size_x,curvature_B(1:20:x,1:20:y)*pixel_size_z);
%     colorbar;
%     title('PSOCT FOV curvature B(um)');
%     xlabel('X(um) \rightarrow')
%     ylabel('\leftarrow Y(um)')
%     zlabel('Z(um) \rightarrow')
% end
% %%
% 
%fitting
format long
[X Y] = meshgrid(1:x,1:y);
XY(:,:,1)=X;
XY(:,:,2)=Y;
% Create Objective Function: 
surfit = @(B,XY)  B(6)+B(1)*XY(:,:,1)+B(2)*XY(:,:,2)+B(3).*(XY(:,:,1)).^2 + B(4).*(XY(:,:,2)).^2+B(5).*XY(:,:,1).*XY(:,:,2); 
% surfit = @(B,XY)  exp(B(1).*XY(:,:,1)) + (1 - exp(B(2).*XY(:,:,2))); 
% Do Regression
B = lsqcurvefit(surfit, [ 0.1 0.1 0.00001 -0.00001  0.0001 45], XY, curvature, [-1 -1 0.00001 -0.001 -0.0001 0],  [1 1 0.001 -0.00001 0.0001 100])
% Calculate Fitted Surface
%%
Z = surfit(B,XY); 
% 
% % Plot: 
% X_=1:20:x;
% Y_=1:20:x;
% [X,Y]=meshgrid(X_,Y_);
% figure;
% surf(X*pixel_size_x, Y*pixel_size_x, Z(X_,Y_)*pixel_size_z)                           % Fitted Surface
% colorbar;
% xlabel('X(um) \rightarrow')
% ylabel('\leftarrow Y(um)')
% zlabel('Z(um) \rightarrow')
% title('fitting of FOV curvature')
% grid
% %%
% %calculate residual
% residual=curvature-Z;
% figure;
% imagesc(1:x*pixel_size_x,1:x*pixel_size_x,residual*pixel_size_z) ;
% colorbar;
% xlabel('X(um) \rightarrow')
% ylabel('\leftarrow Y(um)')
% caxis([-4,6]);
% colorbar;
% %zlabel('Z(um) \rightarrow')
% title('residual of fitting')
% % %%
% % format long
% % line=curvature(100,:);
% % func=@(k,x) k(1)+k(2).*(x-k(3)).^k(4);
% % K=lsqcurvefit(func,[10 0.01 600 2],1:1200,line, [0 0.00001 0 1.000001],[100 1 1200 2])
% % %%
% % scatter(1:1200,line);
% % hold on;
% % fitted=func(K,1:1200);
% % plot(1:1200,fitted)
% if A_i>0
%     %smooth curvature
%     [B,surfit]=Fit_curvature(x,y,curvature_A);
%     [X, Y] = meshgrid(1:x,1:y);
%     clear XY
%     XY(:,:,1)=X;
%     XY(:,:,2)=Y;
%     curvature_A=round(surfit(B,XY));
%     curvature_A=curvature_A-min(min(curvature_A));
%     save('curvature_A.mat','curvature_A');
% end

if B_i>0
    %smooth curvature
    [B,surfit, residual]=Fit_curvature(x,y,curvature_B);
    [X, Y] = meshgrid(1:x,1:y);
    clear XY
    XY(:,:,1)=X;
    XY(:,:,2)=Y;
    curvature_B=round(surfit(B,XY));
    curvature_B=curvature_B-min(min(curvature_B));
    figure;imagesc(curvature_B)
    save('curvature_B.mat','curvature_B');
end