function status = pulse_depends_on_ei(moderator)
% Informs of the dependency of any characteristics of the moderator time pulse on ei
%
%   >> status = pulse_depends_on_ei(moderator)
%
% Input:
% -------
%   moderator   IX_moderator object
%
% Output:
% -------
%   status      =true  if the moderator pulse depends on incident neutron energy
%               =false otherwise

if ~isscalar(moderator), error('Function only takes a scalar object'), end

model=moderator.pulse_model;
if strcmp(model,'ikcarp')           % Raw Ikeda Carpenter
    status=false;
elseif strcmp(model,'ikcarp_param') % Ikeda-Carpenter with parametrised tauf, taus, R
    status=true;
else
    error('Unrecognised pulse model')
end
