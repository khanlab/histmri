function  generatePatches(tif,res_microns,pad_microns,out_root_dir)
%subj,specimen,slice,stain)

init_openslide;

scratch_dir=getenv('SLURM_TMPDIR');
if isempty(scratch_dir)
	scratch_dir=getenv('TMPDIR');
	if isempty(scratch_dir)
		disp('Cannot set suitable temp dir for patches, tried SLURM_TMPDIR or TMPDIR');
		exit;
	end
end
disp(sprintf('Using scratch_dir=%s',scratch_dir));

%default uses 100um+5um pad -- Maged's 20um used 50um pad --


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

    tif_folder=fileparts(fullfile(tif));
    in_root_dir=fullfile(sprintf('%s/../../',tif_folder));



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


featdir=sprintf('%s/%s/%s_FeatureMaps',out_root_dir,subj,out_name);
patchdir=sprintf('%s/%s/%s_Patches',out_root_dir,subj,out_name);
mkdir(patchdir);


%end

inmap=sprintf('%s/%s.mat',featdir,name);
out_tar=sprintf('%s/%s.tar',patchdir,name);

%load up features and featureVec
load(inmap); 


[openslidePointer,hist_res, Nx,Ny] =  prepChunks_openslide (tif, res_microns);


padWidth=floor(pad_microns./hist_res); %in pixels
%get patch only if featureVec(i,j,1) > min_number_neurons
min_number_neurons=5;

for i=1:Nx
    %    for i=roix
    
    % i
%    disp(sprintf('%2.1f percent complete',double(i-1)./double(Nx)*100));
    for j=1:Ny
        %        for j=roiy
        
        %  j;
	if (featureVec(i,j,1) > min_number_neurons)

		disp(sprintf('about to get patch for i=%03d, j=%03d',i,j));
	        [img]=getHiresChunkOpenslide(openslidePointer,Nx,Ny,i,j,0,padWidth);
		out_png=sprintf('%s/%s_RGB_%03d_%03d.png',scratch_dir,name,i,j);
		disp(sprintf('saving as: %s',out_png));
		imwrite(img,out_png);
       end 
       
        
%        stain_img=getStainChannel(img,stain_type);        
%        preWS=(threshold-stain_img)./255;
%        preWS(preWS<0)=0;
        
           
            
        end
        
        
    end

    %all patches in scratch_dir now, tar them up and save in patchdir
    tar(out_tar,'*.png',scratch_dir);
end






