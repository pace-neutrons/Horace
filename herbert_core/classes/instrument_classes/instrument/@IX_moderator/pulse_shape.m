function [y,t] = pulse_shape (obj, varargin)
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


if ~isscalar(obj)
    error('IX_moderator:pulse_shape:invalid_argument',...
        'Method only takes a scalar object')
end

if ~obj.valid_
    error('IX_moderator:pulse_shape:invalid_argument',...
        'Moderator object is not valid')
end

if numel(varargin)==0
    t = []; % interpreted by called functions to choose a default set of times
elseif numel(varargin)==1
    t = varargin{1};
else
    error('IX_moderator:pulse_shape:invalid_argument',...
        'Check number of input arguments')
end

models= obj.pulse_models_;
model = obj.pulse_model_;

if models.match('ikcarp',model)
    [y,t] = ikcarp_pulse_shape (obj.pp_, t);
    
elseif models.match('ikcarp_param',model)
    [y,t] = ikcarp_param_pulse_shape (obj.pp_, obj.energy_, t);
    
elseif models.match('table',model)
    [y,t] = table_pulse_shape (obj.pdf_, t);
    
elseif models.match('delta_function',model)
    [y,t] = delta_function_pulse_shape (obj.pp_, t);
    
else
    error('IX_moderator:pulse_shape:invalid_argument',...
        'Unrecognised moderator pulse model for computing pulse shape')
end

end
