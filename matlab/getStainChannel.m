function stain_img = getStainChannel(img,stain_type)



switch stain_type

    case {'NEUN','GFAP','NF'}
      %  disp('H DAB');
        
        in_mod=[ 0.650, 0.704, 0.286;  %Haem
            0.268, 0.570, 0.776;  %DAB
            0, 0, 0];
        
        MOD=createColourDeconvolveMatrix(in_mod);
        
        
        %save second channel
        
        stain_img=computeColourDeconvolve(img,MOD);
 %       stain_imgH=stain_img(:,:,1); %Haem
        stain_img=stain_img(:,:,2); %DAB
       
%       figure;imagesc(stain_imgH(100:500,70:500,:));axis off;axis equal;  
%       figure;imagesc(stain_img(100:500,70:500,:));axis off;axis equal;


    stain_img=255-stain_img;
    stain_img(stain_img<0)=0; %cap off at 0
    
        
    case {'LUXFB','LFB'}
        
        %old
%     in_mod =[    0.6622    0.2764    0.1070;
%                     0.8520    0.5107    0.4389;
%                     0         0         0];


in_mod =[
    0.6622    0.2764    0.1070
    0.4902    0.5333    0.5412
         0         0         0];


    MOD=createColourDeconvolveMatrix(in_mod);

    %save first channel
	stain_img=computeColourDeconvolve(img,MOD);
    
    %old extraction
% 	stain_img=stain_img(:,:,1);
%     stain_img(stain_img<0)=0;
    
        stain_img=stain_img(:,:,1);  %LFB component

    
    stain_img=255-stain_img;
    stain_img(stain_img<0)=0; %cap off at 0
    
    
        
    case 'HE' %split into blood, tissue, nuclei as channels 1 to 3
        
  
    
    in_mod =[

    0.2343    0.8508    0.8000
    0.1765    0.6121    0.4336
    0.6180    0.8147    0.5797];

    MOD=createColourDeconvolveMatrix(in_mod);
    
    
	stain_img=computeColourDeconvolve(img,MOD);
    
        stain_img=255-stain_img;
    stain_img(stain_img<0)=0; %cap off at 0
    
    
    case 'LFBHE' %Luxol fast blue with H&E
        
        %this one is untested..
       in_mod=[0.644211000,0.716556000,0.266844000
            0.09278900,0.95411100,0.28311100
            0.6622    0.2764    0.1070];

        
        
        stain_img=computeColourDeconvolve(img,MOD);
        stain_img=stain_img(:,:,3);  %LFB component
       

    stain_img=255-stain_img;
    stain_img(stain_img<0)=0; %cap off at 0
    
    case 'Biels'
        
            %this one is untested..
       in_mod=[0.7608    0.8667    0.9333   %from color picker
            0.733,0.413,0.177               %opposing color1 in color wheel
            0.00000000,0.00000000,0.0000000];   

        
        
        stain_img=computeColourDeconvolve(img,MOD);
        stain_img=stain_img(:,:,1);  %LFB component
       

    stain_img=255-stain_img;
    stain_img(stain_img<0)=0; %cap off at 0
    
    otherwise
        disp('Unknown staining!');
        exit 0
        
end




end
        
