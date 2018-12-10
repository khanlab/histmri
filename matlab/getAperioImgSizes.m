function imgSizes=getAperioImgSizes(tif)

tifinfo=imfinfo(tif);
imgSizes=zeros(length(tifinfo),2);

for i=1:length(tifinfo)
    imgSizes(i,1)=tifinfo(i).Height;
    imgSizes(i,2)=tifinfo(i).Width;
end

end