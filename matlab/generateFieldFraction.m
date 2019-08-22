function  generateFieldFraction(tif,res_microns,pad_microns,out_root_dir,threshold)
%subj,specimen,slice,stain)

%converted tifs from svs trigger a type warning, this suppresses it..
%warning('off','all')
init_openslide;

%default uses 100um+5um pad -- Maged's 20um used 50um pad -- 

ref_res=100;


if ~exist('res_microns')
    %resolution of output feature maps, in microns
    res_microns=100; 
end

if ~exist('pad_microns')
    %padding of each chunk, in microns -- default is ~approx radius of neuron
   pad_microns=0;
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

if ~exist('threshold')
    threshold=0.5;
end
%tif='F:\Histology\EPI_P040\tif\EPI_P040_Neo_06_NEUN.tif';
%tif='/links/Histology/EPI_P040/tif/EPI_P040_Hp_06_NEUN.tif'

[path,name,ext]=fileparts(tif);


split=strsplit(name,'_');

stain_type=split{end};
strct=split{end-2}; %Hp or Neo

if (length(split) == 4)
	subj=split{1};
elseif (length(split) == 5)
	subj=[split{1},'_', split{2}];
end






    
outdir=sprintf('%s/%s/%s_FieldFractionsTH%g',out_root_dir,subj,out_name,threshold);
mkdir(outdir);


outmap=sprintf('%s/%s.mat',outdir,name);




[openslidePointer,hist_res, Nx,Ny] =  prepChunks_openslide (tif, res_microns);



features={'field_fraction'};


featureVec=zeros(Nx,Ny,length(features));


%padwidth should be radius of pyramidal neuron (say 10um/2 = 5um)
padWidth=floor(pad_microns./hist_res); %in pixels



for i=1:Nx
%    for i=roix
 
% i
fprintf('%2.1f percent complete\n',double(i-1)./double(Nx)*100);
    for j=1:Ny
%        for j=roiy
        
  %  j;
        [img]=getHiresChunkOpenslide(openslidePointer,Nx,Ny,i,j,0,padWidth); 
        

       
        stain_img=getStainChannel(img,stain_type);

	stain_img=255-stain_img;
        stain_img(stain_img<0)=0; %cap off at 0

        fraction=stain_img(:,:,1)./255;
        
        
        %fraction of pixels that are > threshold
        featureVec(i,j,1)=sum(fraction(:)>threshold)./numel(fraction);
        
        
       
    end % i
    
  %  disp(double(i)/double(Nx)*100);
end %j



save(outmap,'featureVec','features','pad_microns','res_microns');


%end %exist outmap

end
