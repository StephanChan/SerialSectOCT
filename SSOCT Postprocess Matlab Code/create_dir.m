function create_dir(nslice,datapath)
%% create folders for each volume during oct processing
% Author: Jiarui Yang
    cd(datapath);
    mkdir aip
    mkdir mip
    for i=1:nslice
        foldername=strcat('vol',num2str(i));
        cd(strcat(datapath,'aip/'));
        mkdir(foldername);
        cd(strcat(datapath,'mip/'));
        mkdir(foldername);
    end
end