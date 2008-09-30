function irange = get_irange(urange,varargin)
% Get range of bin boundary indicies that fully contain an n-dimensional rectange
% Works for arbitrary number of dimensions, and non-uniformly spaced bin boundaries
%
%   >> irange = get_irange(urange,p1,p2,p3,...pnd)
%
% Input:
%   urange(2,nd)    Range to cover: 2 x nd array of [urange_lo; urange_hi]
%   p1(:)           Bin boundaries along first axis
%   p2(:)           Similarly axis 2
%   p3(:)           Similarly axis 3
%    :                      :
% Output:
%   irange(2,nd)    Bin index ranges. If the region defined by urange lies
%                  outside the bins, then returned as empty array [].
%

% T.G.Perring   30/06/2007

nd=length(varargin);
irange = zeros(2,nd);
for id=1:nd
    irange(1,id) = max(1,upper_index(varargin{id},urange(1,id)));
    irange(2,id) = min(length(varargin{id}),lower_index(varargin{id},urange(2,id)))-1;
end
if any(irange(1,:)>irange(2,:)) % section not in the input bins
    irange=[];
end
