function ok=equal_to_relerr(x1,x2,tol)
% Determine if two numbers are equal to within a given relative tolerance
%
%   >> ok=equal_to_relerr(x1,x2,tol)
%

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if x1==x2
    ok=true;
else
    ok = abs(x2-x1)/max(abs([x1,x2]))<=tol;
end
