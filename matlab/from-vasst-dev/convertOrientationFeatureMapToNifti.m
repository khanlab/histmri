function convertOrientationFeatureMapToNifti( feat_name, orient_variable_names, tif )


%tif='/media/Histology/Histology/EPI_P040/tif/EPI_P040_Neo_06_NEUN.tif';


[path,name,ext]=fileparts(tif);

%mat file:
featdir=sprintf('%s/../%s',path,feat_name);
featmap=sprintf('%s/%s.mat',featdir,name);

load(featmap);


for f=1:length(orient_variable_names)
    

orientAngle=featureVec(:,:,strcmp(features,orient_variable_names{f}));
featname=sprintf('vector_%s',orient_variable_names{f});

orientcsv=sprintf('%s/orientation.csv',path);
    
outdir=sprintf('%s/histspace/%s',featdir,featname);
mkdir(outdir);


orientAngle(orientAngle>90)=orientAngle(orientAngle>90)-180;

orientVector_u=zeros(size(orientAngle,1),size(orientAngle,2));
orientVector_v=zeros(size(orientAngle,1),size(orientAngle,2));

orientVector_u=cos(orientAngle.*pi./180);
orientVector_v=sin(orientAngle.*pi./180);
orientVector_u(orientAngle==0)=0;
orientVector_v(orientAngle==0)=0;

%figure; quiver(flipud(orientVector_u),flipud(orientVector_v));

orientVector=zeros(size(orientAngle,1),size(orientAngle,2),3);
orientVector(:,:,1)=orientVector_u;
orientVector(:,:,2)=orientVector_v;

%featRot=rotateImgTiffSpaceWithOrient(featureVec(:,:,i),tif,orientcsv);

featRot=rotateVectorImgTiffSpaceWithOrient(orientVector,tif,orientcsv);

%rotAngle=imrotate(orientAngle,-90);

%save as nifti
%nii=make_nii(imrotate(featRot,-90),[0.1,0.1,4.4],[0,0,0],16);
nii=make_nii(featRot(:,:,1),[0.1,0.1,1],[0,0,0],16);

niifile=sprintf('%s/%s.nii',outdir,name);

nii.hdr.dime.dim(1)=4;
nii.hdr.dime.dim(5)=3;

nii.img=single(zeros(size(featRot,1),size(featRot,2),3));

%nii.img(:,:,2)=imrotate(orientVector_u,-90);
%nii.img(:,:,1)=imrotate(orientVector_v,-90);
%nii.img(:,:,3)=imrotate(zeros(size(orientVector_u)),-90);
%nii.img(:,:,3)=rotAngle;

nii.img(:,:,2)=-featRot(:,:,1);  % not sure why the x needs to be flipped here, it just does! (perhaps nifti thing..)
nii.img(:,:,1)=featRot(:,:,2);
nii.img(:,:,3)=featRot(:,:,3);

save_nii(nii,niifile);
gzip(niifile);
delete(niifile);

end


end
