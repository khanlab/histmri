% generate 100um png and nifti files
function genHistNiftiPng ( datadir, out_res, varargin )


%addpath('~/epilepsy/shared_data/scripts/histology');

%datadir='/media/Histology/Histology';
subjs=varargin;


%only generate 2um pngs for NEUN
%resolutions={100,20,2}; %100
%nii or png?
%stain?
%resolution?

%100 -> all stains, all formats
%higher res: only pngs, NEUN/GFAP

%resolutions={2,100,10};

%for res=1:length(resolutions)
    
%    out_res=resolutions{res};
    
    out_res_mm=out_res/1000;
    
    
    for s=1:length(subjs);
        subj=subjs{s};
        
        histdir=sprintf('%s/%s/tif',datadir,subj);
        niidir=sprintf('%s/%s/%dum_nii',datadir,subj,out_res);
        pngdir=sprintf('%s/%s/%dum_png',datadir,subj,out_res);
        
        mkdir(niidir);
        mkdir(pngdir);
        
        
        %should only import tif files that are listed in the
        %orientation.csv
        
        orient=importdata(sprintf('%s/orientation.csv',histdir));
        orientflags=orient.data;
        tifs=orient.textdata;
        
        for f=1:length(tifs)
            tif=tifs{f};
            
                   
            nii_file=sprintf('%s/%s.nii',niidir,tif(1:end-4));            
            png_file=sprintf('%s/%s.png',pngdir,tif(1:end-4));            
            histFile=sprintf('%s/%s',histdir,tif);
           

%	proceed=false;
proceed=true;

	%for 100um convert 	
%	if (out_res ==100 )
%            if ( ~ exist(nii_file,'file') || ~ exist(png_file,'file') )
%		proceed =true;
%		end
%	else
%		if ( ~exist(png_file,'file') )
%			proceed=true;
%		end
%	end

	%for 2um only convert non-HE stained slides

%	   if (out_res==2) %if out res ==2, 
%                if (isempty(strfind(tif,'HE')))  %if not NEUN then continue out
%                proceed=true;
%		else
%		proceed=false;
%                end
%            end



        if ( proceed )
                
                %read in tif
             %   imgSizes=mexAperioTiff(histFile);
                imgSizes=getAperioImgSizes(histFile);

                
                origvox=[0.0005,0.0005];
                
                %get img pyramid resolutions
                imgresolutions=imgSizes(1)./imgSizes(:,1).*origvox(1);
                
                
                %pull out 2um image
                res_2um=2e-3;
                 
             
                    
                tolerance=1e-6; %resolution will be close to desired but not exactl
                whichImg=find(abs(imgresolutions-res_2um)<tolerance);
                                    disp(['loading file: ' histFile]);
                     
                %if 2um image does not exist (happens sometimes for small
                % images)
                if (isempty(whichImg))
                    %load up next highest resolution image
                    chosen_res=max(imgresolutions(imgresolutions<res_2um));
                    whichImg=find(imgresolutions==chosen_res);
                end              

                %whichImg = size(imgSizes,1)-1;
                %img=mexAperioTiff(histFile,whichImg,1,imgSizes(whichImg,1),1,imgSizes(whichImg,2));
                img=imread(histFile,whichImg,'PixelRegion',{[1,imgSizes(whichImg,1)],[1,imgSizes(whichImg,2)]});

                %flip according to orientation
                
                % Legend of Orientation positions:
                % 1- 0 DEGREES
                % 2- 90 DEGREES RIGHT
                % 3- 180 DEGREES
                % 4- 90 DEGREES LEFT
                % 5- FLIPPED VERTICALLY
                % 6- 90 DEGREES RIGHT AND FLIPPED vertically
                % 7- FLIPPED HORIZONTALLY
                % 8- 90 DEGREES LEFT AND FLIPPED vertically
                
                
                switch orientflags(f)
                        case 1
                            imgRot=img;
                        case 2
                            % 90 deg right
                            imgRot=imrotate(img,-90);
                        case 3
                            % 180 degmexAperioTiff
                            imgRot=imrotate(img,180);
                        case 4
                            % 90 deg left
                            imgRot=imrotate(img,90);
                        case 5
                            % flip vertical
                            imgRot=img(end:-1:1,1:1:end,:);
                        case 6
                            % 90 deg right then flipped vert
                            imgRot=imrotate(img,-90);
                            imgRot=imgRot(end:-1:1,1:1:end,:);
                            
                        case 7
                            % flip horizontal
                            imgRot=img(1:1:end,end:-1:1,:);
                        case 8
                            % 90 deg left then flipped vert
                            imgRot=imrotate(img,90);
                            imgRot=imgRot(end:-1:1,1:1:end,:);
                            
               end
                    
                    
                    %now write out
                    
                    %orignal vox dim is 0.5 microns
                    %the img we read in is 16x that (8 microns)
                    
                    %if we want 100 micron (0.1mm) vox dims, then downsize by addnl 100/8
                    % (or resize by addnl 8%)  -- total is 0.5%
                    
                    invox=[(imgSizes(1)/imgSizes(whichImg))*origvox,1]
                    outvox=[out_res_mm,out_res_mm,1];


                    scale=invox./outvox;
      
                    
                    if (scale(1) ~= 1)
                          img100m=imresize(imgRot,scale(1));
                    else
                        img100m=imgRot;
                    end
                    
               %     if(out_res~=2)
               %     img100m=imresize(imgRot,scale(1));
                 %   else 
                  %      img100m=imgRot;
                  %  end
                    
                    %do a rotate right before nii save
                    if (out_res==100 | out_res==20 )
                    nii = make_nii(imrotate(img100m,-90), outvox,[0,0,0],2);
                    
                
                  
                    disp(['saving file: ' nii_file]);
                    save_nii(nii,nii_file);
                    fileattrib(nii_file,'+w','g');
                    
                    end
                    
                    
                    disp(['saving file: ' png_file]);
                    imwrite(img100m,png_file);
                    fileattrib(png_file,'+w','g');
                    
                end %exist orientfile
                
            end
            
        end
        
        
%    end

end
