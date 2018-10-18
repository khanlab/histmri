function  generateGrayscaleRGB(data_dir,subj,strct,stain_type,res_microns,out_dir)
%subj,specimen,slice,stain)

pad_microns=0;

%loop through
tif_files=dir(sprintf('%s/%s/tif/%s_%s_*_%s.tif',data_dir,subj,subj,strct,stain_type));

for f=1:length(tif_files)
    
    tif=sprintf('%s/%s',tif_files(f).folder,tif_files(f).name);
    
    %by default, use legacy naming (100um_FeatureMaps)
    out_name=sprintf('%dum',res_microns);
    
    
    [~,name,~]=fileparts(tif);
        
    
    outdir_gray=sprintf('%s/%s/%s_Grayscale',out_dir,subj,out_name);
    outdir_rgb=sprintf('%s/%s/%s_RGB',out_dir,subj,out_name);
    mkdir(outdir_gray);
    mkdir(outdir_rgb);
    
    
    outmap_gray=sprintf('%s/%s.mat',outdir_gray,name);
    outmap_rgb=sprintf('%s/%s.mat',outdir_rgb,name);
    
    
    %0.5um/pixel
    hist_res=0.5;
    
    scalefac=res_microns./hist_res;
    
    
    imgSizes=getAperioImgSizes(tif);
    
    
    ds_size=ceil(imgSizes(1,:)./scalefac);
    Nx=ds_size(1);
    Ny=ds_size(2);
    
    
    imgresolutions=imgSizes(1)./imgSizes(:,1)*hist_res;
    
    if res_microns>=100
        whichImg=2;
    else
        %find most appropriately scaled image in bigtiff pyramid
        [mindiff,whichImg]=min(abs(imgresolutions-res_microns));
    end
    
    
    
    img=imread(tif,whichImg,'PixelRegion',{[1,imgSizes(whichImg,1)],[1,imgSizes(whichImg,2)]});
    img_resized=imresize(img,[Nx,Ny]);
    
    
    
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
    % featRot=rotateImgTiffSpaceWithOrient(featureVec,tif,orientcsv);
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
