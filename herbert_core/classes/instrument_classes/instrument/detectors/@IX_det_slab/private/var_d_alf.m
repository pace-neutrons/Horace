function val = var_d_alf (alf)
% Variance of depth of absorption in a slab detector
%
%   >> val = var_d_alf (alf)
%
% Input:
% ------
%   alf     Thickness of slab as a multiple of the attenuation length
%          (scalar or array)
%
% Output:
% -------
%   val     Variance of depth of absorption along the neutron path as a
%          multiple of thickness along the neutron path
%
% The algorithm evaluates:
%
%       (1/alf^2)(1 - (alf^2)*exp(-alf)/(1-exp(-alf))^2)
%
% in a numerically robust way for small alf.


small = (alf<0.35);
C = [1/12, -1/20, -5/126, -7/200, -5/154, -7601/245700, -455/15202];

val = zeros(size(alf));

% Large alf:
alfbig = alf(~small);
expon = exp(-alfbig);
val(~small) = 1./alfbig.^2 - expon./(1-expon).^2;

% Small alf
alfsmall = alf(small);
val(small) = series_eval (alfsmall.^2,C);
