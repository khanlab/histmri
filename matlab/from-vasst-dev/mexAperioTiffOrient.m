function img=mexAperioTiffOrient(tif,imselect,begX,endX,begY,endY,orient_flag);
%wrapper to mexAperioTiff that uses orient flag
%currently only works on full res image

% -- need to :
% transform coordinates, then pull out image, then transform image
% accordingly..


          %     imgSizes=mexAperioTiff(tif);
               imgSizes=getAperioImgSizes(tif);
                               

               nx=imgSizes(imselect,1);
               ny=imgSizes(imselect,2);
        
               
switch orient_flag
    case 1
        o_begX=begX;
        o_endX=endX;
        o_begY=begY;
        o_endY=endY;
        
       % img=mexAperioTiff(tif,imselect,o_begX,o_endX,o_begY,o_endY);
        img=imread(tif,imselect,'PixelRegion',{[o_begX,o_endX],[o_begY,o_endY]});

    case 2
        % 90 deg right
       % imgRot=imrotate(img,-90);
        disp(sprintf('orientflag %d not implemented!',orient_flag));
        exit 0
    case 3
        % 180 degmexAperioTiff
        

        o_endX=nx-begX;
        o_begX=nx-endX;
        o_endY=ny-begY;
        o_begY=ny-endY;

        %img=mexAperioTiff(tif,imselect,o_begX,o_endX,o_begY,o_endY);
        img=imread(tif,imselect,'PixelRegion',{[o_begX,o_endX],[o_begY,o_endY]});

                img=imrotate(img,180);
                
    case 4
        % 90 deg left
       % imgRot=imrotate(img,90);
        disp(sprintf('orientflag %d not implemented!',orient_flag));
        exit 0

    case 5
        % flip vertical
      % 
        o_endX=nx-begX;
        o_begX=nx-endX;
        o_begY=begY;
        o_endY=endY;
             
        %img=mexAperioTiff(tif,imselect,o_begX,o_endX,o_begY,o_endY);
        img=imread(tif,imselect,'PixelRegion',{[o_begX,o_endX],[o_begY,o_endY]});

        img=img(end:-1:1,1:1:end,:);
      

    case 6
        %imgRot=imrotate(img,-90);
       % imgRot=imgRot(end:-1:1,1:1:end,:);
        disp(sprintf('orientflag %d not implemented!',orient_flag));
        exit 0

    case 7
        % flip horizontal
        
        o_begX=begX;
        o_endX=endX;
        o_endY=ny-begY;
        o_begY=ny-endY;
 
       % img=mexAperioTiff(tif,imselect,o_begX,o_endX,o_begY,o_endY);
        img=imread(tif,imselect,'PixelRegion',{[o_begX,o_endX],[o_begY,o_endY]});

        img=img(1:1:end,end:-1:1,:);


    case 8
        % 90 deg left then flipped vert
    %    imgRot=imrotate(img,90);
     %   imgRot=imgRot(end:-1:1,1:1:end,:);
        disp(sprintf('orientflag %d not implemented!',orient_flag));
        exit 0

end
