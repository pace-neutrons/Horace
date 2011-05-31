function [wout] = rebin(win, varargin)
% Rebin an IX_dataset_1d object or array of IX_dataset_1d objects along the x-axis
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
%   >> wout = rebin(win,wref)            % rebin win with the bin boundaries of wref
%                                    (wref must contain one spectrum, or the same number as win)

% Catch trivial case of no rebinning information
% ----------------------------------------------
if nargin==1
    wout=win;
    return
end

% Check input arguments
% ---------------------
if nargin==2 && isa(varargin{1},'IX_dataset_1d')
    % If two arguments, both spectra, check that the number of elements are consistent
    wref=varargin{1};
    if ~(numel(wref)==1 || numel(wref)==numel(w))
        error('If second argument is an IX_dataset_1d, it must be a single dataset or have same arraya length as first argument')
    end
    % Check the reference dataset(s) can provide bin boundaries
    for i=1:numel(wref)
        if numel(wref(i).x)==numel(wref(i).signal) || isempty(wref(i).signal)
            error('Reference dataset(s) must be non-empty histogram dataset(s)')
        end
    end
    % If just one reference dataset, get the x-values
    if numel(wref)==1
        xbounds_all_same=true;
        xbounds=wref.x;
    else
        xbounds_all_same=false;
        ref_dataset=true;
    end
else
    % If rebin arguments are numeric, check format
    % (the fortran does a bunch or checks, but better to catch in matlab first)
    [ok,rebin_descriptor,any_dx_zero,mess]=rebin_descriptor_check(varargin{:});
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
        wout=single_rebin(win,xbounds,true);
    elseif ref_dataset
        wout=single_rebin(win,wref,true);
    else
        wout=single_rebin(win,rebin_descriptor,false);
    end
else
    wout=IX_dataset_1d(size(win));
    for i=1:numel(win)
        if xbounds_all_same
            wout(i)=single_rebin(win(i),xbounds,true);
        elseif ref_dataset
            wout(i)=single_rebin(win,wref((i)),true);
        else
            wout=single_rebin(win,rebin_descriptor,false);
        end
        wout(i)=single_rebin(win(i),rebin_descriptor);
    end
end
