function ok=equal_to_relerr(x1,x2,tol,min_denominator)
% Determine if all elements in a pair of arrays are equal to within a given relative tolerance
%
%   >> ok=equal_to_relerr(x1,x2,tol)
%   >> ok=equal_to_relerr(x1,x2,tol,min_denominator)
%
% The relative error is defined as:
%   relerr = abs(a-b)/max(abs(a),abs(b))
%
% or, if min_denominator is given:
%   relerr = abs(a-b)/max(abs(a),abs(b),abs(min_denominator))
% 
% The latter case is useful if it is possible that a and b are both very close to zero
% with rounding errors in calculation possibly responsible for a large relative error.

% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)

if all(x1(:)==x2(:))
    ok=true;
else
    if nargin==3
        ok = all(abs(x2(:)-x1(:))./max(abs(x1(:)),abs(x2(:)))<=tol);
    else
        ok = all(abs(x2(:)-x1(:))./max(max(abs(x1(:)),abs(x2(:))),abs(min_denominator)*ones(numel(x1),1))<=tol);
    end
end

