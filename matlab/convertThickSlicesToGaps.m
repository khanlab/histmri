function convertThickSlicesToGaps (in_thick_nii,in_thin_nii,out_gap_nii);
%given a thick slice image (in z dim) and a resampled image


% 
% in_thick_nii='test_hist_thick.nii.gz'
% in_thin_nii='test_hist_thin.nii.gz'
% out_gap_nii='test_hist_gap.nii.gz'


thin_nii=load_nifti(in_thin_nii);
thick_nii=load_nifti(in_thick_nii);

N=size(thin_nii.vol,3);
M=size(thick_nii.vol,3);
indices=round(1:(N/M):N);

fillval=0;
out_vol=fillval.*ones(size(thin_nii.vol));
out_vol(:,:,indices)=thin_nii.vol(:,:,indices);

thin_nii.vol=out_vol;
save_nifti(thin_nii,out_gap_nii);
