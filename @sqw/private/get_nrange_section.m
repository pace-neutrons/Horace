function [nstart,nend] = get_nrange_section (urange,nelmts,varargin)
% Get contiguous ranges of elements of an array where it intersects a hypercuboid
%
% Given an array containing number of points in bins, and the bin boundaries,
% return column vectors of the start and end indicies of ranges of contiguous
% points for those bins that partially or fully lie within a hypercuboid,
% n the column representation of the points.
%
%   >> [nstart,nend] = get_nrange (urange,nelmts,,p1,p2,p3...)
% 
% Input:
% ------
%   urange  Range to cover: 2 x nd array of [urange_lo; urange_hi]
%   nelmts  Array of number of points in n-dimensional array of bins
%          e.g. 3x5x7 array such that nelmts(i,j,k) gives no. points in
%          the (i,j,k)th bin.
%   p1      Bin boundaries along first axis (column vector)
%   p2      Similarly axis 2
%   p3      Similarly axis 3
%    :              :
%   
% Output:
% -------
%   nstart      Column vector of starting values of contiguous blocks in
%              the array of values with the number of elements in a bin
%              given by nelmts(:).
%   nend        Column vector of finishing values.
%
%               nstart and nend have column length zero if there are no
%              elements i.e. have the value zeros(0,1).


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get contiguous arrays
[irange,inside,outside] = get_irange(urange,varargin{:});
if ~outside
    [nstart,nend] = get_nrange(nelmts,irange);
else
    nstart=zeros(0,1);
    nend=zeros(0,1);
end
