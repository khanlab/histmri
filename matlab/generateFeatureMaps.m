function  generateFeatureMaps(tif,res_microns,pad_microns,out_root_dir)
%subj,specimen,slice,stain)

init_openslide;


%default uses 100um+5um pad -- Maged's 20um used 50um pad -- 

ref_res=100;



if ~exist('res_microns')
    %resolution of output feature maps, in microns
    res_microns=100; 
end

if ~exist('pad_microns')
    %padding of each chunk, in microns -- default is ~approx radius of neuron
   pad_microns=5;
   %by default, use legacy naming (100um_FeatureMaps)
   out_name=sprintf('%dum',res_microns);
else
    %otherwise, specify padding in name
    out_name=sprintf('%dum_%dumPad',res_microns,pad_microns);
end

if ~exist('out_root_dir')
    tif_folder=fileparts(fullfile(tif));
    out_root_dir=fullfile(sprintf('%s/../../',tif_folder));
end

%tif='F:\Histology\EPI_P040\tif\EPI_P040_Neo_06_NEUN.tif';
%tif='/links/Histology/EPI_P040/tif/EPI_P040_Hp_06_NEUN.tif'

[path,name,ext]=fileparts(tif);

split=strsplit(name,'_');


subj=name(1:8);
stain_type=split{end};
strct=split{end-2}; %Hp or Neo

if (length(split) == 4)
	subj=split{1};
elseif (length(split) == 5)
	subj=[split{1},'_', split{2}];
end



    
outdir=sprintf('%s/%s/%s_FeatureMaps',out_root_dir,subj,out_name);
mkdir(outdir);

%end

outmap=sprintf('%s/%s.mat',outdir,name);


ref_map=sprintf('%s/../%dum_FeatureMaps/%s.mat',path,ref_res,name);



        openslidePointer=openslide_open(tif);

        % mppX                      - Resolution, microns per pixel
        % mppY                      - Resolution, microns per pixel
        % width0                     - Size in pixels
        % height0                    - Size in pixels
        % numberOfLevels            - Number of levels available
        % downsampleFactors         - Downsample factors of the levels available
        % objectivePower            - Magnification factor for level 0
        
        [mppX,mppY,width0,height0,numberOfLevels,...
            downsampleFactors,objectivePower] = ...
            openslide_get_slide_properties(openslidePointer)

        if(mppX ~= mppY) 
            disp(sprintf('cannot proceed with non-square pixels, mppX = %g, mppY = %g',mppX,mppY));
            return;
        end
        
        %was previously hardcoded to 0.5um/pixel
        hist_res=mppX;
        
        scalefac=res_microns./hist_res;
        

        [width0, height0] = openslide_get_level0_dimensions(openslidePointer)

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
        

%         imgSizes=getAperioImgSizes(histFile);
        imgSizes=double([height0,width0]);
        ds_size=ceil(imgSizes./scalefac);
        Nx=ds_size(1);
        Ny=ds_size(2);
        
%         
% 
% %imgSizes=mexAperioTiff(tif);
% imgSizes=getAperioImgSizes(tif);
% 
% ds_size=ceil(imgSizes(1,:)./scalefac);
% Nx=ds_size(1);
% Ny=ds_size(2);


xout=0:0.5:255;
%maintain histogram
total_counts=zeros(size(xout));

skip_sweep=false;
%if feat map exists already, load it up and skip 1st sweep:
if (exist(ref_map))
    skip_sweep=true;
    load(ref_map,'threshold');
end




%need two sweeps, first to compute histograms and determine optimal
%threshold, then to threshold and count # of positives

if (~skip_sweep)
    

%sweep 1:
parfor i=1:Nx
    
    for j=1:Ny
     %   fprintf('i=%d,j=%d\n',i,j);
      
        
        [img]=getHiresChunkOpenslide(openslidePointer,Nx,Ny,i,j,0,0); 
        
        stain_img=getStainChannel(img,stain_type);
        
        counts= hist(stain_img(:),xout);
        total_counts=total_counts+counts;
        
        
        
    end
end

threshold=getStainThreshold(xout,total_counts,stain_type);

end


features={'count','area','perimeter','orientation','weighted_orientation','eccentricity','clustering','field_fraction'};


featureVec=zeros(Nx,Ny,length(features));

centroidVec=cell(Nx,Ny);
areaVec=cell(Nx,Ny);
angleVec=cell(Nx,Ny);
eccenVec=cell(Nx,Ny);


%get features of big and small neurons too
sizeThreshold=500;
features_bysize={'count','area','perimeter','orientation','eccentricity'};
featureVec_sml=zeros(Nx,Ny,length(features_bysize));
featureVec_big=zeros(Nx,Ny,length(features_bysize));




%padwidth should be radius of pyramidal neuron (say 10um/2 = 5um)
padWidth=floor(pad_microns./hist_res); %in pixels


%figure; 
%plot( fitresult{1}, xData, yData );

%roix=3:58;
%roiy=81:211;
 %roix=160:170;
 %roiy=160:170;


%now, have threshold, do second sweep to get pos pix frac
for i=1:Nx
%    for i=roix
 
% i
disp(sprintf('%2.1f percent complete',double(i-1)./double(Nx)*100));
    for j=1:Ny
%        for j=roiy
        
  %  j;
        [img]=getHiresChunkOpenslide(openslidePointer,Nx,Ny,i,j,0,padWidth); 
        
%         fh=figure; imagesc(img);
%         c=centroidVec{i,j};
%         hold on; scatter(c(:,1),c(:,2),'g.');
%         set(gcf,'Position',[66 1 1855 1001]);
%         axis equal;
%         saveas(fh,sprintf('snapshot_%d_%d.jpg',i,j));
%         
%         close(fh);

       
        stain_img=getStainChannel(img,stain_type);
        
        preWS=(threshold-stain_img)./255;         
        preWS(preWS<0)=0;
        
        
        %compute field fraction (on region with padding removed)
        nonpadimg=preWS(padWidth:(end-padWidth),padWidth:(end-padWidth));
        featureVec(i,j,8)=sum(nonpadimg(:)>0)/numel(nonpadimg);
        
        %remove border 
        preWS=preWS.*imclearborder(preWS>0);
        
       min_th=100; % number of pixels to be positive to perform watershed
        
        if(numel(find(preWS>0))<min_th)
            
            %nothing passes the preWS threshold, skip this chunk..
            continue
        end
        
           
        if (strcmp(strct,'Neo'))
    
        [wL] = watershed2(preWS,5); 

        elseif (strcmp(strct,'Hp'));
            
        [wL] = watershed2(preWS,6); 


        end 
        
        
        neuronCC=bwconncomp(wL);
        
            
        featureVec(i,j,1)=neuronCC.NumObjects;
       
        if (neuronCC.NumObjects > 0)
            
            props= regionprops(neuronCC,'Eccentricity','Area','Perimeter','Orientation','Centroid');  
            
            featureVec(i,j,2)=mean(cat(1,props.Area)).*hist_res^2;  %in units of um^2
            featureVec(i,j,3)=mean(cat(1,props.Perimeter));

          
            area=cat(1,props.Area);
            perim=cat(1,props.Perimeter);
            angle=cat(1,props.Orientation);
            eccen=cat(1,props.Eccentricity);
            centroid=cat(1,props.Centroid);

                        
            %get avg in cos space
            cos_mean=acos(mean(cos(angle/180*pi)))*180/pi;
            
            if (cos_mean>=45)
                angle(angle<0)=angle(angle<0)+180;
                featureVec(i,j,5)=mean((angle-90).*eccen)+90;
            else
                featureVec(i,j,5)=mean(angle.*eccen);
                
            end
            
            featureVec(i,j,4)=mean(angle); 
            featureVec(i,j,6)=mean(eccen);
            featureVec(i,j,7)=mean(pdist(centroid));
            
            centroidVec(i,j)={centroid};
            angleVec(i,j)={angle};
            areaVec(i,j)={area};
            eccenVec(i,j)={eccen};
            % fill in featureVec_sml and featureVec_big
            % with features_bysize
            
            ind_sml=(cat(1,props.Area) < sizeThreshold);
            ind_big=(cat(1,props.Area) >= sizeThreshold);
            
            
            %count
            featureVec_sml(i,j,1)=sum(ind_sml);
            
            %area
            featureVec_sml(i,j,2)=mean(area(ind_sml));
            
            %perimeter
            featureVec_sml(i,j,3)=mean(perim(ind_sml));
            
            %angle:
            featureVec_sml(i,j,4)=mean(angle(ind_sml)); 
            
            %eccentricity
            featureVec_sml(i,j,5)=mean(eccen(ind_sml));

            
            %big neurons:
                        
            
            %count
            featureVec_big(i,j,1)=sum(ind_big);
            
            %area
            featureVec_big(i,j,2)=mean(area(ind_big));
            
            %perimeter
            featureVec_big(i,j,3)=mean(perim(ind_big));
            
            %angle:
            featureVec_big(i,j,4)=mean(angle(ind_big)); 
            
            %eccentricity
            featureVec_big(i,j,5)=mean(eccen(ind_big));
            
            
            
        end
        
       
    end
    
  %  disp(double(i)/double(Nx)*100);
    end


    %don't rotate yet... need to rotate orientations too!
    
%plot all features
 %figure;
 %for f=1:size(featureVec,3)
  %   subplot(1,size(featureVec,3),f); imagesc(featureVec(:,:,f));
  %   title(features{f});
  %  featureVec(:,:,f)=rotateImgTiffSpace(featureVec(:,:,f),tif);
 %end


save(outmap,'featureVec','features','total_counts','xout','threshold','featureVec_sml','featureVec_big','features_bysize','centroidVec','angleVec','areaVec','eccenVec','pad_microns','res_microns','ref_map');


%end %exist outmap

end
