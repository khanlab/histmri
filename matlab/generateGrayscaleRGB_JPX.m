function  generateGrayscaleRGB_JPX(data_dir,subj,strct,stain_type,res_microns,out_dir)
%subj,specimen,slice,stain)

pad_microns=0;

%loop through
jpx_files=dir(sprintf('%s/%s/jpx/%s_%s_*_%s.jpx',data_dir,subj,subj,strct,stain_type));

for f=1:length(jpx_files)
    
    jpx=sprintf('%s/%s',jpx_files(f).folder,jpx_files(f).name);
    
    %by default, use legacy naming (100um_FeatureMaps)
    out_name=sprintf('%dum',res_microns);
    
    
    [~,name,~]=fileparts(jpx);
        
    
    outdir_gray=sprintf('%s/%s/%s_Grayscale',out_dir,subj,out_name);
    outdir_rgb=sprintf('%s/%s/%s_RGB',out_dir,subj,out_name);
    mkdir(outdir_gray);
    mkdir(outdir_rgb);
    
    
    outmap_gray=sprintf('%s/%s.mat',outdir_gray,name);
    outmap_rgb=sprintf('%s/%s.mat',outdir_rgb,name);
    
    
    %0.5um/pixel
%    hist_res=0.5;
    
%    scalefac=res_microns./hist_res;
    
    
    imgSizes=getAperioImgSizes(jpx);
    
    %2^(reduction_level) downsampling
    reduction_level=7;
    scalefac=2.^reduction_level;
    
    
  %  ds_size=ceil(imgSizes(1,:)./scalefac);
   
    
 %   imgresolutions=imgSizes(1)./imgSizes(:,1)*hist_res;
    
%     if res_microns>=100
%         whichImg=2;
%     else
%         %find most appropriately scaled image in bigjpxf pyramid
%         [mindiff,whichImg]=min(abs(imgresolutions-res_microns));
%     end
%     
    
    
    %img=imread(jpx,whichImg,'PixelRegion',{[1,imgSizes(whichImg,1)],[1,imgSizes(whichImg,2)]});
    img_resized=imread(jpx,'ReductionLevel',reduction_level);
    %img_resized=imresize(img,[Nx,Ny]);
    ds_size=size(img_resized);
     Nx=ds_size(1);
    Ny=ds_size(2);
    
    
    
    
    features={'grayscale'};
    featureVec=double(rgb2gray(img_resized));
    save(outmap_gray,'featureVec','features','pad_microns','res_microns');
    
    
    features={'red','green','blue'};
    
    featureVec=double(img_resized);
    save(outmap_rgb,'featureVec','features','pad_microns','res_microns');
    
    
    
    %
    % orientcsv=sprintf('%s/orientation.csv',path);
    %
    %
    %
    % outdir=sprintf('%s/histspace/%s',outdir_gray);
    % mkdir(outdir);
    %
    % featRot=rotateImgjpxfSpaceWithOrient(featureVec,jpx,orientcsv);
    % inplane_mm=res_microns/1000;
    %
    % %save as nifti
    % thickness=5; %5mm
    % nii=make_nii(imrotate(featRot,-90),[inplane_mm,inplane_mm,4.4],[0,0,0],16);
    %
    % niifile=sprintf('%s/%s.nii',outdir_gray,name);
    % save_nii(nii,niifile);
    % gzip(niifile);
    % delete(niifile);
    
end

end
