function val = effic_alf (alf)
% Efficiency of a slab detector
%
%   >> val = effic_alf (alf)
%
% Input:
% ------
%   alf     Thickness of slab as a multiple of the attenuation length
%          (scalar or array)
%
% Output:
% -------
%   val     Efficiency (in range 0 to 1)
%
%
% The algorithm evaluates:
%
%       1- exp(-alf)
%
% in a numerically robust way for small alf.


small = (alf<0.1);
C = [1,-1./(2:10)];

val = zeros(size(alf));
val(~small) = 1 - exp(-alf(~small));
val(small) = series_eval (alf(small),C,1);
