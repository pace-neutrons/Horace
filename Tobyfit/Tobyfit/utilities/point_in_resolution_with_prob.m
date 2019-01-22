function [pinr_Xidx,pinr_Xlen,pinr_frst,pinr_last,pinr_list,pinr_VxR] = ...
    point_in_resolution_with_prob(span,N,Y,Yhead,Ylist,X,M,C,Xhead,Xlist,frac)
% Determine if a point (or points) Y is inside of the resolution defined by
% Xcov centered at X.

% Inputs:
%   Y       The d-dimensional test point(s).
%           Either a (d,1) vector for a single point, or a (d,Npt) matrix 
%           for Npt points.
%
%   Yhead   The head of the linked list putting all Y point(s) into their
%           appropriate neighbourhoods.
%           Yhead(i) is the index of the first Ylist point in neighbourhood
%           i (i.e., Y(Yhead(i))).
%
%   Ylist   The list of the linked list putting all Y point(s) into their
%           appropriate neighbourhoods
%           Ylist(j) gives the index of the next point in the
%           neighbourhood, so Y(j), Y(Ylist(j)), Y(Ylist(Ylist(j)), ...,
%           are all in the same neighbourhood until you find Ylist(j)==0
%
%   X       The locations of the resolution function(s).
%           Either a (d,1) vector for a single pixel, or a (d,Npx) matrix
%           for Npx pixels.
%
%   M       The d-dimensional gaussian width matricies, where the elements 
%           of M describe the semi-axis lengths by M_ij = 1/sigma_ij^2 
%           Either a (d,d) matrix for a single ellipsoid or a (d,d,m) array
%           for m ellipsoids.
%
%   C       The d-dimensional covariance matricies ( the inverse of M)
%           Either a (d,d) matrix for a single ellipsoid or a (d,d,m) array
%           for m ellipsoids.
%
%   Xhead   Like Yhead, but gives the first index into Xlist
%
%   frac    The fractional probability above which a point is *in*
%           resolution for a pixel

% Outputs:
%   pinr    A cell array where the ith component contains the indicies of
%           the points in Y which are within the resolution ellipsoid of
%           X(i)
%           This could be another linked list instead

% Verify that inputs are sensible:
d = numel(N);
if size(N,1)~=d
    N=N(:);
end
if numel(span)~=d 
    error('the span must have as many elements as N')
end
if size(span,1)~=d
    span=span(:); % make sure it's a column vector
end
Ntot = prod(N);
if ~ismatrix(Y) || size(Y,1)~=d
    error('Y must be a (%d,1) point or a (%d,Npt) collection of points',d,d)
end
if numel(Yhead)~=Ntot
    error('Yhead must have %d elements for the neighbourhood array passed',Ntot)
end
Npt=size(Y,2);
if numel(Ylist) ~= Npt
    error('Ylist must have %d entries for Y of size (%d,%d)',Npt,d,Npt)
end

if ~ismatrix(X)||size(X,1)~=d
    error('X must be a (d,1) point or a (d,Npx) collection of pixels')
end
Npx=size(X,2);
if size(M,1)~=d||size(M,2)~=d||size(M,3)~=Npx||ndims(M)>3
    error('M must be (%d,%d,%d) to match X',d,d,Npx)
end
if size(C,1)~=d||size(C,2)~=d||size(C,3)~=Npx||ndims(C)>3
    error('C must be (%d,%d,%d) to match X',d,d,Npx)
end
if numel(Xhead)~=Ntot
    error('Xhead must have %d elements for the neighbourhood array passed',Ntot)
end
if numel(Xlist) ~= Npx
    error('Xlist must have %d entries for X of size (%d,%d)',Npx,d,Npx)
end

cellHasPx = Xhead > 0;
% fprintf('Now checking %d of %d cells for resolution inclusion\n',sum(hasPx),Ntot);
cellHasPx = find(cellHasPx,Ntot); % A vector of indicies is easier to use

pinr_Xidx = zeros(1,Npx);
pinr_Xlen = zeros(1,Npx);
pinr_frst = zeros(1,Npx);
pinr_last = zeros(1,Npx);
% % If every point is within resolution for every pixel, we need to keep
% % track of Npx*Npt indicies:
% pinr_list = zeros(1,Npx*Npt);
% But doing so might take more memory than we have for a large volume of
% (Q,E) [where we certainly don't need so many points due to the relatively
% small overlap of R(Q,E)]
pinr = cell(numel(cellHasPx),1);
tmp_VxR = cell(numel(cellHasPx,1));

ninr = 0; % So we'll need to keep track of how much of the list is used
iPx = 0; % the number of pixels accumulated thus far

% Yhead == 0 are neighbourhoods without Y points
% Xhead == 0 are neighbourhoods without X pixels


for i=1:numel(cellHasPx)
    % get indicies in to X for pixels in cell cellHasPx(i)
    iXidx = cll_collect_idx( cellHasPx(i), Xhead, Xlist);
    % determine the neighbouring cells to cellHasPx(i) 
    nCell = cll_cell_neighbours( cellHasPx(i), N, span, Ntot, 1);
    % get indicies in to Y for pixels in any of the neighbouring cells
    iYidx = cll_collect_idx( nCell, Yhead, Ylist); 
    % get a cell array where each element are the indicies into iYidx for
    % the corresponding iXidx
    [idx,prob] = point_in_ellipsoid_with_prob(Y(:,iYidx),M(:,:,iXidx),C(:,:,iXidx),X(:,iXidx),frac);
    
    in_cell = cell(length(idx),1);
    for j=1:length(idx)
        iPx = iPx + 1; % Increment how many pixels we've accumulated
        iY = idx{j};
        % Store for output
        pinr_Xidx(iPx) = iXidx(j);  % this pixel number
        pinr_Xlen(iPx) = numel(iY); % how many points are within resolution for this pixel
        pinr_frst(iPx) = 1+ninr;    % the first entry in the list or point indicies for this pixel
        pinr_last(iPx) = ninr+numel(iY);
        ninr = ninr + numel(iY); % increment how many points are in resolution
        % finally store the point indicies
        %   iY are indicies into iYidx, but we want the indicies into Y,
        %   which are iYidx(iY).
        %pinr_list( pinr_frst(iPx) : pinr_last(iPx) ) = iYidx(iY);  
        in_cell{j} = iYidx(iY);
    end
    pinr{i} = cat(2,in_cell{:});
    tmp_VxR{i} = cat(2,prob{:});
end
% % make sure we only return the part of pinr_list which has been populated
% pinr_list = pinr_list(1:ninr);

pinr_list = cat(2,pinr{:});
pinr_VxR = cat(2,tmp_VxR{:});
if numel(pinr_list)~= ninr || numel(pinr_VxR)~= ninr
    error('Something has gone wrong creating pinr_list')
end
end

