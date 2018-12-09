*  Epilepsy Hist-MRI pipelines

# `000_runExHistPipeline`

i  import hist lo-res at .mat files using  02_importHistMatGrayscaleRGB

ii  convert .mat to .nii using 31_genHistspaceFeatureMaps

iii coregister stains (nii inputs) using 30_coregisterStainsToHE, saving transform and reg'd images in coreg dir

iv  apply these xfms to nii images in the grayscale dir using 31_genHistspaceFeatureMaps (which uses flirt)

v  perform ex-hist reg on refstain images using 20_registerHistToMRI

vi  apply transforms using 32_genAlignedFeatureMaps, which uses genAlignedFeatureMap_general.m
	-this function needs:
		- ex-hist reg dir
		- featmap dir, containing regHE files
 	- creates nii images in aligned folder

vii  deformable registration performed with 40_regDeformableStainToAlignedMRI (niftyReg 2D stack wrapper: reg_f3d_split2d)




1. utilize new import scripts, importing into `100um_Grayscale_nii` and `100um_RGB_nii`   (merging i and ii)

2. create an applyStainCoreg script (takes input folder, output folder), should work with 2D+time nii too (new featmaps)

3. make histology processing scripts output nifti/json/tsv instead of .mat files with features, featureVec + extra vars

4. minor edits to genAlignedFeatureMap_general for 

```
sub-XXX
|-tif
 |-SUBJID_STRUCT_##_STAIN.tif
|
|-hist_100um_Grayscale_nii
 |-SUBJID_STRUCT_##_STAIN.nii
|-hist_100um_Grayscale_nii_reg<REFSTAIN>
 |-SUBJID_STRUCT_##_STAIN.nii
|-hist_100um_<featmap>_nii
 |-SUBJID_STRUCT_##_STAIN.nii  
 |-SUBJID_STRUCT_##_STAIN.json #defining what type of features in this 2D+time file
|-hist_100um_<featmap>_nii_reg<REFSTAIN>
|-aligned_<mritype>_100um_STRUCT>_<REFSTAIN>
 |-SUBJID_STRUCT_aligned_<regtype>_<featmap>.nii  
 |-SUBJID_STRUCT_aligned_<regtype>_<featmap>.json  # defining what type of features in 3D+time file
|
|-mri_<STRUCT>
|-mri_aligned_STRUCT_100um

```







