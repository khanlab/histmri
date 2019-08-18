% generate 100um png and nifti files
function genHistNiftiPngFromThumbnail ( datadir, out_dir, out_res, varargin )

%now uses openslide to query and read the image
% this is the multi-platform loader:
init_openslide;


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
        
        openslidePointer=openslide_open(histFile);

        % mppX                      - Resolution, microns per pixel
        % mppY                      - Resolution, microns per pixel
        % width0                     - Size in pixels
        % height0                    - Size in pixels
        % numberOfLevels            - Number of levels available
        % downsampleFactors         - Downsample factors of the levels available
        % objectivePower            - Magnification factor for level 0
        
        [mppX,mppY,width0,height0,numberOfLevels,...
            downsampleFactors,objectivePower] = ...
            openslide_get_slide_properties(openslidePointer);

        if(mppX ~= mppY) 
            disp(sprintf('cannot proceed with non-square pixels, mppX = %g, mppY = %g',mppX,mppY));
            return;
        end
        
        %was previously hardcoded to 0.5um/pixel
        hist_res=mppX;
        
        scalefac=out_res./hist_res;
        
        
        [level] = openslide_get_best_level_for_downsample(openslidePointer, scalefac);
        
        [width, height] = openslide_get_level_dimensions(openslidePointer, level);

        % openslidePointer          - Pointer to openslide object to read from
        % xPos                      - Pixel position, with first position as 0 and in
        %                             the specified level reference frame
        % yPos                      - Pixel position, with first position as 0 and in
        %                             the specified level reference frame
        % width                     - Widht of region to read in pixels
        % height                    - Height of region to read in pixels
        %
        % OPTIONAL INPUT ARGUMENTS
        % 'level'                   - Image level to read, 0 refers to original
        %                             level
        
        ARGB=openslide_read_region(openslidePointer,0,0,width,height,'level',level);

        
%         imgSizes=getAperioImgSizes(histFile);
        imgSizes=[height0,width0];
        ds_size=ceil(imgSizes./scalefac);
        Nx=ds_size(1);
        Ny=ds_size(2);
        
        
       % imgresolutions=imgSizes(1)./imgSizes(:,1)*hist_res;
        
      
        
      %  disp(sprintf('getting %dum image from %d um tif',out_res,imgresolutions(whichImg)));
        
        img=ARGB(:,:,2:4);
        %imread(histFile,whichImg,'PixelRegion',{[1,imgSizes(whichImg,1)],[1,imgSizes(whichImg,2)]});
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
