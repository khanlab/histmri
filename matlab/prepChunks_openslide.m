function [openslidePointer,hist_res, Nx,Ny] =  prepChunks_openslide (histFile, res_microns)
%need to populate: hist_res, Nx, Ny ;  inputs: hist_file, res_microns



openslidePointer=openslide_open(histFile);

% mppX                      - Resolution, microns per pixel
% mppY                      - Resolution, microns per pixel
% width0                     - Size in pixels
% height0                    - Size in pixels
% numberOfLevels            - Number of levels available
% downsampleFactors         - Downsample factors of the levels available
% objectivePower            - Magnification factor for level 0

[mppX,mppY,width0,height0,numberOfLevels,...
    downsampleFactors,objectivePower] = ...
    openslide_get_slide_properties(openslidePointer);

if(mppX ~= mppY)
    disp(sprintf('cannot proceed with non-square pixels, mppX = %g, mppY = %g',mppX,mppY));
    return;
end

%was previously hardcoded to 0.5um/pixel
hist_res=mppX;

scalefac=res_microns./hist_res;


[width0, height0] = openslide_get_level0_dimensions(openslidePointer);

% openslidePointer          - Pointer to openslide object to read from
% xPos                      - Pixel position, with first position as 0 and in
%                             the specified level reference frame
% yPos                      - Pixel position, with first position as 0 and in
%                             the specified level reference frame
% width                     - Widht of region to read in pixels
% height                    - Height of region to read in pixels
%
% OPTIONAL INPUT ARGUMENTS
% 'level'                   - Image level to read, 0 refers to original
%                             level


%         imgSizes=getAperioImgSizes(histFile);
imgSizes=double([height0,width0]);
ds_size=ceil(imgSizes./scalefac);
Nx=ds_size(1);
Ny=ds_size(2);


end