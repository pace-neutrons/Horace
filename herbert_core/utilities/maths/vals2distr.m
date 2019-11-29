function varargout = vals2distr(vals,varargin)
% Create an IX_dataset_1d of a pdf from an array of sampled values
%
%   >> w = vals2distr (vals)            % return distribution
%   >> w = vals2distr (vals,nbins)      % with specified number of bins
%   >> w = vals2distr (vals,edges)      % with particular bin boundaries
%   >> w = vals2distr (...,'norm')      % normalise to unit area
%   >> w = vals2distr (...,'poisson')   % assign error bars
%
%   >> vals2distr (...)     % plot distribution without a return argument
%
%
% Input:
% ------
%   vals    Array of random values
%
% Optional arguments:
%   nbins   Number of bins into which to split the histogram
%
%   edges   Bin boundaries for the distribution
%
% Output:
% -------
%   w       IX_dataset_1d of the normalised histogram
%
% Calls matlab intrinsic function histcounts, and normalises the
% resulting spectrum to have unit area


keyval_def = struct('norm',false,'poisson',false);
flags = {'norm','poisson'};
[par,keyval,~,~,ok,mess] = parse_arguments (varargin,keyval_def,flags);
if ~ok, error(mess), end
if numel(par)>1
    error('Check number of input arguments')
end

[N,edges] = histcounts(vals(:),par{:});
if keyval.poisson
    w = IX_dataset_1d(edges,N,sqrt(N));
else
    w = IX_dataset_1d(edges,N,zeros(size(N)));    
end
if keyval.norm
    area=integrate(w);
    w = w/area.val;
end

if nargout>0
    varargout{1}=w;
end

if nargout==0
    dh(w)
    xlo = min(vals(:));
    xhi = max(vals(:));
    dx=xhi-xlo;
    xlims = [xlo-dx/10,xhi+dx/10];
    ylims = [0,1.1*max(w.signal)];
    lx(xlims);
    ly(ylims)
end
