function [dt, t_av, fwhh] = pulse_width (obj, varargin)
% Calculate the standard deviation of the moderator pulse shape
%
%   >> [dt, t_av, fwhh] = pulse_width (moderator)
%   >> [dt, t_av, fwhh] = pulse_width (moderator, ei)
%
% Input:
% ------
%   obj         IX_moderator object
%
%   ei          Incident energy (meV) (array or scalar)
%               If omitted or empty, use the ei value in the IX_moderator object
%
% Output:
% -------
%   dt          Standard deviation of pulse width (microseconds)
%
%   t_av        First moment (microseconds)
%
%   fwhh        FWHH (microseconds)


if ~isscalar(obj)
    error('IX_moderator:pulse_width:invalid_argument',...
        'Method only takes a scalar object')
end

if ~obj.valid_
    error('IX_moderator:pulse_width:invalid_argument',...
        'Moderator object is not valid')
end

if numel(varargin)==0
    energy = obj.energy_;
elseif numel(varargin)==1
    energy = varargin{1};
else
    error('IX_moderator:pulse_width:invalid_argument',...
        'Check number of input arguments')
end

models= obj.pulse_models_;
model = obj.pulse_model_;

if models.match('ikcarp',model)
    [dt, t_av, fwhh] = ikcarp_pulse_width (obj.pp_, energy);
    
elseif models.match('ikcarp_param',model)
    [dt, t_av, fwhh] = ikcarp_param_pulse_width (obj.pp_, energy);
    
elseif models.match('table',model)
    [dt, t_av, fwhh] = table_pulse_width (obj.pdf_, energy);
    
elseif models.match('delta_function',model)
    [dt, t_av, fwhh] = delta_function_pulse_width (obj.pp_, energy);
    
else
    error('IX_moderator:pulse_width:invalid_argument',...
        'Unrecognised moderator pulse model for computing pulse width')
end
