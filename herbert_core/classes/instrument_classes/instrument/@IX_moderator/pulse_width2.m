function [width, tmax, tlo, thi] = pulse_width2 (obj, frac, varargin)
% Calculate the positions of the peak and fractional heights of the pulse shape
%
%   >> [width, tmax, tlo, thi] = pulse_width2 (moderator, frac)
%   >> [width, tmax, tlo, thi] = pulse_width2 (moderator, frac, ei)
%
% Input:
% ------
%   obj         IX_moderator object
%
%   frac        Fraction of peak height at which to determine the width
%
%   ei          Incident energy (meV) (array or scalar)
%               If omitted or empty, use the ei value in the IX_moderator object
%
% Output:
% -------
%   width       Width across the peak (microseconds)
%
%   tmax        Position of peak maximum (microseconds)
%
%   tlo         Short time fractional height (microseconds)
%
%   thi         High time fractional height (microseconds)


if ~isscalar(obj)
    error('IX_moderator:pulse_width2:invalid_argument',...
        'Method only takes a scalar object')
end

if ~obj.valid_
    error('IX_moderator:pulse_width2:invalid_argument',...
        'Moderator object is not valid')
end

if numel(varargin)==0
    energy = obj.energy_;
elseif numel(varargin)==1
    energy = varargin{1};
else
    error('IX_moderator:pulse_width2:invalid_argument',...
        'Check number of input arguments')
end

models= obj.pulse_models_;
model = obj.pulse_model_;

if models.match('ikcarp',model)
    [width, tmax, tlo, thi] = ikcarp_pulse_width2 (obj.pp_, frac, energy);
    
elseif models.match('ikcarp_param',model)
    [width, tmax, tlo, thi] = ikcarp_param_pulse_width2 (obj.pp_, frac, energy);
    
elseif models.match('table',model)
    [width, tmax, tlo, thi] = table_pulse_width2 (obj.pdf_, frac, energy);
    
elseif models.match('delta_function',model)
    [width, tmax, tlo, thi] = delta_function_pulse_width2 (obj.pp_, frac, energy);
    
else
    error('IX_moderator:pulse_width2:invalid_argument',...
        'Unrecognised moderator pulse model for computing pulse width')
end

end
