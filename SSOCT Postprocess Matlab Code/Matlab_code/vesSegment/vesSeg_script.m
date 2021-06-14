%% batch job version of vessel segmentation
% Author: Jiarui Yang
% 10/21/20
function[]=vesSeg_script
% add path
addpath '/projectnb/npbssmic/s/Matlab_code/vesSegment';
addpath '/projectnb/npbssmic/s/Matlab_code';

% load volume
vol=TIFF2MAT('/projectnb2/npbssmic/ns/200903_PSOCT_MGH_TDE_test_sample/dist_corrected/volume_ref/roi_fb.tif');
%filename = strcat(datapath,'dist_corrected/volume/ref',num2str(islice),'.mat');
%load(filename);
%Ref=255*(mat2gray(Ref));
%Ref=255-Ref;

% multiscale vessel segmentation
%vol=imresize3(vol,[size(vol,1) size(vol,2) size(vol,3)/5]);
% vol=vol(:,:,43:53);
[~,I_seg]=vesSegment(double(vol),[0.3 0.5], 0.22);

% save segmentation
MAT2TIFF(I_seg,'/projectnb2/npbssmic/ns/200903_PSOCT_MGH_TDE_test_sample/dist_corrected/volume_ref/roi_fb_seg.tif');
% savepath=strcat(datapath,'dist_corrected/volume/ves_seg_',num2str(islice),'.mat');
% save(savepath,'I_seg');
end