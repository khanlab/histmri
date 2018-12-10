function processNotchFilterHistMap( in_mat, out_mat)


%in_mat='sub_01_WM_01_LFB.mat';
%out_mat='sub_01_WM_01_LFB_filt.mat';

load(in_mat,'featureVec');

% could eventually make this loop through the 3rd dimension for
% processing multiple scalar maps.. try on neuron count, size etc, later..

f=featureVec;



%% create filter

[N,M]=size(f);

notchfactor=10; %this is the parameter that is defined by the 
                %slide scanner, found empirically, but should be 
                % related to the FOV of the microscope

notchinterval=ceil(M./notchfactor);

F=fftshift(fft2(f));

centrek=[ceil((N+1)/2),ceil((M+1)/2)];
notchespos=centrek(2):notchinterval:M;
notchesneg=centrek(2):-notchinterval:1;
%make sure they are same size, if not strip off longer one..
minlen=min(length(notchespos),length(notchesneg));
notchespos=notchespos(2:minlen); %take off DC term (centrek), and extra 
notchesneg=notchesneg(2:minlen);
notches=sort([notchespos,notchesneg]); %sorting not required, but just neater..


H=ones(N,M);
H(ceil((N+1)/2),notches)=0; %notch filters

epsilon=ceil(M/80); %epsilon proportional to image size

H=imerode(H,strel('disk',epsilon));
%H=imerode(H,strel('rectangle',epsilon.*[2,2]));

gausseps=ceil(epsilon/4);
gaussH=gausseps*2+1;
gaussS=gausseps;
H=imfilter(H,fspecial('gaussian',gaussH,gaussS),'replicate');


F=fftshift(fft2(f));
G=H.*F;

filtf=abs(ifft2(G));

%% save result - copy old .mat file, and update featureVec image

copyfile(in_mat,out_mat);

featureVec=filtf;
save(out_mat,'featureVec','-append');

% %% plot filter and result
% figure; 
% subplot(1,3,1); imagesc(log(abs(F)));
% subplot(1,3,2); imagesc(H);
% subplot(1,3,3); imagesc(log(abs(H.*F)));
% 
% figure; 
% 
% subplot(1,4,1); imagesc(f); 
% subplot(1,4,2);  imagesc(log(abs(F)));
% subplot(1,4,3);  imagesc(log(abs(G)));
% subplot(1,4,4); imagesc(filtf);


end
