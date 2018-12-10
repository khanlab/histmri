function out_vec=reorientVecField_mat( in_vec, xfm,do_normalize)
%mult


N=numel(in_vec)/3;
v=zeros(3,N);
v(1,:)=reshape(in_vec(:,:,:,1),1,N);
v(2,:)=reshape(in_vec(:,:,:,2),1,N);
v(3,:)=reshape(in_vec(:,:,:,3),1,N);

%mat mult
rv=xfm*v;

if (do_normalize==1)
%normalize to unit vectors
vlen=sqrt(rv(1,:).^2+ rv(2,:).^2+rv(3,:).^2);
rv(1,:)=rv(1,:)./vlen;
rv(2,:)=rv(2,:)./vlen;
rv(3,:)=rv(3,:)./vlen;
end

%save out
for i=1:3
out_vec(:,:,:,i)=reshape(rv(i,:),size(in_vec,1),size(in_vec,2),size(in_vec,3));
end

end