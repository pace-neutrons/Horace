function wout = single_rebin(win,xbounds,true_values,point_ave)
% Rebin dataset. Assumes that have already checked validity of input data.

ny=length(win.signal);
nx=length(win.x);
%---------------------------------------------------------------------------------------------
% Histogram data
if nx~=ny
    if win.x_distribution
        if true_values
            [wout_y,wout_e] = rebin_1d_hist (win.x, win.signal, win.error, xbounds);
            wout = IX_dataset_1d (xbounds, wout_y, wout_e, win.title, win.x_axis, win.s_axis, win.x_distribution);
        else
            [wout_x, wout_y,wout_e] = rebin_1d_hist_by_descriptor (win.x, win.signal, win.error, xbounds);
            wout = IX_dataset_1d (wout_x, wout_y, wout_e, win.title, win.x_axis, win.s_axis, win.x_distribution);
        end
    else
        % Get arrays of distribution of counts and errors
        xin_bins=diff(win.x);
        ytemp=win.signal./xin_bins;
        etemp=win.error./xin_bins;
        if true_values
            [ytemp, etemp] = rebin_1d_hist (win.x, ytemp, etemp, xbounds);
            xout_bins=diff(xbounds);
            ytemp=ytemp.*xout_bins;
            etemp=etemp.*xout_bins;
            wout = IX_dataset_1d (xbounds, ytemp, etemp, win.title, win.x_axis, win.s_axis, win.x_distribution);
        else
            [wout_x, ytemp, etemp] = rebin_1d_hist_by_descriptor (win.x, ytemp, etemp, xbounds);
            xout_bins=diff(wout_x);
            ytemp=ytemp.*xout_bins;
            etemp=etemp.*xout_bins;
            wout = IX_dataset_1d (wout_x, ytemp, etemp, win.title, win.x_axis, win.s_axis, win.x_distribution);
        end
    end

%---------------------------------------------------------------------------------------------    
% Point data
else
    if point_ave
        % Point averaging
    else
        % Trapezoidal integration averaging
    end
%     % Get boundaries for rebinning: Not very efficient, as also rebins data, but quick 'n easy way of getting boundaries
%     % IF DEBUG HERE, MAKE IDENTICAL CHANGES TO REGROUP IN POINT MODE.
%     if (nargin==2)
%         if (isa(v1,'spectrum'))      % check if second argument is also a spectrum
%             if length(v1.x)~=length(v1.y)   % is a histogram
%                 xtemp = v1.x;
%             else                            % is point data
%                 if length(v1.x)>1
%                     xtemp = boundaries(v1.x);
%                 else
%                     error ('ERROR: Spectrum providing boundaries is point data with only one point')
%                 end
%             end
%         elseif (isa(v1,'double'))    % check if second argument is a double array
%             xbounds = v1';
%             [xtemp,dum_out.y,dum_out.e] = spectrum_rebin_by_descriptor (w1.x, w1.y, w1.e, xbounds);
%         else
%             error ('Second argument must be a spectrum or real array (REBIN)')
%         end
%     elseif (nargin==3)              % check that the three additional arguments are all single numbers
%         if (isa(v1,'double') & isa(v2,'double') & length(v1)==1 & length(v2)==1)
%             xbounds=[v1;v2];
%         else
%             error ('Second and third arguments must be XLO, XHI (REBIN)')
%         end
%         [xtemp,dum_out.y,dum_out.e] = spectrum_rebin_by_descriptor (w1.x, w1.y, w1.e, xbounds);
%     elseif (nargin==4)              % check that the three additional arguments are all single numbers
%         if (isa(v1,'double') & isa(v2,'double') & isa(v3,'double') & length(v1)==1 & length(v2)==1 & length(v3)==1)
%             xbounds=[v1;v2;v3];
%         else
%             error ('Second, third and fourth arguments must be XLO, DEL, XHI (REBIN)')
%         end
%         [xtemp,dum_out.y,dum_out.e] = spectrum_rebin_by_descriptor (w1.x, w1.y, w1.e, xbounds);
%     else
%         error ('Check rebin arguments (REBIN)')
%     end
%         
%     ibin = bin_index (w1.x, xtemp);
%     np = length(xtemp)-1;
%     wout_x = zeros(np,1);
%     wout_y = zeros(np,1);
%     wout_e = zeros(np,1);
%     npix = zeros(np,1);
%     for i = find(ibin>0)
%         wout_x(ibin(i)) = wout_x(ibin(i)) + w1.x(i);
%         wout_y(ibin(i)) = wout_y(ibin(i)) + w1.y(i);
%         wout_e(ibin(i)) = wout_e(ibin(i)) + w1.e(i)^2;
%         npix(ibin(i)) = npix(ibin(i)) + 1;
%     end
%     mask = npix>0;
%     wout_x = wout_x(mask)./npix(mask);
%     wout_y = wout_y(mask)./npix(mask);
%     wout_e = sqrt(wout_e(mask))./npix(mask);    
    
%---------------------------------------------------------------------------------------------    
end

% wout = spectrum(wout_x, wout_y, wout_e, w1.title, w1.xlab, w1.ylab, w1.xunit, w1.distribution);
% wout=w1;
% wout = set_simple_xye(wout, wout_x, wout_y, wout_e);
        