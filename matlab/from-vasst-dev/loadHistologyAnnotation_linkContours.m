%% get landmarks for stain coregistration validation -- on HE, GFAP, NEUN --
function loadHistologyAnnotation (annot_folder , res_microns);

hist_microns=0.5;

ds=res_microns./hist_microns;

[path,annot_name,ext]=fileparts(annot_folder);

out_dir=sprintf('%s/../%dum_Annotations_%s',path,res_microns,annot_name);
mkdir(out_dir);


%for later, if we decide to add this..
%d=dir(sprintf('%s/*',annot_folder));
%isub = [d(:).isdir]; %# returns logical vector
%annot_names = {d(isub).name}';
%annot_names(ismember(annot_names,{'.','..'})) = [];




files=dir(sprintf('%s/*.xml',annot_folder));


orientcsv=sprintf('%s/../tif/orientation.csv',path);
orient=importdata(orientcsv);
orientflags=orient.data;
tifs=orient.textdata;


for f=1:length(files)
    
[xmlpath,name,ext]=fileparts(files(f).name);

xml=sprintf('%s/%s%s',annot_folder,name,ext);

split=strsplit(name,'_');

%get stain type at end of name:
s=name;

subj=name(1:8);
stain_type=split{end};
strct=split{end-2}; %Hp or Neo

tif=sprintf('%s/../tif/%s.tif',path,name);
index=find(strcmp(tifs,sprintf('%s.tif',name)));
    

%imgSizes=mexAperioTiff(tif);
imgSizes=getAperioImgSizes(tif);

imsize=imgSizes(1,:);
orientflag=orientflags(index);

ds_size=ceil(imsize./ds);
roi_ds=uint8(zeros(ds_size(1),ds_size(2)));

features=cell(1,1);
features{1}=annot_name;


[contours,contoursClosed,names,names_alt]=readAperioXMLContours(xml);

for c=1:length(contours)
    
    if (length(contours{c})==0)
        disp('no contours');
        continue;
    end
    
                label_num=c;

                
                
  %  figure;
  existing_lmk=[];
  nsegs=0;
  distpix=zeros(4,1);
  figure;
        for roi=1:length(contours{c})
            
            %load in current segment, appending to existing
            curr_lmk=contours{c}{roi};
            existing_lmk=[existing_lmk; curr_lmk];
            

            %if there is a next segment
            if roi<length(contours{c})
                
                %and it is continuous with next segment 
                next_lmk=contours{c}{roi+1};
                
              
%            scatter(existing_lmk(:,1),existing_lmk(:,2),'.'); hold on; scatter(next_lmk(:,1),next_lmk(:,2),'.'); 
 %           roi
%            roi+1
                
                dist_th=5000;
                %check if any endpoints are close by
                dist_pix(1)=sqrt(sum((existing_lmk(end,:)-next_lmk(1,:)).^2));  %end of current lmk with beginning of next
                dist_pix(2)=sqrt(sum((existing_lmk(1,:)-next_lmk(1,:)).^2));  %start of current lmk with beginning of next (reverse current)
                dist_pix(3)=sqrt(sum((existing_lmk(end,:)-next_lmk(end,:)).^2)); %end of current lmk with end of next (reverse next)
                dist_pix(4)=sqrt(sum((existing_lmk(1,:)-next_lmk(end,:)).^2));  %start of current lmk with end of next (reverse both)
                [mindist,minind]=min(dist_pix);
          
                
                if (mindist<dist_th)
                    
                    if(minind==2 || minind==4)
                        existing_lmk=flip(existing_lmk);
                    end
                    if (minind==3 || minind==4)
                        contours{c}{roi+1}=flip(next_lmk);
                    end

                    nsegs=nsegs+1;
                    continue %then continue on to next segment
                    
                end
                
            end
            
            
            %otherwise, write out existing contour, then reset
      %      disp(sprintf('number segments: %d',nsegs));
            curr_ds=poly2mask(existing_lmk(:,1)./ds,existing_lmk(:,2)./ds,ds_size(1),ds_size(2));
            roi_ds(curr_ds==1)=label_num;
       %    figure; imagesc(roi_ds);

            
            nsegs=0;
            existing_lmk=[];
        end
        
end
            
            
            
            
            




%roi=roi_ds;
featureVec=roi_ds;
            figure;     imagesc(roi_ds);

out_mat=sprintf('%s/%s.mat',out_dir,name);
save(out_mat,'features','res_microns','featureVec');
    

end 
 
    
end



