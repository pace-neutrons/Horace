function y=pulse_shape(moderator,ei,t)
% Calculate normalised moderator pulse shape as a function of time in microseconds
%
%   >> y=pulse_shape(moderator,ei,t)
%
% Input:
% -------
%   moderator   IX_moderator object
%   ei          Incident energy (meV) (scalar)
%   t           Array of times at which to evaluate pulse shape (microseconds)
%
% Output:
% -------
%   y           Array of values of pulse shape. Normalised so pulse has unit area

if ~isscalar(moderator), error('Function only takes a scalar object'), end

model=moderator.pulse_model;
if strcmp(model,'ikcarp')           % Raw Ikeda Carpenter
    y=pulse_shape_ikcarp(moderator.pp,ei,t);
elseif strcmp(model,'ikcarp_param') % Ikeda-Carpenter with parametrised tauf, taus, R
    y=pulse_shape_ikcarp_param(moderator.pp,ei,t);
else
    error('Unrecognised pulse model')
end
