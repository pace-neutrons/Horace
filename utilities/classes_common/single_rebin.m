function [wout_x,wout_s,wout_e] = single_rebin(iax,win_x,win_s,win_e,win_xdist,xbounds,true_values,...
                                                rebin_hist_func,integrate_points_func,point_ave)
% Rebin dataset. Assumes that have already checked validity of input data.
%
%   >> wout = single_rebin(win,boundaries,true_values,point_ave)
%
%   iax             Axis index (1,2,3...) of rebin axis
%   win_x           Input rebin axis values (row vectore of bin boundaries or point values)
%   win_s           Signal values
%   win_e           Standard errors on signal
%   win_xdist       Distribution i.e. counts per unit axis interval (true), or just counts (false)
%   xbounds         Output rebin boundaries or descriptor of boundaries 
%                  (Note: these describe boundaries for the rebinning even if point data)
%   true_values     Nature of data contained in xbounds:
%                     true:  boundaries are the true values
%                     false: boundaries is rebin rescriptor
%   rebin_hist_func         Rebin function e.g. rebin_2d_x_hist
%   integrate_points_func   Point data integration function e.g. integrate_2d_y_points
%   point_ave       Averging method (point data only; ignored if histogram data)
%                     true:  Point everaging
%                     false: Trapezoidal integration

nx=numel(win_x);
sz=size(win_s);
if numel(sz)==2 && sz(2)==1
    oneD=true;
else
    oneD=false;
end
x_sz_repmat=sz; x_sz_repmat(iax)=1; % size to repmat a vector across the input or output data arrays
%---------------------------------------------------------------------------------------------
% Histogram data
if nx~=sz(iax)
    if true_values, wout_x=xbounds; else wout_x = bin_boundaries_from_descriptor (xbounds, win_x); end
    if win_xdist
        [wout_s, wout_e] = rebin_hist_func (win_x, win_s, win_e, wout_x);
    else
        % Get arrays of distribution of counts and errors
        if oneD
            dx_in=diff(win_x)';
            dx_out=diff(wout_x)';
        else
            dx_in=repmat(reshape(diff(win_x),[ones(1,iax-1),numel(win_x)-1]),x_sz_repmat);
            dx_out=repmat(reshape(diff(wout_x),[ones(1,iax-1),numel(wout_x)-1]),x_sz_repmat);
        end
        [wout_s, wout_e] = rebin_hist_func (win_x, win_s./dx_in, win_e./dx_in, wout_x);
        wout_s=wout_s.*dx_out;
        wout_e=wout_e.*dx_out;
    end
    
    %---------------------------------------------------------------------------------------------
    % Point data
else
    if true_values
        xbounds_true=xbounds;
    else
        if numel(win_x)>1
            xbounds_true=bin_boundaries_from_descriptor(xbounds, win_x);
        else    % effectively make ranges where dx=0 just one bin 
            xbounds_true=bin_boundaries_from_descriptor(xbounds, [xbounds(1),xbounds(end)]);
        end
    end
    if point_ave
        % Point averaging
        % Get bin index for each point along the rebin axis
        nb=numel(xbounds_true);
        ind=bin_index(win_x,xbounds_true,true);
        ok=(ind>0&ind<nb)';   % those elements in the new bins; column vector
        ind=ind(ok);          % keep only the elements in the new boundaries; column vector
        xsum=accumarray(ind,win_x(ok),[nb-1,1]);
        nout=accumarray(ind,ones(size(win_x(ok))),[nb-1,1]);
        keep=(nout~=0);
        nout=nout(keep);
        wout_x=xsum(keep)./nout;
        % Get bin index for each point in data arrays
        if oneD % Handle 1D data differently
            ysum=accumarray(ind,win_s(ok),[nb-1,1]);
            esum=accumarray(ind,(win_e(ok).^2),[nb-1,1]);
        else
            ok=repmat(reshape(ok,[ones(1,iax-1),numel(win_x)-1]),x_sz_repmat);
            ok=ok(:);         % make column vector
            indcell=cell(1,numel(sz));
            for id=1:numel(sz)
                if id~=iax
                    indcell{id}=1:sz(id);
                else
                    indcell(id)=ind;
                end
            end
            ind_grid=ndgridcell(indcell{:});
            ind=cat(numel(sz)+1,ind_grid{:});
            ind=reshape(ind,[numel(ind)/numel(sz),numel(sz)]);
            szout=sz; szout(iax)=nb-1;
            ysum=accumarray(ind,win_s(ok),szout);
            esum=accumarray(ind,(win_e(ok).^2),szout);
            % Normalise data in bins by number of contributing points
            clear('ok','ind_grid','ind');     % get rid of potentially large work arrays
            keep=repmat(reshape(keep,[ones(1,iax-1),numel(keep)]),x_sz_repmat);
            nout=repmat(reshape(nout,[ones(1,iax-1),numel(nout)]),x_sz_repmat);
        end
        wout_s=ysum(keep)./nout;
        wout_e=sqrt(esum(keep))./nout;
    else
        % Trapezoidal integration averaging
        if oneD
            dx_out=diff(xbounds_true)';
        else
            dx_out=repmat(reshape(diff(xbounds_true),[ones(1,iax-1),numel(xbounds_true)-1]),x_sz_repmat);
        end
        [wout_s,wout_e] = integrate_points_func (win_x, win_s, win_e, xbounds_true);
        wout_x=0.5*(xbounds_true(2:end)+xbounds_true(1:end-1));
        wout_s=wout_s./dx_out;
        wout_e=wout_e./dx_out;
    end
    
    %---------------------------------------------------------------------------------------------
end
