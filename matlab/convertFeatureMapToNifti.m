function convertFeatureMapToNifti( hist_dir,subj,strct,stain_type, res_microns, feat_name,out_dir )


disp(sprintf('%s/%s/%s/%s_%s_*_%s.mat',out_dir,subj,feat_name,subj,strct,stain_type));
mat_files=dir(sprintf('%s/%s/%s/%s_%s_*_%s.mat',out_dir,subj,feat_name,subj,strct,stain_type));


for f=1:length(mat_files)
    
    featmap=sprintf('%s/%s',mat_files(f).folder,mat_files(f).name);
    
    [path,name,~]=fileparts(featmap);
    
    jpx_dir=sprintf('%s/%s/jpx',hist_dir,subj);
    
    jpx=sprintf('%s/%s.jpx',hist_dir,name);

    disp(featmap);
    disp(jpx);    
    if (~exist(featmap))
        fprintf('Feature map %s does not exist!\n',featmap);
        continue
    end
    
    %mat file:
    load(featmap);
    
    if (~exist('features','var'))
        fprintf('Feature map %s does not contain a features variable!\n',featmap);
        continue
    end
    
    if (~exist('featureVec','var'))
        fprintf('Feature map %s does not contain a featureVec variable!\n',featmap);
        continue
    end
    
    
    orientcsv=sprintf('%s/orientation.csv',jpx_dir);
    
    
    for i=1:length(features)
        
        
        
        outdir=sprintf('%s/histspace/%s',path,features{i});
        mkdir(outdir);
        
        featRot=rotateImgTiffSpaceWithOrient(featureVec(:,:,i),jpx,orientcsv);
        
        if(~exist('res_microns'))
            res_microns=100
        end
        
        inplane_mm=res_microns/1000;
        
        %save as nifti
        nii=make_nii(imrotate(featRot,-90),[inplane_mm,inplane_mm,4.4],[0,0,0],16);
        
        niifile=sprintf('%s/%s.nii',outdir,name);
        save_nii(nii,niifile);
        gzip(niifile);
        delete(niifile);
        
        
    end
    
    
    
    
end


end


