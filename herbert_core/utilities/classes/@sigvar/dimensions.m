function [nd,sz] = dimensions(w)
% Number and extent of the dimensions of the public signal array.
%
%   >> [nd,sz] = dimensions(w)
%
% The notion of dimensionality and size of an object is a class dependent
% convention. In particular, the number of dimensions and their extents are
% not necessarily the same as returned by the Matlab intrinsic function
% size. For example, a class may define by convention that an object is 
% one-dimensional and hold the signal internally as a column vector.
% 
% Input:
% ------
%   w       Scalar sigvar object
%
%
% Output:
% -------
%   nd      Number of dimensions of the object
%   sz      Row vector with the extend along each dimension (numel(sz)==nd)
%
%           The convention for sigvar objects is:
%           - if w.s empty,         nd=[], sz=[]
%           - If w.s scalar,        nd=0,  sz=zeros(1,0)
%           - if w.s column vector, nd=1,  sz=length(w.s)
%           - if w.s row vector,    nd=2,  sz=size(w.s)
%           - All other cases:      nd=numel(size(w.s)),  sz=size(w.s)


if ~isempty(w.s)
    if ~isscalar(w.s)
        if size(w.s,2)>1
            sz=size(w.s);
            nd=length(sz);
        else
            sz=numel(w.s);
            nd=1;
        end
    else
        nd=0;
        sz=zeros(1,0);
    end
else
    nd=[];
    sz=[];
end
