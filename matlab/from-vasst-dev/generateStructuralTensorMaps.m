function  generateStructuralTensorMaps(tif)
%subj,specimen,slice,stain)

%tif='/eq-nas/alik/EpilepsyHistology/Histology_Hp/EPI_P040/tif/EPI_P040_Hp_04_LUXFB.tif';
%tif='\\eq-nas\EpilepsyHistology\Histology_Hp\EPI_P040\tif\EPI_P040_Hp_04_LUXFB.tif';
%tif='/eq-nas/alik/EpilepsyHistology/Histology_Hp/EPI_P040/tif/EPI_P040_Hp_04_NEUN.tif';

%tif='F:\Histology\EPI_P040\tif\EPI_P040_Neo_06_NEUN.tif';
%tif='/links/Histology/EPI_P040/tif/EPI_P040_Hp_06_NEUN.tif'

[path,name,ext]=fileparts(tif);

%get stain type at end of name:
s=name;
for i=1:5
    [token,s]=strtok(s,'_');
    if( i==3)
        strct=token;
    end
    
end
stain_type=token;
subj=name(1:8);


outdir=sprintf('%s/../100um_StructuralTensors',path);
mkdir(outdir);

outmap=sprintf('%s/%s.mat',outdir,name);

sigma=5;

scalefac=200;


%imgSizes=mexAperioTiff(tif);
imgSizes=getAperioImgSizes(tif);

ds_size=ceil(imgSizes(1,:)./scalefac);
Nx=ds_size(1);
Ny=ds_size(2);

% 
% skip_sweep=0;
% if (strcmp(stain_type,'LUXFB'))
%     skip_sweep=1;
% end
    
xout=0:0.5:255;
%maintain histogram
total_counts=zeros(size(xout));
%             
% if (~skip_sweep)
%     
% %sweep 1 to get thresholds:
% for i=1:Nx
%     i
%     for j=1:Ny
%         
%     
%         [img]=getHiresChunkAperio(tif,Nx,Ny,i,j,0,0); 
%         
%         stain_img=getStainChannel(img,stain_type);
%         
%         counts= hist(stain_img(:),xout);
%         total_counts=total_counts+counts;
%         
%         
%     end
%     
% end
% 
% threshold=getStainThreshold(xout,total_counts,stain_type);
% 
% end




%features={'principal_orientation_rad','principal_orientation_x','principal_orientation_y','principal_orientation_dispersion'};

features={'major_angle','mean_anisotropy','mean_trace'};

featureVec=zeros(Nx,Ny,length(features));


%padwidth should be radius of pyramidal neuron (say 10um/2 = 5um)
padWidth=0; %in pixels

hist_counts=cell(Nx,Ny);
hist_centers=cell(Nx,Ny);




for i=1:Nx
%    for i=roix
 %   i
    for j=1:Ny
%        for j=roiy
        
  %  j;
        [img]=getHiresChunkAperio(tif,Nx,Ny,i,j,0,padWidth); 
        
        if (strcmp(stain_type,'LUXFB'))
            proc_img=img;
        end
        
        if (strcmp(stain_type,'NEUN') || strcmp(stain_type,'GFAP'))
            proc_img=getStainChannel(img,stain_type);
        end
        
        
        % perform structural tensor analysis
            [hist_counts{i,j},hist_centers{i,j},featureVec(i,j,1),featureVec(i,j,2),featureVec(i,j,3)]=computeStructuralTensor(proc_img,sigma);


            %update this later to include: 
                   % multiple sigmas
                   % orientation dispersion
                   % parametric OdiffDFs?

             %fourier series order 4 fit to histogram
%            ffit1=fit(xdata',ydata','fourier4');

                   
        end
       
end



save(outmap,'sigma','hist_counts','hist_centers','features','featureVec');
    
    
end
