function wout = rebin_ref(win, varargin)
% Rebin an IX_dataset_1d object or array of IX_dataset_1d objects along the x-axis
% *** TO BE RETAINED FOR TESTING PURPOSES ***
%
%   >> wout = rebin(win, xlo, xhi)      % keep data between xlo and xhi, retaining existing bins
%
%	>> wout = rebin(win, xlo, dx, xhi)  % rebin from xlo to xhi in intervals of dx
%
%       e.g. rebin(win,2000,10,3000)    % rebins from 2000 to 3000 in bins of 10
%
%       e.g. rebin(win,5,-0.01,3000)    % rebins from 5 to 3000 with logarithmically
%                                     spaced bins with width equal to 0.01 the lower bin boundary 
%
%   >> wout = rebin(win, [x1,dx1,x2,dx2,x3...]) % one or more regions of different rebinning
%
%       e.g. rebin(win,[2000,10,3000])
%       e.g. rebin(win,[5,-0.01,3000])
%       e.g. rebin(win,[5,-0.01,1000,20,4000,50,20000])
%
%   >> wout = rebin(win,wref)           % rebin win with the bin boundaries of wref
%                                       (wref must contain one spectrum, or the same number as win)
%
% For any datasets of the array win that contain point data the averaging of the points
% can be controlled:
%
%   >> wout = rebin (...)               % default method: point averaging
%   >> wout = rebin (..., 'int')        % trapezoidal integration
%
%
% Note that this function correctly accounts for x_distribution if histogram data.
% Point data is averaged, as it is assumed point data is sampling a function.
% The individual members of the array of output datasets, wout, have the same type as the 
% corresponding input datasets.

% T.G.Perring 3 June 2011 Based on the original mgenie rebin routine, but with
%                         extension to non-distribution histogram datasets, added
%                         trapezoidal integration for point data.


% Catch trivial case of no rebinning information
% ----------------------------------------------
if nargin==1
    wout=win;
    return
end

% Check input arguments
% ---------------------
% Check averging type - check if last argument is 'int'
if nargin>1 && ischar(varargin{end})
    if strcmpi(varargin{end},'int')
        point_ave=false;
        if nargin>2
            args=varargin(1:end-1);
        else
            error('Check arguments')
        end
    else
        error('Check arguments')
    end
else
    point_ave=true;
    args=varargin;
end

% Check rebinning parameters
if nargin>=2 && isa(args{1},'IX_dataset_1d')
    % If two arguments, both spectra, check that the number of elements are consistent
    wref=args{1};
    if ~(numel(wref)==1 || numel(wref)==numel(win))
        error('If second argument is an IX_dataset_1d, it must be a single dataset or have same array length as first argument')
    end
    % Check the reference dataset(s) can provide bin boundaries
    % *** Could catch case of single data point in reference workspaces - allowed if x values
    %     in win are also for a single point and match those in reference workspace.
    for i=1:numel(wref)
        if numel(wref(i).x)==1  % single point dataset, or histogram dataset with empty signal array
            error('Reference dataset(s) must have at least one bin (histogram data) or two points (point data)')
        end
    end
    % If just one reference dataset, get the x-values
    if numel(wref)==1
        xbounds_all_same=true;
        if numel(wref.x)~=numel(wref.signal)
            xbounds=wref.x;
        else
            xbounds=bin_boundaries_simple(wref.x);
        end
    else
        xbounds_all_same=false;
        ref_dataset=true;
    end
else
    % If rebin arguments are numeric, check format
    % (the fortran does a bunch or checks, but better to catch in matlab first)
    [ok,rebin_descriptor,any_dx_zero,mess]=rebin_descriptor_check_ref(args{:});
    if ok
        if numel(rebin_descriptor)>=3 && ~any_dx_zero     % get new bin boundaries
            xbounds_all_same=true;
            xbounds=rebin_1d_hist_get_xarr(0,rebin_descriptor);     % need to give dummy x bins
        else
            xbounds_all_same=false;
            ref_dataset=false;
        end
    else
        error(mess)
    end
end

% Perform rebin
% -------------
if numel(win)==1
    if xbounds_all_same
        wout=single_rebin(win,xbounds,true,point_ave);
    else
        wout=single_rebin(win,rebin_descriptor,false,point_ave);
    end
else
    wout=repmat(IX_dataset_1d,size(win));
    for i=1:numel(win)
        if xbounds_all_same
            wout(i)=single_rebin(win(i),xbounds,true,point_ave);
        elseif ref_dataset
            if numel(wref.x)==numel(wref.signal)
                xbounds=wref(i).x;
            else
                xbounds=bin_boundaries_simple(wref(i).x);
            end
            wout(i)=single_rebin(win(i),xbounds,true,point_ave);
        else
            wout(i)=single_rebin(win(i),rebin_descriptor,false,point_ave);
        end
    end
end


%==================================================================================================
function wout = single_rebin(win,xbounds,true_values,point_ave)
% Rebin dataset. Assumes that have already checked validity of input data.
%
%   >> wout = single_rebin(win,xbounds,true_values,point_ave)
%
%   win             Input IX_dataset_1d
%   xbounds         New x boundaries or x boundaries descriptor
%   true_values     Nature of x boundaries:
%                       true:  xbounds are the true values
%                       false: xbounds is rebin rescriptor
%   point_ave       Averging method (point data only; ignored if histogram data)
%                       true:  Point everaging 
%                       false: Trapezoidal integration
%
%   wout            Output IX_dataset_1d

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
            wout_x=rebin_1d_hist_get_xarr(win.x,xbounds);
            [wout_y,wout_e] = rebin_1d_hist(win.x, win.signal, win.error, wout_x);
%            [wout_x, wout_y,wout_e] = rebin_1d_hist_by_descriptor (win.x, win.signal, win.error, xbounds);
            wout = IX_dataset_1d (wout_x, wout_y, wout_e, win.title, win.x_axis, win.s_axis, win.x_distribution);
        end
    else
        % Get arrays of distribution of counts and errors
        xin_bins=diff(win.x);
        ytemp=win.signal./xin_bins';
        etemp=win.error./xin_bins';
        if true_values
            [ytemp, etemp] = rebin_1d_hist (win.x, ytemp, etemp, xbounds);
            xout_bins=diff(xbounds);
            ytemp=ytemp.*xout_bins';
            etemp=etemp.*xout_bins';
            wout = IX_dataset_1d (xbounds, ytemp, etemp, win.title, win.x_axis, win.s_axis, win.x_distribution);
        else
            [wout_x, ytemp, etemp] = rebin_1d_hist_by_descriptor (win.x, ytemp, etemp, xbounds);
            xout_bins=diff(wout_x);
            ytemp=ytemp.*xout_bins';
            etemp=etemp.*xout_bins';
            wout = IX_dataset_1d (wout_x, ytemp, etemp, win.title, win.x_axis, win.s_axis, win.x_distribution);
        end
    end

%---------------------------------------------------------------------------------------------    
% Point data
else
    if point_ave
        % Point averaging
        if true_values
            nb=numel(xbounds);
            indx=bin_index(win.x,xbounds,true);
        else
            if numel(win.x)>1
                xbounds_actual=rebin_1d_hist_get_xarr(win.x,xbounds);
            else    % effectively make ranges where dx=0 just one bin
                xbounds_actual=rebin_1d_hist_get_xarr([xbounds(1),xbounds(end)],xbounds);
            end
            nb=numel(xbounds_actual);
            indx=bin_index(win.x,xbounds_actual,true);
        end
        ok=(indx>0&indx<nb);
        indx=indx(ok)';     % keep only the elements in the new boundaries; column
        xsum=accumarray(indx,win.x(ok)',[nb-1,1]);
        ysum=accumarray(indx,win.signal(ok)',[nb-1,1]);
        esum=accumarray(indx,(win.error(ok).^2)',[nb-1,1]);
        nout=accumarray(indx,ones(size(win.x(ok)')),[nb-1,1]);
        ok=(nout~=0);
        nout=nout(ok);
        wout_x=xsum(ok)./nout;
        wout_y=ysum(ok)./nout;
        wout_e=sqrt(esum(ok))./nout;
        wout = IX_dataset_1d (wout_x, wout_y, wout_e, win.title, win.x_axis, win.s_axis, win.x_distribution);
    else
        % Trapezoidal integration averaging
        if true_values
            xbounds_actual=xbounds;
        else
            if numel(win.x)>1
                % - 29 Aug 2011: Replace
                % xbounds_actual=rebin_1d_hist_get_xarr(win.x,xbounds);
                % - with
                xbounds_actual=rebin_1d_hist_get_xarr(bin_boundaries_simple(win.x),xbounds);
            else    % effectively make ranges where dx=0 just one bin
                xbounds_actual=rebin_1d_hist_get_xarr([xbounds(1),xbounds(end)],xbounds);
            end
        end
        xout_bins=diff(xbounds_actual);
        [wout_y,wout_e] = integrate_1d_points (win.x, win.signal, win.error, xbounds_actual);
        xbounds_centres=0.5*(xbounds_actual(2:end)+xbounds_actual(1:end-1));
        wout = IX_dataset_1d (xbounds_centres, wout_y./xout_bins', wout_e./xout_bins', win.title, win.x_axis, win.s_axis, win.x_distribution);
    end  
    
%---------------------------------------------------------------------------------------------    
end


%==================================================================================================
function x_out=rebin_1d_hist_get_xarr (x_in, xbounds)
% Deprecated function, replaced by bin_boundaries_from_descriptor

x_out=bin_boundaries_from_descriptor (xbounds, x_in);


%==================================================================================================
function [xout, sout, eout] = rebin_1d_hist_by_descriptor (x, s, e, xbounds)
% Simple wr
xout=rebin_1d_hist_get_xarr (x, xbounds);
[sout, eout] = rebin_1d_hist (x, s, e, xout);


%==================================================================================================
function [ok,rebin_descriptor,any_dx_zero,mess]=rebin_descriptor_check_ref(varargin)
% Check rebin descriptor has valid format, and returns in standard form [x1,dx1,x2,dx2,x3,...]
%
%   xlo,xhi
%   xlo,dx,xhi
%   [xlo,xhi]
%   [xlo,dx,xhi]
%   [x1,dx1,x2,dx2,x3,...]
%
%   Require that x1<x2<x3... and that if dx1<0 then dx1>0, dx2<0 then dx2>0 ...

ok=false;
rebin_descriptor=[];
any_dx_zero=false;
mess='';
if nargin==1 && isnumeric(varargin{1}) && ~isscalar(varargin{1})
    if numel(varargin{1})>=3 && rem(numel(varargin{1}),2)==1
        if all(diff(varargin{1}(1:2:end)))>0    % strictly monotonic increasing
            if all(varargin{1}(1:2:end-1)>0 | varargin{1}(2:2:end-1)>=0)
                ok=true;
                if any(varargin{1}(2:2:end)==0), any_dx_zero=true; end
                rebin_descriptor=varargin{1}(:)';
            else
                mess='Binning descriptor: cannot have logarithmic bins for negative axis values';
            end
        else
            mess='Binning descriptor: bin boundaries must be strictly monotonic increasing';
        end
    elseif numel(varargin{1})==2
        if varargin{1}(2)>varargin{1}(1)
            ok=true;
            rebin_descriptor=varargin{1}(:)';
        else
            mess='Binning descriptor: upper limit must be greater than lower limit';
        end
    else
        mess='Check length of rebin descriptor array';
    end
    
elseif nargin==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
        isscalar(varargin{1})  && isscalar(varargin{2})
    if varargin{2}>varargin{1}
        ok=true;
        rebin_descriptor=[varargin{1},varargin{2}];
    else
        mess='Binning descriptor: upper limit must be greater than lower limit';
    end
    
elseif nargin==3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3}) &&...
        isscalar(varargin{1})  && isscalar(varargin{2})  && isscalar(varargin{3})
    if varargin{3}>varargin{1}
        if varargin{1}>0 || varargin{2} >=0
            ok=true;
            rebin_descriptor=[varargin{1},varargin{2},varargin{3}];
        else
            mess='Binning descriptor: cannot have logarithmic bins for negative axis values';
        end
    else
        mess='Binning descriptor: bin boundaries must be strictly monotonic increasing';
    end
    
else
    mess='Check number and type of rebin descriptor parameter(s)';
end
