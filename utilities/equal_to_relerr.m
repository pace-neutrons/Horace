function ok=equal_to_relerr(x1,x2,tol)
% Determine if two numbers are equal to within a given relative tolerance
%
%   >> ok=equal_to_relerr(x1,x2,tol)
%

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

if x1==x2
    ok=true;
else
    ok = abs(x2-x1)/max(abs([x1,x2]))<=tol;
end
