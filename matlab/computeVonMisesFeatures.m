function [a,k,mu,adjrsquare]=computeVonMisesFeatures(hist_counts,hist_centers)


    
    
    theta=deg2rad(reshape(hist_centers,length(hist_centers),1));
    rho=reshape(hist_counts,length(hist_counts),1);

    vmEqn='a*exp(k*cos(2*(x-mu)))./(2*pi*besseli(0,k))';
    [vm_fit,vm_gof,vm_out]=fit(theta, rho,vmEqn,'Lower',[0,0,-pi/2],'Upper',[Inf,Inf,pi/2]);



    a=vm_fit.a;
    k=vm_fit.k;
    mu=vm_fit.mu;
    adjrsquare=vm_gof.adjrsquare;
    
end
