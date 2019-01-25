% generate 100um png and nifti files
function genHistNiftiPngFromThumbnail ( datadir, out_dir, out_res, varargin )


subjs=varargin;


out_res_mm=out_res/1000;



for s=1:length(subjs);
    subj=subjs{s};
    
    histdir=sprintf('%s/%s/tif',datadir,subj);

    niidir=sprintf('%s/%s/%dum_Grayscale_nii',out_dir,subj,out_res);
    pngdir=sprintf('%s/%s/%dum_png',out_dir,subj,out_res);
    niirgbdir=sprintf('%s/%s/%dum_RGB_nii',out_dir,subj,out_res);

    
    mkdir(niidir);
    mkdir(niirgbdir);
    mkdir(pngdir);
    
    
    %should only import tif files that are listed in the
    %orientation.csv
    orientcsv=sprintf('%s/orientation.csv',histdir);
    orient=importdata(sprintf('%s/orientation.csv',histdir));
    orientflags=orient.data;
    tifs=orient.textdata;
    
    for f=1:length(tifs)
        tif=tifs{f};

		
        
        nii_file=sprintf('%s/%s.nii',niidir,tif(1:end-4));
        niirgb_file=sprintf('%s/%s.nii',niirgbdir,tif(1:end-4));

        png_file=sprintf('%s/%s.png',pngdir,tif(1:end-4));
        histFile=sprintf('%s/%s',histdir,tif);
        
       
	% go to next file if it doesn't exist..
        if exist(histFile, 'file') ~= 2
		continue;
	end	
        
        %0.5um/pixel
        hist_res=0.5;
        
        scalefac=out_res./hist_res;
        
        
        imgSizes=getAperioImgSizes(histFile);
        
        ds_size=ceil(imgSizes(1,:)./scalefac);
        Nx=ds_size(1);
        Ny=ds_size(2);
        
        
        imgresolutions=imgSizes(1)./imgSizes(:,1)*hist_res;
        
        %find most appropriately scaled image in bigtiff pyramid
        %[mindiff,whichImg]=min(abs(imgresolutions-res_microns));
        
        %get the thumbnail
        whichImg=2;
        
        disp(sprintf('getting %dum image from %d um tif',out_res,imgresolutions(whichImg)));
        
        img=imread(histFile,whichImg,'PixelRegion',{[1,imgSizes(whichImg,1)],[1,imgSizes(whichImg,2)]});
        img_resized=imresize(img,[Nx,Ny]);
        
        
        imgRot=rotateImgTiffSpaceWithOrient(img_resized,tif,orientcsv);
        
        inplane_mm=out_res/1000;
        
        %save as nifti -- note out of plane resolution fixed by default
        %to 1.0mm
        nii=make_nii(imrotate(double(rgb2gray(imgRot)),-90),[inplane_mm,inplane_mm,1.0],[0,0,0],16);
        
        disp(['saving file: ' nii_file]);
        save_nii(nii,nii_file);
        gzip(nii_file);
        delete(nii_file);
        
        %save PNG
        disp(['saving file: ' png_file]);
        imwrite(imgRot,png_file);
        
        
        %save as rgb nifti:
        
        %   128 Red-Green-Blue            (Use uint8, bitpix=24) % DT_RGB24, NIFTI_TYPE_RGB24
        nii.hdr.dime.datatype=128;
        nii.hdr.dime.bitpix=24;
        
       
        %2d image
        nii.img=imrotate(double(imgRot),-90);
        nii.img=reshape(nii.img,size(nii.img,1),size(nii.img,2),1,3);
        nii.hdr.dime.dim(1)=2; %2d
        nii.hdr.dime.dim(5)=1;
        
                
        disp(['saving file: ' niirgb_file]);
        save_nii(nii,niirgb_file);
        gzip(niirgb_file);
        delete(niirgb_file);
        
        
        
        

    end %exist orientfile
    
end


end
