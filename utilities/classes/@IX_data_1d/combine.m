function wout= combine(w1,varargin)
% Combine parts of several IX_dataset_1d into a single new IX_dataset_1d.
% The data set are "glued" together at the points x1,x2..xn-1
% with a smoothing function that extends +/-(delta/2) about those points.
%
% Syntax:
%   >> wout = combine (w1, x1, w2, delta)                   % minimum case
%   >> wout = combine (w1, x1, w2, x2 ... xn-1, wn, delta)  % general case

% Original: Joost van Duijn: 28-08-03
%
% Modified: T.G.Perring 27-01-2007
%   - enhance argument checking
%   - now calculates smoothing function correctly for point spectra as well as
%    histogram data
%   - corrects error at the ends of the x range when one or both limits were
%    negative
%   - corrected bug in calculation of error bars
%   - for a given IX_dataset_1d, ignores any points that lie outside the range
%    of the non-zero parts of the smoothing function. This cures a problem that
%    NaN in a IX_dataset_1d cause a NaN in the output, even if the point is way
%    outside the range that the IX_dataset_1d contributes to.
%
% Modified T.G.Perring 01-11-2009
%   - datasets can have different x values, so long as the overlap regions are common
%   - error message if an overlap range not fully covered by the two datasets being joined at that point

class_type=class(w1);

% Get parameters from the first IX_dataset_1d
if numel(w1)~=1
    error(['Input argument 1 must be a single ',class_type,' object, not an array']);
end
w.x=w1.x; w.y=w1.signal; w.e=w1.error;
is_hist=logical(length(w.x)-length(w.y));

if rem(nargin,2)~=0
    error ('Check number of arguments to dataset combine function')
end

nwork= nargin/2; %number of IX_dataset_1d objects that will be combined
if nwork<=1
    error(['Not enough input paramters given! Minimum input consists'...
        ' of e.g. wout= combine(w1,x1,w2,delta)']);
end

% Check if input parameters in the varargin 2, 4, 6, ..., 2*(nwork-1) are of type IX_dataset_1d
% and all have the same x-axis.
j=1;
w=repmat(w,1,nwork);
for i=2:2:2*(nwork-1)
    j= j+1;
    if ~isa(varargin{i} , class_type),
        error(['Input argument ' 1+int2str(i) ' is not a ',class_type,' object']);
    elseif length(varargin{i})~=1
        error(['Input argument ' 1+int2str(i) ' must be a single ',class_type,' object, not an array']);
    else
        w(j).x=varargin{i}.x; w(j).y=varargin{i}.signal; w(j).e=varargin{i}.error;
    end
    if logical(length(w(j).x)-length(w(j).y))~=is_hist
        error ('Cannot mix histogram and point data sets');
    end
end

% Check if the input paramters in the varargin 1, 3, ..., 2*nwork-3 are double, these
% paramters contain the boundaries of the different spectra, and
% are in increasing order. Will give x1, x2, x3, ..., xn-1.
j=0;
x=zeros(1,nwork-1);
for i=1:2:2*nwork-3,
    j= j+1;
    if ~isa(varargin{i}, 'double'),
        error(['Input agument ' 1+int2str(i) ' is not a number']);
    elseif length(varargin{i})>1
        error(['Input agument ' 1+int2str(i) ' must be a scalar']);
    else
        x(j)= varargin{i};
    end
    if j==1 && x(j)<w(1).x(1)
        error('The first merge point does not lie within the xrange');
    elseif j>1 && x(j-1)>x(j)
        error('The merge points are not in increasing order');
    elseif i==2*nwork-3 && x(j)>w(end).x(end)
        error('The final merge point does not lie within the xrange');
    end
end

% Check if the last agument is a double or vector length (nwork-1). This is the delta that will be
% used in the smoothing function, determines the range over which data
% is smoothed near the boundaries.
if ~isa(varargin{2*nwork-1}, 'double') || ~(length(varargin{2*nwork-1})==1) || varargin{2*nwork-1}<0
    error('The final input argument must be a positive number, or array of positive numbers with length one less than number of IX_dataset_1d objects');
else
    delta=varargin{2*nwork-1};
end

% Merge data
[wcombine,ok,mess]=combine_xye(w,x,delta);
if ~ok
    error(mess)
end

wout=IX_dataset_1d(w1.title, wcombine.y, wcombine.e, w1.s_axis, wcombine.x, w1.x_axis, w1.x_distribution);
