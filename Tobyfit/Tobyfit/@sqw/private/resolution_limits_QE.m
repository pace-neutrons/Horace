function [minX,maxX,delX] = resolution_limits_QE(win,lookup,frac)
% Determine the minimum corner and maximum corner of the total resolution
% ellipsoid projection extents along the four projection axes, plus the
% maximum extents of any one resolution ellipsoid.
% From this we can setup the neighborhood search cells, with 
%   N = ceil( (maxX-minX)./delX ) + 1
% cells along each axis and prod(N) total cells.
%
% Inputs:
%   win     one or more SQW object(s)
%
%   lookup  the *_init function-created lookup tables for the SQW object(s)
%
%   frac    the fractional-probability at which to evaluate the resolution
%           function widths
%
% Outputs:
%   minX    the smallest (Q,E) point of the resolution bounding box (4,1)
%
%   maxX    the largest (Q,E) point of the resolution bounding box (4,1)
%
%   delX    the largest resolution halfwidth along each dimension from all
%           pixels of all SQW objects. (4,1)

if nargin < 3 || ~isnumeric(frac)
    frac=0.5; % half-height probability by default
end

if iscell(win)
    win = cell2mat_obj(win);
end

minX = inf(4,1);  % smallest extent along each axis
maxX =-inf(4,1);  % biggest extent along each axis
delX = zeros(4,1);% biggest individual resolution projection along each axis

for i=1:numel(win)
    X = lookup.QE{i};
    C = lookup.cov_hkle{i};
    H = resolution_halfwidths(C,frac); % (4,npix)
    
    this_minX = min(X-H,[],2);
    this_maxX = max(X+H,[],2);
    this_delX = max(H,[],2);
        
    minX = min(minX,this_minX); % elementwise comparison and selection
    maxX = max(maxX,this_maxX);
    delX = max(delX,this_delX);
end    

end