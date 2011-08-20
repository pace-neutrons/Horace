function varargout = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,...
    rebin_hist_func,integrate_points_func,integrate_data,point_integration)
% Rebin dataset. Assumes that have already checked validity of input data.
%
%   >> wout = single_rebin_one_axis(iax,win_x,win_s,win_e,win_xdist,xbounds,true_values,...
%                                               rebin_hist_func,integrate_points_func,integrate_data,point_integration)
% OR
%   >> [wout_x,wout_s,wout_e] = single_rebin_one_axis(iax,win_x,win_s,win_e,win_xdist,xbounds,true_values,...
%                                               rebin_hist_func,integrate_points_func,integrate_data,point_integration)
% Input:
% -------
%   win             Input IX_dataset_nd object
%   iax             Array of axis indices (chosen from 1,2,3...) of rebin axes
%   xbounds         Output rebin boundaries or descriptor of boundaries for each axis (cell array of row vectors) 
%                  (Note: these describe boundaries for the rebinning even if point data)
%   true_values     Array of logical flags that give nature of data contained in xbounds:
%                     true:  boundaries are the true values
%                     false: boundaries is rebin rescriptor
%   rebin_hist_func         Handles to rebin functions e.g. rebin_2d_x_hist for each axis (cell array)
%   integrate_points_func   Handles to point data integration functions e.g. integrate_2d_y_points for each axis (cell array)
%   integrate_data          Integrate(true) or rebin (false)
%   point_integration       Array of averging method (point data only; ignored if histogram data)
%                             true:  Trapezoidal integration
%                             false: Point averaging
% Output:
% -------
% EITHER:
%   wout            Output IX_dataset_nd object
%   
% OR:
%   wout_x          Rebinned axis values
%   wout_s          Rebinned signal
%   wout_e          Rebinned errors
%
% Note that integration is the same as rebinning for non-distribution histogram data.
% For point data, integration requires multiplication by the bin widths (point integration) or
% number of contributing points (point averagin) regardless of the data being distribution
% or not. This is because it is assumed that point data is sampling a function.

ndim=dimensions(win);
nrebin=numel(iax);
wout_x=cell(1,nrebin);
% Need to treat IX_dataset_1d in special way: because data is stored as row vectors
ax=axis(win,iax(1));
[wout_x{1},wout_s,wout_e] = rebin_one_axis(ndim,iax(1),ax.values,win.signal,win.error,ax.distribution,xbounds{1},true_values(1),...
                                            rebin_hist_func{1},integrate_points_func{1},integrate_data,point_integration(1));
for i=2:nrebin
    ax=axis(win,iax(i));
    [wout_x{i},wout_s,wout_e] = rebin_one_axis(ndim,iax(i),ax.values,wout_s,wout_e,ax.distribution,xbounds{i},true_values(i),...
                                                rebin_hist_func{i},integrate_points_func{i},integrate_data,point_integration(i));
end
if nargout==1
    if ~integrate_data
        varargout{1}=xsigerr_set(win,iax,wout_x,wout_s,wout_e);
    else
        varargout{1}=xsigerr_set(win,iax,wout_x,wout_s,wout_e,false);   % reset distribution to false along integration axes
    end
else
    varargout{1}=wout_x;
    varargout{2}=wout_s;
    varargout{3}=wout_e;
end

%============================================================================================================
function [wout_x,wout_s,wout_e] = rebin_one_axis(ndim,iax,win_x,win_s,win_e,win_xdist,xbounds,true_values,...
                                                rebin_hist_func,integrate_points_func,integrate_data,point_integration)
% Rebin dataset. Assumes that have already checked validity of input data.
%
%   >> [wout_x,wout_s,wout_e] = single_rebin_one_axis(iax,win_x,win_s,win_e,win_xdist,xbounds,true_values,...
%                                               rebin_hist_func,integrate_points_func,point_integration)
%
% Input:
% -------
%   ndim            Dimensionality of IX_dataset_nd object
%   iax             Array of axis indices (chosen from 1,2,3...) of rebin axes
%   win_x           Input x-values
%   win_s           Input signal
%   win_e           Input error
%   xbounds         Output rebin boundaries or descriptor of boundaries 
%                  (Note: these describe boundaries for the rebinning even if point data)
%   true_values     Nature of data contained in xbounds:
%                     true:  xbounds contains the true x-axis rebin values
%                     false: xbounds contains a rebin rescriptor
%   rebin_hist_func         Rebin function e.g. rebin_2d_x_hist
%   integrate_points_func   Point data integration function e.g. integrate_2d_y_points
%   integrate_data          Integrate(true) or rebin (false)
%   point_integration       Averging method (point data only; ignored if histogram data)
%                             true:  Trapezoidal integration
%                             false: Point averaging
%
% Output:
% -------
%   wout_x          Rebinned axis values
%   wout_s          Rebinned signal
%   wout_e          Rebinned errors
%
% Note that integration is the same as rebinning for non-distribution histogram data.
% For point data, integration requires multiplication by the bin widths (point integration) or
% number of contributing points (point averagin) regardless of the data being distribution
% or not. This is because it is assumed that point data is sampling a function.

% Catch case when no rebin required
if isempty(xbounds) || (true_values && numel(xbounds)==numel(win_x) && all(xbounds==win_x))
    wout_x=win_x;
    wout_s=win_s;
    wout_e=win_e;
    return
end

% Now treat case when new bins
nx=numel(win_x);
sz=size(win_s);
if ndim==1
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
        if integrate_data
            if oneD
                dx_out=diff(wout_x)';
            else
                dx_out=repmat(reshape(diff(wout_x),[ones(1,iax-1),numel(wout_x)-1,1]),x_sz_repmat);
            end
            wout_s=wout_s.*dx_out;
            wout_e=wout_e.*dx_out;
        end
    else
        % Get arrays of distribution of counts and errors
        if oneD
            dx_in=diff(win_x)';
            dx_out=diff(wout_x)';
        else
            dx_in=repmat(reshape(diff(win_x),[ones(1,iax-1),numel(win_x)-1,1]),x_sz_repmat);
            dx_out=repmat(reshape(diff(wout_x),[ones(1,iax-1),numel(wout_x)-1,1]),x_sz_repmat);
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
    if ~point_integration
        % Point averaging
        % Get bin index for each point along the rebin axis
        nb=numel(xbounds_true);
        ind=bin_index(win_x,xbounds_true,true)'; % column vector
        ok=(ind>0&ind<nb);      % those elements in the new bins; column vector
        ind=ind(ok);            % keep only the elements in the new boundaries; column vector
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
            ok=repmat(reshape(ok,[ones(1,iax-1),numel(win_x),1]),x_sz_repmat);
            ok=ok(:);         % make column vector
            indcell=cell(1,numel(sz));
            for id=1:numel(sz)
                if id~=iax
                    indcell{id}=1:sz(id);
                else
                    indcell{id}=ind;
                end
            end
            ind_grid=ndgridcell(indcell);
            ind=cat(numel(sz)+1,ind_grid{:});
            ind=reshape(ind,[numel(ind)/numel(sz),numel(sz)]);
            szout=sz; szout(iax)=nb-1;
            ysum=accumarray(ind,win_s(ok),szout);
            esum=accumarray(ind,(win_e(ok).^2),szout);
            % Normalise data in bins by number of contributing points
            clear('ok','ind_grid','ind');     % get rid of potentially large work arrays
            keep=repmat(reshape(keep,[ones(1,iax-1),numel(keep),1]),x_sz_repmat);
            nout=repmat(reshape(nout,[ones(1,iax-1),numel(nout),1]),x_sz_repmat);
        end
        if ~integrate_data
            wout_s=reshape(ysum(keep),size(nout))./nout;    % subscripting with keep turns output into a column vector
            wout_e=sqrt(reshape(esum(keep),size(nout)))./nout;
        else
            wout_s=reshape(ysum(keep),size(nout));    % subscripting with keep turns output into a column vector
            wout_e=sqrt(reshape(esum(keep),size(nout)));
        end
    else
        % Trapezoidal integration averaging
        if oneD
            dx_out=diff(xbounds_true)';
        else
            dx_out=repmat(reshape(diff(xbounds_true),[ones(1,iax-1),numel(xbounds_true)-1,1]),x_sz_repmat);
        end
        [wout_s,wout_e] = integrate_points_func (win_x, win_s, win_e, xbounds_true);
        wout_x=0.5*(xbounds_true(2:end)+xbounds_true(1:end-1));
        if ~integrate_data
            wout_s=wout_s./dx_out;
            wout_e=wout_e./dx_out;
        end
    end
    
%---------------------------------------------------------------------------------------------
end
