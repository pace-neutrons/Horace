function [] = set_primary (x1)
% Set default moderator-to-sample distance for the current run
%
%   >> set_primary (x1)
%
% To view current values:
%   >> set_primary
%
% Inverse function of get_primary

global mgenie_globalvars

% Check arguments and set parameters:
small=1e-10;
if isa(x1,'double') && isscalar(x1)
    if x1<small
        error ('Moderator-sample distance must be greater than zero')
    end
    mgenie_globalvars.unitconv.x1 = x1;
else
    error('Check parameter type and size')
end

% Print values to screen
disp(['                       Fixed energy (meV) : ',num2str(mgenie_globalvars.unitconv.efix,5)])
disp(['            Moderator-sample distance (m) : ',num2str(mgenie_globalvars.unitconv.x1,5)])
disp(['                              Energy mode : ',num2str(mgenie_globalvars.unitconv.emode)])
disp(' ')
