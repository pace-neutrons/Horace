function [istart,iend] = get_irange_rot(urange,rot,trans,p1,p2,p3)
% Get indicies that define contiguous ranges of bins that partially or wholly
% lie inside a cuboid volume that is rotated and translated w.r.t. to the
% cuboid that is split into bins.
%
%   >> [istart,iend] = get_irange_rot(urange,rot,trans,p1,p2,p3)
%
% Works for non-uniformly spaced bin boundaries.
% Also works for non-orthogonal axes. That is, the matrix that connects the
% two coordinate frames of urange and of the bin boundaries can also
% encode a shear.
%
% Input:
% ------
%   urange  Range to cover: 2 x 3 array of upper and lower limits
%          [urange_lo; urange_hi] (in units of a coordinate frame
%          that is rotated shifted with respect to that frame in
%          which the bin boundaries p1,p2,p3 are expressed, see below)
%
%   rot     Matrix, A     --|  that relate the two coordinate frames
%   trans   Translation, T--|  of the bin boundary arrays and of urange:
%              r'(i) = A(i,j)(r(j) - T(j))
%          where r(j) are the coordinates of a vector in the frame of the
%          bin boundaries p1,p2,p3 (below), and r'(i) are the coordinates
%          of the frame in which urange is expressed.
%           Note that T is given in coordinates of the axes of the bin
%          boundaries.
%
%   p1      Bin boundaries along first axis (column vector)
%   p2      Similarly axis 2
%   p3      Similarly axis 3
% 
% Ouptut:
% -------
%   istart  Bin index values. If range is outside the bins then returned as empty
%   iend    Upper index values. If range is outside the bins then returned as empty
%
% Note:
%   The algorithm is an n^3 algorithm - good for small grids, but could be improved for
%   for large grids.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


psize=[numel(p1),numel(p2),numel(p3)];

% Grid of bin verticies:
[x1,x2,x3]=ndgrid(p1-trans(1),p2-trans(2),p3-trans(3));

% Coordinates of bin verticies in rotated and translated frame in which urange is given
ucoords=rot*[x1(:)';x2(:)';x3(:)'];       

inside = ~(outside(1)|outside(2)|outside(3));   % =0 if bin outside, =1 if at least partially intersects volume

change = diff([false;inside(:);false]);
istart = find(change==1);
iend   = find(change==-1)-1;

    function wrk = outside (idim)
        % Determine if the bins lie wholly outside the limits along dimension number idim
        wrk = reshape(ucoords(idim,:)<=urange(1,idim),psize);
        all_low = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = reshape(ucoords(idim,:)>=urange(2,idim),psize);
        all_hi  = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = all_low | all_hi;
    end

end
