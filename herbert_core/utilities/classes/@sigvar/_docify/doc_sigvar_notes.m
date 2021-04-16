% Requires that objects have the following methods to find the size of the
% public signal and variance arrays, create a sigvar object from those
% arrays, and set them from another sigvar object.
%
%	>> sz = sigvar_size(obj)    % Returns size of public signal and variance
%                               % arrays
%	>> w = sigvar(obj)          % Create a sigvar object from the public
%                               % signal and variance arrays
%	>> obj = sigvar_set(obj,w)  % Set signal and variance in an object from
%                               % those in a sigvar object
