function del_out=delta_array(w1,w2,tol,verbose)
% Report the different between two numerical arrays
%
%   >> delta_array(w1,w2)
%   >> delta_array(w1,w2,tol)           % -ve tol then |tol| is relative tolerance
%   >> delta_array(w1,w2,tol,verbose)   % verbose=true then print message even if equal
%
%   >> del = delta_IX_dataset_nd(...)
%
% Input:
% ------
%   w1, w2  Arrays to be compared (must both have the same number of elements)
%   tol     Tolerance criterion for equality
%               if tol>=0, then absolute tolerance
%               if tol<0, then relative tolerance
%   verbose If verbose=true then print message even if equal
%
% Output:
% -------
%   del     Scalar containing maximum difference
%           Absolute or relative according to sign of tol

if ~exist('tol','var')||isempty(tol), tol=0; end
if ~exist('verbose','var')||isempty(tol), verbose=false; end

if numel(w1)~=numel(w2)
    error('arrays contain different number of elements')
end

[del,delrel]=del_calc(w1,w2);
if tol<0
    if nargout>0, del_out=delrel; end
    if delrel<=abs(tol)
        if verbose, disp('Numerically equal objects'), end
    else
        disp(['WARNING: Numerically unequal objects:    ',num2str(delrel)])
    end
else
    if nargout>0, del_out=del; end
    if del<=tol
        if verbose, disp('Numerically equal objects'), end
    else
        disp(['WARNING: Numerically unequal objects:    ',num2str(del)])
    end
end


%============================================================================================
function [del,delrel]=del_calc(v1,v2)
% Get absolute and relative differences between two column vectors.
%
%   >> [del,delrel]=del_calc(v1,v2)
%
% Where the maximum absolute magnitude of a pair of elements is less than unity, it is treated as unity
% i.e. the relative difference becomes the absolute difference, or equivalently, the
% returned relative difference is alway less than or equal to the absolute difference.
% This is to avoid problems with large relative differences from rounding errors, which
% is against the spirit of the check that this function is designed for.
%
% Note that if divide by zero, then the NaNs are ignored in the max function, so no problem!
num=v1(:)-v2(:);
den=max(max(abs(v1(:)),abs(v2(:))),1);
del=max(abs(num));
delrel=max(abs(num)./den);
