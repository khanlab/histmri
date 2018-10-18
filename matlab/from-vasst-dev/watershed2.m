function [nmask,L] = watershed2(I,reconR) 
%% compute gradient magnitude

%Neo default is 5, Hp is 6.
if ~exist('reconR')
    reconR=5;
end

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
%figure, imagesc(gradmag), title('Gradient magnitude (gradmag)'), colormap(gray)

%L = watershed(gradmag);
%Lrgb = label2rgb(L);
%figure, imshow(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)')

%% Morphological reconstruction with disk r=reconR -- clean up outside of neurons

% Algorithm for Hippocampus used r=6 instead of r=5.. 

se = strel('disk',reconR);
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);

%% Morphological reconstruction in opposite direction (dilation), r=reconR,  clean up inside of neurons

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);


%% create map of where neurons should be, for imposing on final watershed


fgm = imregionalmax(Iobrcbr);
%figure, imagesc(fgm), title('Regional maxima of opening-closing by reconstruction(fgm)'),colormap(gray)


%I2 = I;
%I2(fgm) = 255;
%figure, imagesc(I2), title('Regional maxima superimposed on original image (I2)'), colormap(gray)


%str element of 5x5 matrix

se2 = strel(ones(5,5));
%se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2); 

%area open, with size 12 -- anything less than 12 pixels vanishes..

% min area of granule cell is 150, but this 
% segmentaiton is eroded with 5x5 kernel, so
% min area in eroded is ~55 (found from taking disk of rad 7, and eroding it)
%   can probably calculate analytically too, but oh well..

minarea=55; % 150 is area of granule cell;


fgm4 = bwareaopen(fgm3,minarea);


%I3 = I;
%I3(fgm4) = 255;
%figure, imagesc(I3), colormap(gray)
%title('Modified regional maxima superimposed on original image (fgm4)')

cc=bwconncomp(fgm4);
if(cc.NumObjects==1)
    
    %no need for watershed, as no splitting required
    cc=bwconncomp(Iobrcbr>0);
    if (cc.NumObjects==0)
            nmask=zeros(size(I));
            return;
    end
    
    numPix=cellfun(@numel,cc.PixelIdxList);
    [m_area,m_ind]=max(numPix);
    nmask=zeros(size(I));
    nmask(cc.PixelIdxList{m_ind})=1;
    
    return;
    
end

%% compute distance transform, and watershed, pulling out ridge lines

D = bwdist(Iobrcbr>0);
%D=bwdist(fgm4); %use dist transform of where neuron centers are to help separate


DL = watershed(D);
bgm = (DL == 0);
%figure, imagesc(bgm), title('Watershed ridge lines (bgm)'), colormap(gray)

%% final watershed, with imposed ridge lines, and neuron centers

gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);
%figure; imshow(L)


nmask=L>0;
%nlbls=unique(L(fgm4));
%nmask=zeros(size(L));
%for i=1:length(nlbls);
%    nmask=(nmask | L==nlbls(i));
%end

%can get all edge pixels
edges=[L(1,:)';L(end,:)';L(:,1);L(:,end)];
bgnd_lbls=unique(edges);
for i=1:length(bgnd_lbls);
    nmask(L==bgnd_lbls(i))=0;
end



%numNeurons=length(nlbls);
%want to return image with neurons as one label, bgnd as another


%I4 = I;
%I4(imdilate(L == 0, ones(4, 4)) | bgm | fgm4) = 255;
%figure, imshow(I4), colormap(gray)
%title('Markers and object boundaries superimposed on original image (I4)')

%Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
%figure, imshow(Lrgb) 
%title('Colored watershed label matrix (Lrgb)') 

% figure, imshow(I), hold on
% himage = imshow(Lrgb);
% set(himage, 'AlphaData', 0.3);
% title('Lrgb superimposed transparently on original image')

end
