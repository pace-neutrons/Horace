function varargout = vals2distr(vals,varargin)
% Create an IX_dataset_1d of a pdf from an array of sampled values
%
% The function produces a histogram of the values in the inut argumnet vals,
% which can be optionally normalised to have area unity and assigned error
% bars as the square root of the number of values that are placed in each bin
% of the histogram. If the input argument vals is not from a randomly
% sampled distribution, the output is still useful as a normalised
% histogram of the input values.
%
%
%   >> w = vals2distr (vals)            % return distribution
%   >> w = vals2distr (vals, nbins)     % with specified number of bins
%   >> w = vals2distr (vals, edges)     % with particular bin boundaries
%   >> w = vals2distr (..., 'norm')     % normalise to unit area
%   >> w = vals2distr (...,' poisson')  % assign error bars
%
%   >> vals2distr (...)     % plot distribution without a return argument
%
%
% Input:
% ------
%   vals        Array of values to be histogrammed. The dimensionality of
%               the array is igored as internally it is converted into a
%               vector before histogramming.
%
% Optional arguments:
%   nbins       Number of bins into which to split the histogram.
%
%   edges       Bin boundaries for the distribution.
%
%  'norm'       Normalise the resulting histogram IX_dataset_1d so that it
%               has unit area.
%
%  'poisson'    Assign error bars computed as the square root of the number
%               of elements of vals that are in each histogram bin. This is
%               a useful heuristic to get a measure of the uncertainty if
%               vals arises from an array of randomly selected points.
%               
%
% Output:
% -------
%   w           Histogram IX_dataset_1d dataset of the values
%
%
% Calls matlab intrinsic function histcounts


keyval_def = struct('norm',false,'poisson',false);
flags = {'norm','poisson'};
[par,keyval,~,~,ok,mess] = parse_arguments (varargin,keyval_def,flags);
if ~ok, error(mess), end

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
