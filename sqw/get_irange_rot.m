function [istart,iend,inside] = get_irange_rot(urange,rot,trans,p1,p2,p3)
% Get range of contiguous bins
% Works for arbitrary number of dimensions, and non-uniformly spaced bin boundaries,
% and allows for rotation and translation
%
%   >> irange = get_irange(urange,p1,p2,p3)
%
% Input:
%   urange(2,3)     Range to cover: 2 x 3 array of [urange_lo; urange_hi]
%                  in units of a rotated and shifted coordinate frame
%   rot             Matrix     --|  that relate a vector expressed in the
%   trans           Translation--|  frame of the bin boundaries to those of urange:
%                                      r'(i) = A(i,j)(r(j) - trans(j))
%   p1(:)           Bin boundaries along first axis
%   p2(:)           Similarly axis 2
%   p3(:)           Similarly axis 3
% 
% Ouptut:
%   istart          Bin index values. If range is outside the bins then returned as empty
%   iend            Upper index values. If range is outside the bins then returned as empty
%
% Note:
%   The algorithm is an n^3 algorithm - good for small grids, but could be improved for
%   for large grids.

% T.G.Perring   30/06/2007

psize=[length(p1),length(p2),length(p3)];
% grid of bin verticies:
[x1,x2,x3]=ndgrid(p1-trans(1),p2-trans(2),p3-trans(3));   
% coordinates of bin verticies in rotated and translated frame
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