function threshold = getStainThreshold(xout,counts,stain_type)


[xData, yData] = prepareCurveData( xout, counts );


%spline fit:
ft = fittype( 'smoothingspline' );
opts = fitoptions( ft );
opts.SmoothingParam = 0.1;

% Fit model to data.
[fitresult, gof(1)] = fit( xData, yData, ft, opts );

%compute zeros of derivative to find extrema
extrema_list=fnzeros( fnder(fitresult.p));

%use 2nd deriv to determine if minima/maxima
secderiv=fnval(fnder(fitresult.p,2),extrema_list(1,:));
minima_list=extrema_list(1,secderiv>0);
maxima_list=extrema_list(1,secderiv<0);





switch stain_type
    case {'NEUN'}
     %   disp('NEUN threshold');
        
        
        %only keep minima occuring after the 1st maxima
        minima_list=minima_list(minima_list>maxima_list(1));
        
        interval=xout<minima_list(1)& xout>maxima_list(1);
        
        fn_interval=fnval(fitresult.p,xout(interval));
        %normalize fn_interval from 0-1
        fn_interval=fn_interval-fn_interval(end);
        fn_interval=fn_interval./fn_interval(1);
        
        %get x-value where histogram is 5% of peak (i.e. cover 95%).
        x_interval=xout(interval);
        threshold=x_interval(fn_interval<0.05);
        threshold=threshold(1);
        
        
%         %plot region of histogram for quality control checking of threshold
%         interval=xout<minima_list(1);
%         xdata=xout(interval);
%         ydata=fnval(fitresult.p,xout(interval));
%        
%         figure; 
%         subplot(2,1,1);
%         plot(xdata,ydata,xdata,counts(interval));
%         xthr=find(xdata==threshold);
%         ythr=ydata(xthr);
%         hold on;
%         scatter(threshold,ythr,200,'rx');
%        
%         subplot(2,1,2);
%         plot(xout,fnval(fitresult.p,xout),xout,counts);
%         xthr=find(xdata==threshold);
%         ythr=ydata(xthr);
%         hold on;
%         scatter(threshold,ythr,200,'rx');
%         
%        
        
        
        
    case 'GFAP'
        
   %     disp('GFAP threshold');
       
        %interval from beginning to 1st peak
        interval=xout>0 & xout<maxima_list(1);
        
        fn_interval=fnval(fitresult.p,xout(interval));
        %normalize fn_interval from 0-1
        fn_interval=fn_interval-fn_interval(1);
        fn_interval=fn_interval./fn_interval(end);
        
        %get x-value where histogram is 50% of peak 
        x_interval=xout(interval);
        threshold=x_interval(fn_interval<0.5);
        threshold=threshold(end);
        
%     case 'LUX'
%         disp('LFB staining');
     otherwise
        disp('Unknown staining!');
        exit 0
        
end

end
