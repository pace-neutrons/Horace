function [width, tlo, thi] = pulse_width2 (self, frac, varargin)
% Calculate the standard deviation of the moderator pulse shape
%
%   >> [width, tlo, thi] = pulse_width2 (moderator, frac)
%   >> [width, tlo, thi] = pulse_width2 (moderator, frac, ei)
%
% Input:
% ------
%   moderator   IX_moderator object
%   frac        Fraction of peak height at which to determine the width
%   ei          Incident energy (meV) (array or scalar)
%               If omitted or empty, use the ei value in the IX_moderator object
%
% Output:
% -------
%   width       Width across the peak (microseconds)
%   tlo         Short time fractinal height (microseconds)
%   thi         High time fractinal height (microseconds)


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
    [width, tlo, thi] = ikcarp_pulse_width2 (self.pp_, frac, energy);
    
elseif models.match('ikcarp_param',model)
    [width, tlo, thi] = ikcarp_param_pulse_width2 (self.pp_, frac, energy);
    
elseif models.match('table',model)
    [width, tlo, thi] = table_pulse_width2 (self.pdf_, frac, energy);
    
else
    error('Unrecognised moderator pulse model for computing pulse width')
end
