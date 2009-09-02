function ok=equal_to_relerr(x1,x2,tol)
% Determine if two numbers are equal to within a given relative tolerance
%
%   >> ok=equal_to_relerr(x1,x2,tol)
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if x1==x2
    ok=true;
else
    ok = abs(x2-x1)/max(abs([x1,x2]))<=tol;
end
