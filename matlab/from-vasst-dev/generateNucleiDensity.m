function  generateNucleiDensity(tif,res_microns,pad_microns)
%subj,specimen,slice,stain)


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



%tif='F:\Histology\EPI_P040\tif\EPI_P040_Neo_06_NEUN.tif';
%tif='/links/Histology/EPI_P040/tif/EPI_P040_Hp_06_NEUN.tif'

[path,name,ext]=fileparts(tif);

split=strsplit(name,'_');

%get stain type at end of name:
s=name;

subj=name(1:8);
stain_type=split{end};
strct=split{end-2}; %Hp or Neo


%currently only HE and LUXFB supported
if (~  strcmp(stain_type,'HE'))
    disp(sprintf('Unsupported stain_type: %s',stain_type));
end



lores_png=sprintf('%s/../%dum_png/%s.png',path,res_microns,name);

if ~exist(lores_png)
  system(sprintf('echo %s >> Missing_%dum_png.txt',lores_png,res_microns))
else
lores=imread(lores_png);
end



    
outdir=sprintf('%s/../%s_SimpleNucleiDensity',path,out_name);
mkdir(outdir);

%end

outmap=sprintf('%s/%s.mat',outdir,name);





%0.5um/pixel
hist_res=0.5;

scalefac=res_microns./hist_res;


%imgSizes=mexAperioTiff(tif);
imgSizes=getAperioImgSizes(tif);


ds_size=ceil(imgSizes(1,:)./scalefac);
Nx=ds_size(1);
Ny=ds_size(2);




features={'nuclei_density'};


featureVec=zeros(Nx,Ny,length(features));


%padwidth should be radius of pyramidal neuron (say 10um/2 = 5um)
padWidth=pad_microns./hist_res; %in pixels



for i=1:Nx
%    for i=roix
 
% i
disp(sprintf('%2.1f percent complete',double(i-1)./double(Nx)*100));
    for j=1:Ny
%        for j=roiy
        
  %  j;
        [img]=getHiresChunkAperio(tif,Nx,Ny,i,j,0,padWidth); 
        

       
        stain_img=getStainChannel(img,stain_type);
        
        fraction=stain_img(:,:,3)./255;
        
        threshold=0.5;
        
        %fraction of pixels that are > threshold
        featureVec(i,j,1)=sum(fraction(:)>threshold)./numel(fraction);
        
        
       
    end % i
    
  %  disp(double(i)/double(Nx)*100);
end %j



save(outmap,'featureVec','features','pad_microns','res_microns');


%end %exist outmap

end
