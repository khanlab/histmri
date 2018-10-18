function reorientVecField ( in_vec_nii, in_xfm_txt, out_vec_nii,do_normalize);

%this can take in flirt xfm or reg_aladin xfm..


%in_vec_nii='dti_sm0.5_V1_regToTfisp.nii.gz';
%in_xfm_txt='flirt_fa-tfisp_reorient.xfm';
%out_vec_nii='dti_sm0.5_V1_regToTfisp_reorientVec.nii.gz';


in_vec=load_nifti(in_vec_nii);
xfm=importdata(in_xfm_txt);
xfm=xfm(1:3,1:3);

in_vec.vol = reorientVecField_mat(in_vec.vol,xfm,do_normalize);
% 
% %mult
% 
% N=numel(in_vec.vol)/3;
% v=zeros(3,N);
% v(1,:)=reshape(in_vec.vol(:,:,:,1),1,N);
% v(2,:)=reshape(in_vec.vol(:,:,:,2),1,N);
% v(3,:)=reshape(in_vec.vol(:,:,:,3),1,N);
% 
% %mat mult
% rv=xfm*v;
% 
% %normalize to unit vectors
% vlen=sqrt(rv(1,:).^2+ rv(2,:).^2+rv(3,:).^2);
% rv(1,:)=rv(1,:)./vlen;
% rv(2,:)=rv(2,:)./vlen;
% rv(3,:)=rv(3,:)./vlen;
% 
% 
% %save out
% for i=1:3
% in_vec.vol(:,:,:,i)=reshape(rv(i,:),size(in_vec.vol,1),size(in_vec.vol,2),size(in_vec.vol,3));
% end


save_nifti(in_vec,out_vec_nii);


end