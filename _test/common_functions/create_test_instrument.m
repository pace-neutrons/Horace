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

ninst = numel(ei);
if ninst ~= numel(hz) || ninst ~= numel(chopper)
    error('HORACE:common_functions:invalid_argument', ...
        'Number of energies, frequencies and chopper definitions in the function should be equal')
end

inst = cell(1,ninst);
if ninst == 1 && ~iscell(chopper)
    chopper = {chopper};
end
for i=1:ninst
    inst{i} = maps_instrument(ei(i),hz(i),chopper{i});
end
instrument = [inst{:}];
