function [y,t] = pulse_shape (self, varargin)
% Calculate normalised moderator pulse shape as a function of time in microseconds
%
%   >> [y,t] = pulse_shape (moderator)
%   >> y = pulse_shape (moderator, t)
%
% Input:
% ------
%   moderator   IX_moderator object
%
%   t           Array of times at which to evaluate pulse shape (microseconds)
%               If omitted or empty, a default suitable set of points for a plot is used
%
% Output:
% -------
%   y           Array of values of pulse shape. Normalised so pulse has unit area
%
%   t           If input was not empty, same as imput argument
%               If input was not given or empty, the default set of points


if ~isscalar(self), error('Method only takes a scalar moderator object'), end
if ~self.valid_
    error('Moderator object is not valid')
end

if numel(varargin)==0
    t = []; % interpreted by called functions to choose a default set of times
elseif numel(varargin)==1
    t = varargin{1};
else
    error('Check number of input arguments')
end

models= self.pulse_models_;
model = self.pulse_model_;

if models.match('ikcarp',model)
    [y,t] = ikcarp_pulse_shape (self.pp_, t);
    
elseif models.match('ikcarp_param',model)
    [y,t] = ikcarp_param_pulse_shape (self.pp_, self.energy_, t);
    
elseif models.match('table',model)
    [y,t] = table_pulse_shape (self.pdf_, t);
    
else
    error('Unrecognised moderator pulse model for computing pulse width')
end
