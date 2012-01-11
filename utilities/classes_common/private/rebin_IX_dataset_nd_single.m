function [wout,ok_rebin,mess] = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,is_descriptor,...
                                                            integrate_data,point_integration,use_mex,force_mex)
% Rebin dataset. Assumes that have already checked validity of input data.
%
%   >> [wout,ok_rebin,mess] = rebin_IX_dataset_nd_single(win,iax,xbounds,true_values,is_descriptor,...
%                                                           integrate_data,point_integration,use_mex,force_mex)
%
% Input:
% -------
%   win                 Input IX_dataset_nd object
%   iax                 Array of axis indices (chosen from 1,2,3...) of rebin axes
%   xbounds             Rebin boundaries or descriptor of boundaries for each axis (cell array of row vectors)
%                      (Note: these describe boundaries for the rebinning even if point data)
%   true_values         Array of logical flags that give nature of data contained in xbounds:
%                         true:  boundaries are the true values
%                         false: boundaries given by a rebin rescriptor, or contain -Inf &/or Inf
%   is_descriptor       Array of logical flags that define rebin description
%                         true:  rebin descriptor
%                         false: bin boundaries 
%   integrate_data      Integrate(true) or rebin (false)
%   point_integration   Array of averging method for each axis (point data only; ignored if histogram data)
%                         true:  Trapezoidal integration
%                         false: Point averaging
%   use_mex             Use mex files
%                         true:  Try to mex functions first
%                         false: Use matlab functions
%   force_mex           Force mex files (only relevant if use_mex==true)
%                         true:  Throw error if mex function fails
%                         false: Use matlab function if mex function fails
%
% Output:
% -------
%   wout                Output IX_dataset_nd object
%   ok_rebin            True if operation successful; false if not
%   mess                Error message if not ok; empty otherwise
%
% Note that integration is the same as rebinning for non-distribution histogram data.
% For point data, integration requires multiplication by the bin widths (point integration) or
% number of contributing points (point averagin) regardless of the data being distribution
% or not. This is because it is assumed that point data is sampling a function.

ndim=dimensions(win);
nrebin=numel(iax);
wout_x=cell(1,nrebin);

ax=axis(win,iax(1));
[wout_x{1},wout_s,wout_e,ok_rebin,mess] = rebin_one_axis(ndim,iax(1),ax.values,win.signal,win.error,ax.distribution,...
                                                xbounds{1},true_values(1),is_descriptor(1),...
                                                integrate_data,point_integration(1),use_mex,force_mex);
if ~ok_rebin, wout=IX_dataset_nd(ndim); return, end

for i=2:nrebin
    ax=axis(win,iax(i));
    [wout_x{i},wout_s,wout_e,ok_rebin,mess] = rebin_one_axis(ndim,iax(i),ax.values,wout_s,wout_e,ax.distribution,...
                                                xbounds{i},true_values(i),is_descriptor(i),...
                                                integrate_data,point_integration(i),use_mex,force_mex);
    if ~ok_rebin, wout=IX_dataset_nd(ndim); return, end
end

if ~integrate_data
    wout=xsigerr_set(win,iax,wout_x,wout_s,wout_e);         % distribution is same as input data
else
    wout=xsigerr_set(win,iax,wout_x,wout_s,wout_e,false);   % reset distribution to false along integration axes
end


%============================================================================================================
function [wout_x,wout_s,wout_e,ok_rebin,mess] = rebin_one_axis(ndim,iax,win_x,win_s,win_e,win_xdist,xbounds,true_values,is_descriptor,...
    integrate_data,point_integration,use_mex,force_mex)
% Rebin dataset. Assumes that have already checked validity of input data.
%
%   >> [wout_x,wout_s,wout_e,ok_rebin,mess] = rebin_one_axis(ndim,iax,win_x,win_s,win_e,win_xdist,xbounds,true_values,is_decsriptor,...
%                                               integrate_data,point_integration,use_mex,force_mex)
%
% Input:
% -------
%   ndim                Dimensionality of IX_dataset_nd object
%   iax                 Axis indices (chosen from 1,2,3...) of rebin axes
%   win_x               Input x-values
%   win_s               Input signal
%   win_e               Input error
%   xbounds             Output rebin boundaries or descriptor of boundaries
%                      (Note: these describe boundaries for the rebinning even if point data)
%   true_values         Nature of data contained in xbounds:
%                         true:  xbounds contains the true x-axis rebin values
%                         false: xbounds is a rebin rescriptor, or contains bin boundaries that have -Inf &/or Inf
%   is_descriptor       Nature of rebin description
%                         true:  rebin descriptor
%                         false: bin boundaries 
%   integrate_data      Integrate(true) or rebin (false)
%   point_integration   Averging method (point data only; ignored if histogram data)
%                         true:  Trapezoidal integration
%                         false: Point averaging
%   use_mex             Use mex files
%                         true:  Try to mex functions first
%                         false: Use matlab functions
%   force_mex           Force mex files (only relevant if use_mex==true)
%                         true:  Throw error if mex function fails
%                         false: Use matlab function if mex function fails
%
% Output:
% -------
%   wout_x              Rebinned axis values
%   wout_s              Rebinned signal
%   wout_e              Rebinned errors
%   ok_rebin            True if operation successfull; false if not
%   mess                Error message if not ok; empty otherwise
%
% Note that integration is the same as rebinning for non-distribution histogram data.
% For point data, integration requires multiplication by the bin widths (point integration) or
% number of contributing points (point averagin) regardless of the data being distribution
% or not. This is because it is assumed that point data is sampling a function.

ok_rebin=true;
mess='';

nx=numel(win_x);
sz=size(win_s);
sz_full=[sz,ones(1,ndim-numel(sz))];    % this works even if ndim=1, i.e. ones(1,-1)==[]
if ndim==1
    oneD=true;
else
    oneD=false;
end
x_sz_repmat=sz; x_sz_repmat(iax)=1;     % size to repmat a vector across the input or output data arrays

%---------------------------------------------------------------------------------------------
% Histogram data
if nx~=sz_full(iax)
    % Catch case when no data along integration axis, then cannot integrate data. We want to handle each axis independently,
    % so even tho we could choose to ignore this case if there are no data points along another axis, we choose to throw an
    % error all the same.
    if sz_full(iax)==0
        wout_x=[]; wout_s=[]; wout_e=[];
        ok_rebin=false; mess=['No data points along axis ',num2str(iax),': cannot perform rebin or integration of histogram data along this axis']; return
    end
    % Get new bin boundaries
    if true_values
        wout_x=xbounds;
    else
        [xb,ok_rebin,mess]=rebin_boundaries_description_resolve_inf(xbounds,is_descriptor,win_x(1),win_x(end));
        if ~ok_rebin, wout_x=[]; wout_s=[]; wout_e=[]; return, end
        if is_descriptor
            if ~isempty(xb)
                wout_x=bin_boundaries_from_descriptor (xb, win_x, use_mex, force_mex);  % also scalar wout_x a possibility here i.e. no data points left
            else
                wout_x=win_x;
            end
        else
            wout_x=xb;
        end
    end
    % Catch case of one of the other axes having no data points, or scalar wout_x. We have the new x values, but cannot evaluate data values
    if any(sz==0) || isscalar(wout_x)
        sz_full(iax)=numel(wout_x)-1;
        wout_s=zeros(sz_full);
        wout_e=zeros(sz_full);
        return
    end
    % Compute rebinned output signal and error arrays
    rebin_hist_func = rebin_hist_func_handle(ndim,iax);
    bounds_unchanged=(numel(wout_x)==numel(win_x) && all(wout_x==win_x));
    if win_xdist
        if bounds_unchanged     % save expensive and unnecessary calculation
            wout_s=win_s;
            wout_e=win_e;
        else
            [wout_s, wout_e] = rebin_hist_func (win_x, win_s, win_e, wout_x, use_mex, force_mex);
        end
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
        if bounds_unchanged     % save expensive and unnecessary calculation
            wout_s=win_s;
            wout_e=win_e;
        else
            if oneD
                dx_in=diff(win_x)';
                dx_out=diff(wout_x)';
            else
                dx_in=repmat(reshape(diff(win_x),[ones(1,iax-1),numel(win_x)-1,1]),x_sz_repmat);
                dx_out=repmat(reshape(diff(wout_x),[ones(1,iax-1),numel(wout_x)-1,1]),x_sz_repmat);
            end
            [wout_s, wout_e] = rebin_hist_func (win_x, win_s./dx_in, win_e./dx_in, wout_x, use_mex, force_mex);
            wout_s=wout_s.*dx_out;
            wout_e=wout_e.*dx_out;
        end
    end
    
%---------------------------------------------------------------------------------------------
% Point data
else
    if true_values
        xbounds_true=xbounds;
    else
        if numel(win_x)>0   % No point data will not need xbounds_true in either point integration option
            [xb,ok_rebin,mess]=rebin_boundaries_description_resolve_inf(xbounds,is_descriptor,win_x(1),win_x(end));
            if ~ok_rebin, wout_x=[]; wout_s=[]; wout_e=[]; return, end
            if is_descriptor
                win_xb=bin_boundaries_simple(win_x);
                if ~isempty(xb)
                    xbounds_true=bin_boundaries_from_descriptor (xb, win_xb, use_mex, force_mex);  % also scalar wout_x a possibility here i.e. no data points left
                else
                    xbounds_true=win_xb;
                end
            else
                xbounds_true=rebin_boundaries_description_resolve_infinities(xbounds,is_descriptor,win_x(1),win_x(end));
                if numel(xbounds_true)==2 && xbounds_true(2)==xbounds_true(1) && numel(win_x)==1
                    xbounds_true=bin_boundaries_simple(xbounds_true(1));    % catch case of just one point (if more than one point at same axis value, that is an error)
                end
            end
            if any(diff(win_x)<=0)
                wout_x=[]; wout_s=[]; wout_e=[];
                ok_rebin=false; mess=['One or more output bins has zero width along axis ',num2str(iax),': cannot perform rebin or integration of point data along this axis']; return
            end
        end
    end

    if ~point_integration
        % Point averaging
        % ---------------
        % If already no points along this axes, then nothing to do
        if numel(win_x)==0
            wout_x=win_x;
            wout_s=win_s;
            wout_e=win_e;
            return
        end
        % Catch case of no output bin (will have arisen if an infinity was resolved into the new bins lying outside the data range)
        if numel(xbounds_true)==1
            sz_full(iax)=0;
            wout_x=zeros(1,0);
            wout_s=zeros(sz_full);
            wout_e=zeros(sz_full);
            return
        end
        % Get bin index for each point along the rebin axis
        nb=numel(xbounds_true);
        ind=bin_index(win_x,xbounds_true,true)'; % column vector
        ok=(ind>0&ind<nb);      % those elements in the new bins; column vector
        ind=ind(ok);            % keep only the elements in the new boundaries; column vector
        % Catch case of no points in the new bins - no need to perform any more calculations
        if isempty(ind)     
            sz_full(iax)=0;
            wout_x=zeros(1,0);
            wout_s=zeros(sz_full);
            wout_e=zeros(sz_full);
            return
        end
        xsum=accumarray(ind,win_x(ok),[nb-1,1]);
        nout=accumarray(ind,ones(size(win_x(ok))),[nb-1,1]);
        keep=(nout~=0);
        nout=nout(keep);
        wout_x=xsum(keep)./nout;
        % Catch case that there are already no points along one of the other axes, now that we have the new x-values along this axis
        if any(sz==0)
            sz_full(iax)=numel(wout_x);
            wout_s=zeros(sz_full);
            wout_e=zeros(sz_full);
            return
        end
        % Get bin index for each point in data arrays
        if oneD % Handle 1D data differently
            ysum=accumarray(ind,win_s(ok),[nb-1,1]);
            esum=accumarray(ind,(win_e(ok).^2),[nb-1,1]);
            wout_s=ysum(keep)./nout;    % subscripting with keep turns output into a column vector
            wout_e=sqrt(esum(keep))./nout;
            if integrate_data
                dx_out=diff(xbounds_true)';
                wout_s=wout_s.*dx_out(keep);
                wout_e=wout_e.*dx_out(keep);
            end
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
            % Replicate and reshape keep and nout arrays
            clear('ok','ind_grid','ind');     % get rid of potentially large work arrays
            keep=repmat(reshape(keep,[ones(1,iax-1),numel(keep),1]),x_sz_repmat);
            nout=repmat(reshape(nout,[ones(1,iax-1),numel(nout),1]),x_sz_repmat);
            % Normalise data in bins by number of contributing points
            wout_s=reshape(ysum(keep),size(nout))./nout;    % subscripting with keep turns output into a column vector
            wout_e=sqrt(reshape(esum(keep),size(nout)))./nout;
            if integrate_data
                dx_out=repmat(reshape(diff(xbounds_true),[ones(1,iax-1),numel(xbounds_true)-1,1]),x_sz_repmat);
                wout_s=wout_s.*reshape(dx_out(keep),size(nout));
                wout_e=wout_e.*reshape(dx_out(keep),size(nout));
            end
        end
    else
        % Trapezoidal integration averaging
        % ---------------------------------
        % Catch common problem of zero or one data point on axis; integration is not possible. This must consitute an error:
        % there is no way assign a signal. One may think that is there is no signal along another axis then one should
        % be able to assign the number of points along this axis because the signal array will have no elements, so the
        % fact that the value of the data points is undefined. However, we should assign on the basis of what we would do
        % if all other axes were not empty.
        if numel(win_x)==0
            wout_x=[]; wout_s=[]; wout_e=[];
            ok_rebin=false; mess=['No data points along axis ',num2str(iax),': cannot perform rebin or integration of point data along this axis']; return
        elseif numel(win_x)==1
            wout_x=[]; wout_s=[]; wout_e=[];
            ok_rebin=false; mess=['Only one data point along axis ',num2str(iax),': cannot perform rebin or integration of point data along this axis']; return
        end
        
        % Catch case of no output bin (will have arisen if an infinity was resolved into the new bins lying outside the data range)
        if numel(xbounds_true)==1
            sz_full(iax)=0;
            wout_x=zeros(1,0);
            wout_s=zeros(sz_full);
            wout_e=zeros(sz_full);
            return
        end
        
        wout_x=0.5*(xbounds_true(2:end)+xbounds_true(1:end-1));

        % Catch case of one of the other axes having no data points. We have the new x values, but cannot evaluate data values
        if any(sz==0)
            sz_full(iax)=numel(wout_x);
            wout_s=zeros(sz_full);
            wout_e=zeros(sz_full);
            return
        end
        
        % Perform integration
        integrate_points_func = integrate_points_func_handle(ndim,iax);
        if oneD
            dx_out=diff(xbounds_true)';
        else
            dx_out=repmat(reshape(diff(xbounds_true),[ones(1,iax-1),numel(xbounds_true)-1,1]),x_sz_repmat);
        end
        [wout_s,wout_e] = integrate_points_func (win_x, win_s, win_e, xbounds_true, use_mex, force_mex);
        if ~integrate_data
            wout_s=wout_s./dx_out;
            wout_e=wout_e./dx_out;
        end
    end
    
%---------------------------------------------------------------------------------------------
end
