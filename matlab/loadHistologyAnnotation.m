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
        for roi=1:length(contours{c})
            
            lmk=contours{c}{roi};
            
            curr_ds=poly2mask(lmk(:,1)./ds,lmk(:,2)./ds,ds_size(1),ds_size(2));
                        
            roi_ds(curr_ds==1)=label_num;
       %     imagesc(roi_ds);
        end
end 
            




%roi=roi_ds;
featureVec=roi_ds;

out_mat=sprintf('%s/%s.mat',out_dir,name);
save(out_mat,'features','res_microns','featureVec');
    

end 
 
    
end



