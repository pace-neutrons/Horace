function [istart,iend,irange,inside,outside] = get_irange_rot(this,urange,varargin)
% Get ranges of bins that partially or wholly lie inside an n-dimensional rectangle,
% where the first three dimensions can be rotated and translated w.r.t. the
% cuboid that is split into bins.
%
%   >> [istart,iend,irange] = this.get_irange_rot(urange,p1,p2,p3,...pndim)
%   >> [istart,iend,irange,inside,outside] = get_irange_rot(...)
%
% Works for an arbitrary number of dimensions ndim (ndim>0), and with
% non-uniformly spaced bin boundaries.
%
% Also works for non-orthogonal axes. That is, the matrix that connects the
% two coordinate frames of urange and of the bin boundaries can also
% encode a shear.
%
% Input:
% ------
%   urange  Range to cover: array size [2,ndim] of [urange_lo; urange_hi]
%          where ndim (>=3) is the number of dimensions. It is required that
%          urange_lo <=urange_hi for each dimension
%
%
%   p1      Bin boundaries along first axis (column vector)
%   p2      Similarly axis 2
%   p3      Similarly axis 3
%    :              :
%   pndim   Similarly axis ndim
%           It is assumed that each array of bin boundaries has
%          at least two values (i.e. at least one bin), and that
%          the bin boundaries are monotonic increasing.
%
% Output:
% -------
%   istart  Column vector of indices of the start of contiguous ranges
%          within the first three dimensions. If range is outside the bins
%          then returned as empty (in fact, has size(istart)=[0,1])
%   iend    Column vector of indices of the end of contiguous ranges
%          within the first three dimensions. If range is outside the bins
%          then returned as empty (in fact, has size(iend)=[0,1])
%   irange  Bin index range for dimensions excluding the first three:
%          array size [2,ndim-3]. If the region defined by urange lies
%          fully outside the bins, then irange is set to zeros(0,ndim)
%          i.e. isempty(irange)==true.
%   inside  If the range defined by urange is fully contained within
%          the bin boundaries, then contained==true. Otherwise,
%          inside==false.
%   outside If the range defined by urange is fully outside the bin
%          boundaries i.e. there is no intersection of the two volumes,
%          then outside=true;


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)


ndim=numel(varargin);
if ndim<3
    error('Must give at least three bin boundary arrays')
elseif numel(size(urange))~=2 || size(urange,1)~=2 || size(urange,2)~=ndim
    error('Check urange is a 2 x ndim array where ndim is the number of bin boundary arrays')
elseif any(urange(1,:)>urange(2,:))
    error('Must have urange_lo <= urange_hi for all dimensions')
end
if ndim==3
    % No check on outer dimensions required
    [istart,iend,inside,outside] = get_irange3D_rot(this,urange,varargin{1:3});
    irange=zeros(2,0);
else
    % Check first if the simple section of dimensions 4,5,... leaves any points (as fast to test)
    [irange,inside,outside] = aProjection.get_irange(urange(:,4:end),varargin{4:end});
    if outside
        istart=zeros(0,1);
        iend=zeros(0,1);
        return
    end
    % Now look at inner three dimensions
    [istart,iend,inside3D,outside3D] = get_irange3D_rot(this,urange,varargin{1:3});
    if ~outside3D
        inside=(inside & inside3D);
    else
        irange=zeros(0,ndim-3);
        inside=false;
        outside=true;
    end
end

end

%========================================================================================
function [istart,iend,inside,outside] = get_irange3D_rot(this,urange,p1,p2,p3)
% Get indicies that define contiguous ranges of bins that partially or wholly
% lie inside a cuboid volume that is rotated and translated w.r.t. the
% cuboid that is split into bins.
%
%   >> [istart,iend] = get_irange3D_rot(urange,rot,trans,p1,p2,p3)
%
% Works for non-uniformly spaced bin boundaries.
%
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

%   p1      Bin boundaries along first axis (column vector)
%   p2      Similarly axis 2
%   p3      Similarly axis 3
%           It is assumed that each array of bin boundaries has
%          at least two values (i.e. at least one bin), and that
%          the bin boundaries are monotonic increasing.
% 
% Ouptut:
% -------
%   istart  Bin index values of the start of contiguous ranges. If range is
%          outside the bins then returned as empty (in fact, has
%          size(istart)=[0,1])
%   iend    Bin index values of the end of contiguous ranges. If range is 
%          outside the bins then returned as empty (in fact, has
%          size(iend)=[0,1])
%   inside  If the range defined by urange is fully contained within
%          the bin boundaries, then contained==true. Otherwise,
%          inside==false.
%   outside If the range defined by urange is fully outside the bin
%          boundaries i.e. there is no intersection of the two volumes,
%          then outside=true;
%
% Note:
%   The algorithm is an n^3 algorithm - good for small grids, but could be improved for
%   for large grids.
% -------------------------------------------------------------------------------------
%   rot     Matrix, A     --|  (3x3 array)
%   trans   Translation, T--|  (column vector length 3)
%           These relate the two coordinate frames of the bin boundary
%           arrays and of urange:
%              r'(i) = A(i,j)(r(j) - T(j))
%          where r(j) are the coordinates of a vector in the frame of the
%          bin boundaries p1,p2,p3 (below), and r'(i) are the coordinates
%          of the frame in which urange is expressed.
%           Note that T is given in coordinates of the axes of the bin
%          boundaries.

[rot,trans] = this.get_box_transf_();

psize=[numel(p1),numel(p2),numel(p3)];

% Grid of bin verticies:
[x1,x2,x3]=ndgrid(p1-trans(1),p2-trans(2),p3-trans(3));

% Coordinates of bin verticies in rotated and translated frame in which urange is given
ucoords=rot*[x1(:)';x2(:)';x3(:)'];

bin_inside = ~(bin_outside(1)|bin_outside(2)|bin_outside(3));   % =0 if bin outside, =1 if at least partially intersects volume

change = diff([false;bin_inside(:);false]);
istart = find(change==1);
iend   = find(change==-1)-1;


% Determine values of inside and outside
% --------------------------------------
[b1,b2,b3]=ndgrid(urange(:,1),urange(:,2),urange(:,3));     % urange in the frame of bin boundaries
bcoords=rot\[b1(:)';b2(:)';b3(:)'] - repmat(trans(:),1,8);
if min(bcoords(1,:))>=p1(1) && max(bcoords(1,:))<=p1(end) &&...
        min(bcoords(2,:))>=p2(1) && max(bcoords(2,:))<=p2(end) &&...
        min(bcoords(3,:))>=p3(1) && max(bcoords(3,:))<=p3(end)
    inside=true;
else
    inside=false;
end
    
outside=isempty(istart);

    function wrk = bin_outside (idim)
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
