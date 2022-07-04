function val = mean_d_alf (alf)
% Mean depth of absorption in a slab detector
%
%   >> val = mean_d_alf (alf)
%
% Input:
% ------
%   alf     Thickness of slab as a multiple of the attenuation length
%          (scalar or array)
%
% Output:
% -------
%   val     Mean depth of absorption along the neutron path as a multiple
%          of thickness along the path
%
% The algorithm evaluates:
%
%       -1/2 +(1/alf)(1 - alf*exp(-alf)/(1-exp(-alf)))
%
% in a numerically robust way for small alf.


small = (alf<0.1);
C = [-1/12, -1/60, -1/42, -1/40, -5/198];

val = zeros(size(alf));

% Large alf:
alfbig = alf(~small);
expon = exp(-alfbig);
val(~small) = -0.5 + 1./alfbig - expon./(1-expon);

% Small alf
alfsmall = alf(small);
val(small) = alfsmall.*series_eval (alfsmall.^2,C);
