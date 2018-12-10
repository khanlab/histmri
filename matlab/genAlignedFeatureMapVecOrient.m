
% transform feature map 100 um niftis to 3D nifti's in aligned space
function genAlignedFeatureMapVecOrient(data_dir,subj, struct, session,stain,in_dir,out_dir,out_name)

%featuredir is where reg niftis exist

resetvol=0;

png_res=100;
 

    png_res_mm=png_res/1000;

%line below for testing
%subj='EPI_P040'; struct='Neo'; session='9.4T'; png_res=100;
reg_dir=sprintf('%s/%s/%s/%s',data_dir,subj,session,struct);


%first, load up hist stack image to determine # of slices and slice spacing
hist_stack_nii=sprintf('%s/images/hist_stack.nii.gz',reg_dir);
hdr=load_nifti(hist_stack_nii,1);
hist_stack_sform=hdr.sform;


%background colour in hist
histfillval=0;

nslices=hdr.dim(4);
slicespacing=hdr.pixdim(4);




%  ----- here we get nifti's instead..

%coreg_dir=sprintf('~/epilepsy/local_data/GenPosPixMaps/%s/%dum_PoxPixMap',subj,png_res);
coreg_dir=sprintf('%s',in_dir);

slice_dir=sprintf('%s/slices',out_dir);

mkdir(out_dir);
mkdir(slice_dir);



for slice=1:nslices
    
    
     coreg_nii=sprintf('%s/%s_%s_%02d_%s_regHE.reoriented.nii.gz',coreg_dir,subj,struct,slice,stain);
    
     if (~exist(coreg_nii))
	continue;
    end
  
        
            
        
 %   hist_png=permute(flipdim(flipdim(imread(in_pngs{st}),1),2),[2,1,3]);
    hist_nii=load_nifti(coreg_nii);
    
    hist_png=flipdim(hist_nii.vol,1);
    
    
    %
    
    histaligned_xfm=sprintf('%s/final_xfm/hist-aligned_slice_%02d.xfm',reg_dir,slice);
 
     %this hist aligned xfm is essentially 2D -- z dim is just translation
 xfm_ha=importdata(histaligned_xfm);
 
%load up 2d hist (nii for now)..
%in_hist_nii='~/epilepsy/local_data/ex-hist-registration_nii/EPI_P040/Processed/Ex-Hist_Reg/9.4T/Neo/images/hist_slice_5.nii.gz';

%in_hist=load_nifti(in_hist_nii);
%size(in_hist.vol)
%vox2ras=in_hist.vox2ras
vox2ras_png=eye(4,4);
vox2ras_png(1,1)=png_res_mm;
vox2ras_png(2,2)=png_res_mm;
vox2ras_png(3,3)=png_res_mm;


%load up ref slice:
refslice=nslices-slice;
histslice=sprintf('%s/3drigid_iter5/slices/hist_%04d.nii.gz',reg_dir,refslice);
histref_hdr=load_nifti(histslice,1);
vox2ras_ref=histref_hdr.vox2ras;


%can use vox2ras to go from vox indices (0 to size-1) to phys dim
I=eye(4,4);
xfm3dto2d=I;
xfm3dto2d(3,:)=I(2,:);
xfm3dto2d(2,:)=I(3,:);


in_coord_begin=[0;0;0;1];
in_coord_end=[size(hist_png,1)-1;size(hist_png,2)-1;0;1];

%get input coords in phys space (begin to end)
in_coords_phys=vox2ras_png*[in_coord_begin, in_coord_end];

%get output coords in phys space (begin to end)
out_coord_begin=[0;0;0;1];
out_coord_end=[histref_hdr.dim(2:4)-1;1];
out_coords_phys=xfm3dto2d*vox2ras_ref*[out_coord_begin, out_coord_end];
 
udata=in_coords_phys(1,:);
vdata=in_coords_phys(2,:);

xdata=out_coords_phys(1,:);
ydata=out_coords_phys(2,:);


%make output pix dim same as png
%out_size=size(histref_hdr.vol);

% for imtransform -- X and Y are reversed!


%create 2d xfm
transform=xfm3dto2d*inv(xfm_ha);
transform(3,:)=[];
transform(:,3)=[];

T=maketform('affine',transform');

%A=permute(hist_png,[2,1,3]);

A=permute(hist_png,[2,1,4,3]);

%A=hist_png;

[B,out_xdata,out_ydata]=imtransform(A,T,'nearest','UData',udata,'VData',vdata,'XData',xdata,'YData',ydata,'XYScale',[png_res_mm,png_res_mm],'FillValues',histfillval);

%B=permute(B,[2,1,3]);

B=permute(B,[2,1,4,3]);

%negate x
B(:,:,:,1)=-B(:,:,:,1);

%need to reorientvectors
B=reorientVecField_mat(B,transform,1);

if(resetvol~=1 )
    rgbout=histfillval.*ones(size(B,1),size(B,2),nslices,1,3);
    resetvol=1;
end

    
    for vecd=1:3
 rgbout(:,:,nslices-slice+1,vecd)=B(:,:,:,vecd);
    end



end




%get ref for sform vol:
histvol=sprintf('%s/3drigid_iter5/hist_stack_reg.nii.gz',reg_dir);
histvolref_hdr=load_nifti(histvol,1);


       
temp=make_nii(squeeze(rgbout(:,:,:,1,1)),[png_res_mm,png_res_mm,slicespacing],[0,0,0]);
%temp.hdr.dime.datatype=128;
%temp.hdr.dime.bitpix=24;


temp.hdr.dime.dim(1)=4;
temp.hdr.dime.dim(5)=3;
temp.img=squeeze(rgbout(:,:,:,1,:));





temp.hdr.hist.srow_x=histvolref_hdr.srow_x';
temp.hdr.hist.srow_y=histvolref_hdr.srow_y';
temp.hdr.hist.srow_z=histvolref_hdr.srow_z';

%correct in-slice voxel resolution in sform:
temp.hdr.hist.srow_x(1)=png_res_mm;
temp.hdr.hist.srow_z(2)=png_res_mm;

temp.hdr.hist.qform_code=0;
temp.hdr.hist.sform_code=1;

%needed for freesurfer save_nifti/load_nifti, else will scale vox dims by
%1e10 !!

temp.hdr.dime.xyzt_units=18;

save_nii(temp,sprintf('%s/%s_rigid_%dum.nii',out_dir,out_name,png_res));
gzip(sprintf('%s/%s_rigid_%dum.nii',out_dir,out_name,png_res));
delete(sprintf('%s/%s_rigid_%dum.nii',out_dir,out_name,png_res));

    
    


end


