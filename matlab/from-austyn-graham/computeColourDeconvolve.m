
function out_img=computeColourDeconvolve(in_img,MOD)


% MOD is correct at this point

%now to apply to RGB:

% added +1 to avoid log(0) becoming Inf - Aug 30,2016

od_img=- ( 255.*log(double(in_img+1)./255) ./ log(255) );

%out_img=zeros(size(od_img));
D=inv(MOD)';


%out_img=exp(-(out_img-255.0)*log(255)/255);

% vectorized version:

rs_od=reshape(od_img,size(od_img,1)*size(od_img,2),3)';
rs_out=D*rs_od;
out_img=reshape(rs_out',size(od_img,1),size(od_img,2),3);
out_img=exp(-(out_img-255.0)*log(255)/255);

end