function  imgRot=rotateVectorImgTiffSpaceWithOrient(img,tif,orientcsv)

%test par
% subj='EPI_P021';
% mask='/home/mgoubran/home_bak/epilepsy/local_data/Neo-Hist_ROI_cor/EPI_P021/RegROI_stain/ROI_07_NEUN.png';
% img=imread(mask);
% out_img='test_rot.png';

[path,name,ext]=fileparts(tif);


orient=importdata(orientcsv);
orientflags=orient.data;
tifs=orient.textdata;


%rotate 90deg left to begin with
img=rotateVectorImg2D(img,-90);


tifind=ind2sub(size(tifs), strmatch([name ext], tifs, 'exact'));

    switch orientflags(tifind)
        
                        case 1
                            imgRot=img;
                        case 2
                            % 90 deg right
                            imgRot=rotateVectorImg2D(img,-90);
                        case 3
                            % 180 degmexAperioTiff
                            imgRot=rotateVectorImg2D(img,180);
                        case 4
                            % 90 deg left
                            imgRot=rotateVectorImg2D(img,90);
                        case 5
                            % flip vertical
                            imgRot=img(end:-1:1,1:1:end,:);
                        case 6
                            % 90 deg right then flipped vert
                            imgRot=rotateVectorImg2D(img,-90);
                            imgRot=imgRot(end:-1:1,1:1:end,:);
                            
                        case 7
                            % flip horizontal
                            imgRot=img(1:1:end,end:-1:1,:);
                        case 8
                            % 90 deg left then flipped vert
                            imgRot=rotateVectorImg2D(img,90);
                            imgRot=imgRot(end:-1:1,1:1:end,:);
                            
   

    end
    
    end
