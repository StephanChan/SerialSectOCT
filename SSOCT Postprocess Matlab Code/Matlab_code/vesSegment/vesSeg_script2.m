%% batch job version of vessel segmentation
% Author: Jiarui Yang
% 10/21/20

% add path
addpath '/projectnb/npbssmic/s/Matlab_code/vesSegment';
addpath '/projectnb/npbssmic/s/Matlab_code';

% load volume
vol=TIFF2MAT('/projectnb2/npbssmic/ns/201028_PSOCT_Ann_7688/dist_corrected/volume/ref_sub_invert.tif');

% multiscale vessel segmentation
%vol=imresize3(vol,[size(vol,1) size(vol,2) size(vol,3)/5]);
%vol=vol(:,:,1:220);
[I_VE,I_seg]=vesSegment(double(vol),[0.1 0.2 0.5 1 2], 0.18);
MAT2TIFF(I_seg,'/projectnb2/npbssmic/ns/201028_PSOCT_Ann_7688/dist_corrected/volume/I_seg_sub.tif');
% save('/projectnb2/npbssmic/ns/190619_Thorlabs/nii/I_VE.mat',I_VE);