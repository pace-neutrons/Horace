function inst = maps2_instrument(varargin)
% Return instrument description for MAPS after the guide upgrade in 2017.
%
% *** BACKWARDS COMPATIBILITY FUNCTION - deprecated ***
%
%     Please use maps_instrument instead
%
%   >> inst = maps2_instrument(ei,hz,chopper)
%
% Input:
% ------
%   ei          Incident energy (meV)
%   hz          Chopper frequency
%   chopper     Fermi chopper package name ('S','A', or 'B')

inst = maps_instrument (varargin{:}, '-version', 2);
