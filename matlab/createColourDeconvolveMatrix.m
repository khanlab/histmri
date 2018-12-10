function MOD=createColourDeconvolveMatrix(in_mod)


%in_mod=[ 0.650, 0.704, 0.286;  %Haem
%    0.268, 0.570, 0.776;  %DAB
%    0, 0, 0];

MOD=in_mod;

%normalize vector length
for i=1:3
    len=norm(MOD(i,:));
    if(len~=0)
    MOD(i,:)=MOD(i,:)./len;
    end
end


if  norm(MOD(2,:))==0
    MOD(2,1)=MOD(1,3);
    MOD(2,2)=MOD(1,2);
    MOD(2,3)=MOD(1,1);
end

if  norm(MOD(3,:))==0
    
    for i=1:3
        
    if(MOD(1,i)^2+MOD(2,i)^2 >1)
         MOD(3,i)=0;
    else
        MOD(3,i)=sqrt(1-MOD(1,i)^2-MOD(2,i)^2);
    end
        
    end
end

%normalize 3rd
MOD(3,:)=MOD(3,:)./norm(MOD(3,:));

%make zero just really small
MOD(MOD==0)=0.001;


end