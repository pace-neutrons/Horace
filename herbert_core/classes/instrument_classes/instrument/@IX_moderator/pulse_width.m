function [dt, t_av, fwhh] = pulse_width (self, varargin)
% Calculate the standard deviation of the moderator pulse shape
%
%   >> [dt, t_av, fwhh] = pulse_width (moderator)
%   >> [dt, t_av, fwhh] = pulse_width (moderator, ei)
%
% Input:
% ------
%   moderator   IX_moderator object
%   ei          Incident energy (meV) (array or scalar)
%               If omitted or empty, use the ei value in the IX_moderator object
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%   t_av        First moment (microseconds)
%   fwhh        FWHH (microseconds)


if ~isscalar(self), error('Function only takes a scalar moderator object'), end
if ~self.valid_
    error('Moderator object is not valid')
end

if numel(varargin)==0
    energy = self.energy_;
elseif numel(varargin)==1
    energy = varargin{1};
else
    error('Check number of input arguments')
end

models= self.pulse_models_;
model = self.pulse_model_;

if models.match('ikcarp',model)
    [dt, t_av, fwhh] = ikcarp_pulse_width (self.pp_, energy);
    
elseif models.match('ikcarp_param',model)
    [dt, t_av, fwhh] = ikcarp_param_pulse_width (self.pp_, energy);
    
elseif models.match('table',model)
    [dt, t_av, fwhh] = table_pulse_width (self.pdf_, energy);
    
else
    error('Unrecognised moderator pulse model for computing pulse width')
end
