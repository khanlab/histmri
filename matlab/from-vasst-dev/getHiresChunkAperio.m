function [img,ds_pix_x,ds_pix_y]=getHiresChunkAperio(tif,Nx, Ny, i, j,scalefac,padWidth)
%getHiresChunkAperio Pulls out (i,j)-th tile chunk in Aperio BigTiff given
%that full res image is split into Nx x Ny chunks. Also returns coords of 
%this chunk in downsampled space (downsampling rate specified by scalefac)

%test params
% 
% tif='/media/Histology/Histology/EPI_P021/tif/EPI_P021_Neo_06_HE.tif';
% 
% Nx=500;
% Ny=500;
% 
% i=202;
% j=199;

%imgSizes=mexAperioTiff(tif);
imgSizes=getAperioImgSizes(tif);



dim=imgSizes(1,:);
bsizex=floor(dim(1)./Nx);
bsizey=floor(dim(2)./Ny);

beginx=[1:bsizex:dim(1)];
if(size(beginx,2)==(Nx+1))
    beginx(end)=[];
end
endx=[beginx(2:end)-1,dim(1)];

beginy=[1:bsizey:dim(2)];
if(size(beginy,2)==(Ny+1))
beginy(end)=[];
end
endy=[beginy(2:end)-1,dim(2)];



if(scalefac ~=0)
    
dim_ds=dim.*scalefac;
bsizex_ds=dim_ds(1)./Nx;
bsizey_ds=dim_ds(2)./Ny;

beginx_ds=round([1:bsizex_ds:dim_ds(1)]);
endx_ds=round([beginx_ds(2:end)-1,dim_ds(1)]);

beginy_ds=round([1:bsizey_ds:dim_ds(2)]);
endy_ds=round([beginy_ds(2:end)-1,dim_ds(2)]);
end


bx=beginx(i);
ex=endx(i);
by=beginy(j);
ey=endy(j);

if(nargin>5)
    bx=max(bx-padWidth,beginx(1));
    ex=min(ex+padWidth,endx(end));
    by=max(by-padWidth,beginy(1));
    ey=min(ey+padWidth,endy(end));
end

%get (i,j)-th block
%img=mexAperioTiff(tif,1,bx,ex,by,ey);
img=imread(tif,1,'PixelRegion',{[bx,ex],[by,ey]});

if(scalefac ~=0)

ds_pix_x=[beginx_ds(i):endx_ds(i)];
ds_pix_y=[beginy_ds(j):endy_ds(j)];
end

%figure; imagesc(img);
end