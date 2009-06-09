function [x,y,e]=get_xye(w,empty)
% Get the bin centres, intensity and error bar for a 1D, 2D, 3D or 4D dataset
%
%   >> [x,y,e]=get_xye(w)
%
%   >> [x,y,e]=get_xye(w, empty)
%
% Input:
% ------
%   w       Result of a cut or slice (1D, 2D,...)
%   empty   [Optional] numeric value to substitute for the intensity in bins
%           with no data.
%           Default: NaN
%           The error bar will always be set to zero.
%
% Output:
% -------
%   x       m x n array of the x coordinates of the bin centres
%           m = number of points in the cut, n=dimensionality
%           The order of the points is usual Fortran order
%           (1,1,1), (2,1,1), ... (n1,1,1),(1,2,1),(2,2,1),...
%
%   y       m x 1 array of intensities
%
%   e       m x 1 array of error bars
%

% T.G.P  13/1/09
% Quick fix: should really be methods of the different types. Done like this for 
% Chris Stock to get him going as quickly as possible

if ~exist('empty','var')
    empty=NaN;
elseif ~isnumeric(empty)
    error('Empty subsitution value must be numeric')
end
    
if isa(w,'d1d')||isa(w,'d2d')||isa(w,'d3d')||isa(w,'d4d')
    ww=get(w);
    if isa(w,'d1d')
        x=bin_centres(ww.p1);
    elseif isa(w,'d2d')
        x{1}=bin_centres(ww.p1);
        x{2}=bin_centres(ww.p2);
    elseif isa(w,'d3d')
        x{1}=bin_centres(ww.p1);
        x{2}=bin_centres(ww.p2);
        x{3}=bin_centres(ww.p3);
    elseif isa(w,'d4d')
        x{1}=bin_centres(ww.p1);
        x{2}=bin_centres(ww.p2);
        x{3}=bin_centres(ww.p3);
        x{4}=bin_centres(ww.p4);
    end
    if iscell(x)
        xx=cell(size(x));
        [xx{:}]=ndgrid(x{:});   % make grid that covers all bins
        for i=1:numel(xx)
            xx{i}=xx{i}(:);     % make each coordinate a column array
        end
        x=[xx{:}];   % concatenate arrays
    end
    y=ww.s(:)./ww.n(:);
    e=sqrt(abs(ww.e(:)))./ww.n(:);
    iszero=(ww.n(:)==0);
    y(iszero)=empty;
    e(iszero)=0;
else
    error('Invalid input argument')
end

%-----------------------------
function xc=bin_centres(x)
xc=0.5*(x(2:end)+x(1:end-1));
