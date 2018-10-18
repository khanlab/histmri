
function generateVonMisesFeatures (in_mat,out_mat)
warning('off','all')
load(in_mat);

%  compute von mises features

vm_a=zeros(size(hist_counts));
vm_k=zeros(size(hist_counts));
vm_mu=zeros(size(hist_counts));
vm_adjrsquare=zeros(size(hist_counts));


vm_a1=zeros(size(hist_counts));
vm_k1=zeros(size(hist_counts));
vm_mu1=zeros(size(hist_counts));
vm_a2=zeros(size(hist_counts));
vm_k2=zeros(size(hist_counts));
vm_mu2=zeros(size(hist_counts));
vm_mix_adjrsquare=zeros(size(hist_counts));


trace=featureVec(:,:,3);

for i=1:size(hist_counts,1)
    for j=1:size(hist_counts,2)
 

if (trace(i,j)<1e-3)
 continue;
end

       
try
        [vm_a(i,j),vm_k(i,j),vm_mu(i,j),vm_adjrsquare(i,j)]=computeVonMisesFeatures(hist_counts{i,j},hist_centers{i,j});

        [vm_a1(i,j),vm_k1(i,j),vm_mu1(i,j),vm_a2(i,j),vm_k2(i,j),vm_mu2(i,j),vm_mix_adjrsquare(i,j)]=computeMixtureVonMisesFeatures(hist_counts{i,j},hist_centers{i,j});

catch

		
	continue;
end

    end
i
end


%for feature vec, need to convert angles to degrees

vm_mu=rad2deg(vm_mu);
vm_mu1=rad2deg(vm_mu1);
vm_mu2=rad2deg(vm_mu2);

features={'a','k','mu','rsq','a1','a2','k1','k2','mu1','mu2','mix_rsq'};
featureVec=zeros(size(hist_counts,1),size(hist_counts,2),length(features));
featureVec(:,:,1)=vm_a;
featureVec(:,:,2)=vm_k;
featureVec(:,:,3)=vm_mu;
featureVec(:,:,4)=vm_adjrsquare;
featureVec(:,:,5)=vm_a1;
featureVec(:,:,6)=vm_a2;
featureVec(:,:,7)=vm_k1;
featureVec(:,:,8)=vm_k2;
featureVec(:,:,9)=vm_mu1;
featureVec(:,:,10)=vm_mu2;
featureVec(:,:,11)=vm_mix_adjrsquare;

save(out_mat,'features','featureVec');
end
