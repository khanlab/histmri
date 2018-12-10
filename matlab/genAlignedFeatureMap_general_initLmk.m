% transform feature map 100 um niftis to 3D nifti's in aligned space

function genAlignedFeatureMap_general(data_dir,subj, struct,  stain,in_dir,out_dir,out_name,res_um);

%featuredir is where reg niftis exist

resetvol=0;


%get resolution from input image
%res_um=100;
 

    res_mm=res_um/1000;


reg_dir=sprintf('%s/%s/mri_hist_reg_initLmk_%s_%dum',data_dir,subj,struct,res_um);


%first, load up hist stack image to determine # of slices and slice spacing
hist_stack_nii=sprintf('%s/images/hist_stack.nii.gz',reg_dir);
hdr=load_nifti(hist_stack_nii,1);
hist_stack_sform=hdr.sform;


%background colour in hist
histfillval=0;

nslices=hdr.dim(4);
slicespacing=hdr.pixdim(4);



%  ----- here we get nifti's instead..

%coreg_dir=sprintf('~/epilepsy/local_data/GenPosPixMaps/%s/%dum_PoxPixMap',subj,res_um);
coreg_dir=sprintf('%s',in_dir);


slice_dir=sprintf('%s/slices',out_dir);

mkdir(out_dir);
mkdir(slice_dir);



for slice=1:nslices
    
    
     coreg_nii=sprintf('%s/%s_%s_%03d_%s_regHE.nii.gz',coreg_dir,subj,struct,slice,stain);

    if (~exist(coreg_nii))
             coreg_nii=sprintf('%s/%s_%s_%03d_%s.nii.gz',coreg_dir,subj,struct,slice,stain);
        if ( ~exist(coreg_nii))
            continue;
        end
    end
       
 %   hist_png=permute(flipdim(flipdim(imread(in_pngs{st}),1),2),[2,1,3]);
    hist_nii=load_nifti(coreg_nii);
    
    hist_png=flipdim(hist_nii.vol,1);
    
    
    %
    
    histaligned_xfm=sprintf('%s/final_xfm/hist-aligned_slice_%03d.xfm',reg_dir,slice);
 
     %this hist aligned xfm is essentially 2D -- z dim is just translation
 xfm_ha=importdata(histaligned_xfm);
 
%load up 2d hist (nii for now)..
%in_hist_nii='~/epilepsy/local_data/ex-hist-registration_nii/EPI_P040/Processed/Ex-Hist_Reg/9.4T/Neo/images/hist_slice_5.nii.gz';

%in_hist=load_nifti(in_hist_nii);
%size(in_hist.vol)
%vox2ras=in_hist.vox2ras
vox2ras_png=eye(4,4);
vox2ras_png(1,1)=res_mm;
vox2ras_png(2,2)=res_mm;
vox2ras_png(3,3)=res_mm;


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

A=permute(hist_png,[2,1,3]);
%A=hist_png;

[B,out_xdata,out_ydata]=imtransform(A,T,'nearest','UData',udata,'VData',vdata,'XData',xdata,'YData',ydata,'XYScale',[res_mm,res_mm],'FillValues',histfillval);

B=permute(B,[2,1,3]);


if(resetvol~=1 )
    
    rgbout=histfillval.*ones(size(B,1),size(B,2),nslices);
    resetvol=1;
end

    
rgbout(:,:,nslices-slice+1)=B;

rgbslice=zeros(size(B,1),size(B,2),1);
rgbslice(:,:,1)=B;


temp=make_nii(rgbslice,[res_mm,res_mm,slicespacing],[0,0,0]);
temp.hdr.hist.srow_x=histref_hdr.srow_x';
temp.hdr.hist.srow_y=histref_hdr.srow_y';
temp.hdr.hist.srow_z=histref_hdr.srow_z';
%correct in-slice voxel resolution in sform:
temp.hdr.hist.srow_x(1)=res_mm;
temp.hdr.hist.srow_z(2)=res_mm;

temp.hdr.hist.qform_code=0;
temp.hdr.hist.sform_code=1;



save_nii(temp,sprintf('%s/%s_rigid_%dum_slice_%03d.nii',slice_dir,stain,res_um,slice));



end




%get ref for sform vol:
histvol=sprintf('%s/3drigid_iter5/hist_stack_reg.nii.gz',reg_dir);
histvolref_hdr=load_nifti(histvol,1);

        
temp=make_nii(rgbout,[res_mm,res_mm,slicespacing],[0,0,0]);
%temp.hdr.dime.datatype=128;
%temp.hdr.dime.bitpix=24;
temp.hdr.hist.srow_x=histvolref_hdr.srow_x';
temp.hdr.hist.srow_y=histvolref_hdr.srow_y';
temp.hdr.hist.srow_z=histvolref_hdr.srow_z';

%correct in-slice voxel resolution in sform:
temp.hdr.hist.srow_x(1)=res_mm;
temp.hdr.hist.srow_z(2)=res_mm;


temp.hdr.dime.xyzt_units=18;

temp.hdr.hist.qform_code=0;
temp.hdr.hist.sform_code=1;

save_nii(temp,sprintf('%s/%s_rigid_%dum.nii',out_dir,out_name,res_um));
gzip(sprintf('%s/%s_rigid_%dum.nii',out_dir,out_name,res_um));
delete(sprintf('%s/%s_rigid_%dum.nii',out_dir,out_name,res_um));

    


end


