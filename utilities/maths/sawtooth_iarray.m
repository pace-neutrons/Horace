function ivout = sawtooth_iarray (n)
% Create array of successive runs [1,2,3..n(1),1,2,3...n(2),...]'
%
%   >> ivout = sawtooth_iarray (n)
%
% Input:
% ------
%   n       List of length of each sawtooth section (integer)
%          (Zeros correspond to zero length section i.e. they are
%           effectively ignored).
%           Must have all(n(:)>=0).
%
% Output:
% -------
%   ivout   Output array: column vector
%               ivout=[1:n(1),1:n(2),...]'
%
% NOTE: This is designed for integer array n only, as it assumes that
%       there are no rounding errors on addition.

% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)

nn0=n(n>0);
nn0=nn0(:);
if ~isempty(nn0)
    nend=cumsum(nn0);
    tmp=ones(nend(end),1);
    ix=1+nend(1:end-1);
    if ~isempty(ix)
        tmp(ix)=tmp(ix)-nn0(1:end-1);
    end
    ivout=cumsum(tmp);
else
    ivout=[];
end
