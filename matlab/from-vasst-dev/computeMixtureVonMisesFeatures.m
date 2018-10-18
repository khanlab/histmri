function [a1,k1,mu1,a2,k2,mu2,adjrsquare]=computeMixtureVonMisesFeatures(hist_counts,hist_centers)


    
    
    theta=deg2rad(reshape(hist_centers,length(hist_centers),1));
    rho=reshape(hist_counts,length(hist_counts),1);

    
    vmMixEqn='a1*exp(k1*cos(2*(x-mu1)))./(2*pi*besseli(0,k1))+a2*exp(k2*cos(2*(x-mu2)))./(2*pi*besseli(0,k2))';
    [vm_fit,vm_gof,vm_out]=fit(theta, rho,vmMixEqn,'Lower',[0,0,0,0,-pi/2,-pi/2],'Upper',[Inf,Inf,Inf,Inf,pi/2,pi/2]);
    
    a1=vm_fit.a1;
    k1=vm_fit.k1;
    mu1=vm_fit.mu1;
    a2=vm_fit.a2;
    k2=vm_fit.k2;
    mu2=vm_fit.mu2;
    adjrsquare=vm_gof.adjrsquare;
    
end
