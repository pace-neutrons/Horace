function instrument = create_test_instrument(ei,hz,chopper)
% Return instrument description for MAPS
%
%   >> instrument = maps_instrument(ei,hz,chopper)
%
% Input:
% ------
%   ei          Incident energy (meV)
%   hz          Chopper frequency
%   chopper     Fermi chopper package name ('S','A', or 'B')


instrument = maps_instrument(ei,hz,chopper);
