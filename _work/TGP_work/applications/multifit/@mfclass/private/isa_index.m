function status = isa_index(n,nmax)
% Determine if an argument is a row vector of positive integers. Includes
% the case of an empty argument i.e. []

if isnumeric(n) && (isempty(n) || (isrowvector(n) && all(n)>0 && all(rem(n,1)==0)))
    if nargin==1 || max(n)<=nmax
        status = true;
    end
else
    status = false;
end
