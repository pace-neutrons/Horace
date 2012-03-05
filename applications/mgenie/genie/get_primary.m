function x1 = get_primary
% Get default primary flight path.
%
%   >> x1 = get_primary (efix) 
%
%  Inverse function of set_primary

global mgenie_globalvars

x1 = mgenie_globalvars.unitconv.x1;
