function [nd,sz] = dimensions(w)
% Find number of dimensions and extent along each dimension of
% the signal arrays. 
% - if w.s empty,         nd=[], sz=[] (nb: [] == zeros(0,0))
% - If w.s scalar,        nd=0,  sz=zeros(1,0)
% - if w.s column vector, nd=1,  sz=length(w.s)
% - if w.s row vector,    nd=2,  sz=size(w.s)
%
% - All other cases:      nd=length(size(w.s)),  sz=size(w.s)
%  (this is the case if row vector too)
%
% The convention is that size(sz)=1 x ndim
%
%   >> [nd,sz]=dimensions(w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

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
