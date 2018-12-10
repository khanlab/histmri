function [hist_counts,hist_centers,major_angle,mean_anisotropy,mean_trace]  = computeStructuralTensor(img,sigma)


n = 256;
f = image_resize(double(img),n,n);
%f = rescale( sum(f,3) );
f=abs(255-sum(f,3))./255;

cconv = @(f,h)real(ifft2(fft2(f).*repmat(fft2(h),[1 1 size(f,3)])));
t = [0:n/2 -n/2+1:-1];
[X2,X1] = meshgrid(t,t);
normalize = @(h)h/sum(h(:));
h = @(sigma)normalize( exp( -(X1.^2+X2.^2)/(2*sigma^2) ) );
blur = @(f,sigma)cconv(f,h(sigma));

options.order = 2;
nabla = @(f)grad(f,options); 

tensorize = @(u)cat(3, u(:,:,1).^2, u(:,:,2).^2, u(:,:,1).*u(:,:,2));
rotate = @(T)cat(3, T(:,:,2), T(:,:,1), -T(:,:,3));

T = @(f,sigma)blur( tensorize( nabla(f) ), sigma);
options.sub = 8;

%sigma=2;

% plot it:

% sigmas=2:2:10;
% 
% figure;
% for i=1:length(sigmas)
%     sigma=sigmas(i);
% subplot(1,length(sigmas),i);
%     plot_tensor_field(rotate(T(f,sigma)), f, options);
% end



delta = @(S)(S(:,:,1)-S(:,:,2)).^2 + 4*S(:,:,3).^2;
eigenval = @(S)deal( ...
    (S(:,:,1)+S(:,:,2)+sqrt(delta(S)))/2,  ...
    (S(:,:,1)+S(:,:,2)-sqrt(delta(S)))/2 );
%Compute (at each location x) the leading eigenvector
normalize = @(u)u./repmat(sqrt(sum(u.^2,3)), [1 1 2]);
eig1 = @(S)normalize( cat(3,2*S(:,:,3), S(:,:,2)-S(:,:,1)+sqrt(delta(S)) ) );
ortho = @(u)deal(u, cat(3,-u(:,:,2), u(:,:,1)));
eigbasis = @(S)ortho(eig1(S));


%Compute the eigendecomposition of T(+ve definate matrix)
S = T(f,sigma);
[lambda1,lambda2] = eigenval(S);
[e1,e2] = eigbasis(S);

trace=S(:,:,1)+S(:,:,2);
%T = perform_tensor_decomp(e1,e2,lambda1,lambda2); % T will a 4-D variable


X = e1(:,:,1); % major eigenvector X-component
Y = e1(:,:,2); % major eigenvector Y-component
angle = atand(Y./X); %angle of the major eigen-vector
%figure; histogram(angle);

%theta=0.5.*atand(2.*(S(:,:,3)./(S(:,:,2)-S(:,:,1))));


%converts to polar histogram, calulate the ODF of the major eigen-vector
angle = angle(:);


%rose(deg2rad(angle));
angle_minus180=angle-180;
%figure; rose(deg2rad([angle; angle_minus180]));
%figure; rose(deg2rad([angle; angle_minus180]),60);



anisotropy=abs(lambda1(:)-lambda2(:))./(lambda1(:)+lambda2(:)); % anisotropic or coherence

%filt_angle=angle(anisotropy>0.8);
filt_angle=angle(trace>0.001);

%figure; hist(angle(anisotropy>0.0030),60);
%figure; rose(deg2rad([filt_angle; filt_angle-180]),60);

%[rhist_counts,rhist_centers]=hist(angle,64);

[hist_counts,hist_centers]=hist(filt_angle,64);

%normalize by total number of pixels in ST image (N^2)
hist_counts=hist_counts./(n^2);

[max_count,max_ind]=max(hist_counts);
max_angle=hist_centers(max_ind);



hist_counts=hist_counts;
hist_centers=hist_centers;
major_angle=max_angle;
mean_anisotropy=mean(anisotropy);
mean_trace=mean(trace(:));
end

