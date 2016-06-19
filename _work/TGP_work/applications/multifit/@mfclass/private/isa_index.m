function status = isa_index(n,nmax)
% Determine if an argument is a row vector of positive integers.
%
%   >> status = isa_index(n)
%   >> status = isa_index(n,nmax)
%
% Includes the case of an empty argument i.e. [], and case of nmax=0

if isnumeric(n) && (isempty(n) || (isrowvector(n) && all(n)>0 && all(rem(n,1)==0))) &&...
        (nargin==1 || max(n)<=nmax)
    status = true;
else
    status = false;
end
