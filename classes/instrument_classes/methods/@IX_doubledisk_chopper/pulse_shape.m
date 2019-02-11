function y=pulse_shape(disk,t)
% Calculate normalised chopper pulse shape as a function of time in microseconds
%
%   >> y=pulse_shape(disk,ei,t)
%
% Input:
% -------
%   disk    IX_doubledisk_chopper object
%   t       Array of times at which to evaluate pulse shape (microseconds)
%
% Output:
% -------
%   y       Array of values of pulse shape.
%           Normalised so pulse area is transmission(disk)
%           Note that transmission(disk) is in fact unity independent of energy


if ~isscalar(disk), error('Function only takes a scalar object'), end

[T1,T2] = hat_times(disk);
y = conv_hh (t,T1,T2);
