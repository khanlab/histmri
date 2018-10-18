function imgRot = rotateVectorImg2D ( img,degrees)

angle=degrees*pi/180;
rotmat=[ cos(angle),sin(angle),0; -sin(angle),cos(angle),0; 0 0 1];

for i=1:3
    imgRot(:,:,i)=imrotate(img(:,:,i),degrees);  
end


N=numel(imgRot)/3;
v=zeros(3,N);
v(1,:)=reshape(imgRot(:,:,1),1,N);
v(2,:)=reshape(imgRot(:,:,2),1,N);
v(3,:)=reshape(imgRot(:,:,3),1,N);

%mat mult
rv=rotmat*v;

for i=1:3
imgRot(:,:,i)=reshape(rv(i,:),size(imgRot,1),size(imgRot,2),1);
end

end