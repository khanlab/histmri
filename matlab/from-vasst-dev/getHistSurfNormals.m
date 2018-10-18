function getHistSurfNormals ( in_vtk, boundary_nii, out_nii);

%vtk='/home/ROBARTS/alik/EpilepsyDatabase/EPI_P027/Processed/Ex-Hist_Reg/9.4T/Neo/3drigid_iter5/Ex_aligned_pv.vtk';
%boundary_nii='/home/ROBARTS/alik/EpilepsyDatabase/EPI_P027/Processed/Ex-Hist_Reg/9.4T/Neo/3drigid_iter5/mask_boundary.hist.nii.gz';
%out_nii='/home/ROBARTS/alik/EpilepsyDatabase/EPI_P027/Processed/Ex-Hist_Reg/9.4T/Neo/3drigid_iter5/mask_boundary.hist.surfNormError.nii.gz';

hist=load_nifti(boundary_nii);
[mr_pts,mr_nrmls]=getPointsNormalsVTK(in_vtk);
inds=find(hist.vol>0.5);

[coord_i,coord_j,coord_k]=ind2sub(size(hist.vol),inds);
coord=[coord_i';coord_j';coord_k'];

%here just one coord for example.. can get ROI for this or bdy voxels..
%coord=[61,212,5]';


coord=coord-1; %since indexed from 0

phys=hist.sform*[coord;ones(1,size(coord,2))];



%find closest points from phys coords on hist to Ex MRI surface
mapToMR=zeros(size(coord,2),1);
distToMR=zeros(size(coord,2),1);

for i=1:size(coord,2)
    
%find nearest point on surface
d=repmat(phys(1:3,i),1,size(mr_pts,2))-mr_pts;
dist=sqrt(dot(d,d,1));
[distToMR(i),mapToMR(i)]=min(dist);

end



%normal vectors from closest point on MR surface
pial_mrnormals=mr_nrmls(:,mapToMR);
slicenorms=zeros(size(coord));

for i=1:size(phys,2)
slicenorm=hist.sform*[0; 0; coord(3,i)+1; 1]  - hist.sform*[0; 0; coord(3,i); 1];
slicenorms(:,i)=slicenorm(1:3)/norm(slicenorm(1:3));
end



pial_norm_endpts=zeros(size(pial_mrnormals,2),2);
oop_angle=zeros(size(pial_mrnormals,2),1);
for i=1:size(pial_mrnormals,2)
    
pialnorm=pial_mrnormals(:,i);
slicenorm=slicenorms(:,i);

%angle between these:
anglerad=atan2(norm(cross(pialnorm,slicenorm)),dot(pialnorm,slicenorm));
oop_angle(i)=abs(90-anglerad*180/pi);

end

img_oop=hist;
img_oop.vol(inds)=oop_angle;

save_nifti(img_oop,out_nii);

%compute projection of pialnorm onto slice plane in 3D, 
%then bring that back to 2D space
%projpial=-pialnorm-dot(-pialnorm,slicenorm)*slicenorm;

%projpial is wrt a point
%pial_path_mr3D(:,i);

%projpial_hist=inv(histxfm)*[pial_path_mr3D(:,i), pial_path_mr3D(:,i)+[projpial;0] ];
%pial_norm_endpts(i,:)=projpial_hist(1:2,2)'-projpial_hist(1:2,1)';

