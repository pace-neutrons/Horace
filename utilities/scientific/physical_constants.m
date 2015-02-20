function s=physical_constants
% Return a structure with physical constants and their mantissa
%
%   >> s=physical_constants     % return structure
%   >> physical_constants       % list constants
%
%   The structure s contains constants and their mantissas and exponents
%  e.g.  s.speed_of_light=2.99792458e8
%        s.speed_of_light_mantissa=2.99792458
%        s.speed_of_light_exponent=8


mlock;  % for stability
persistent structure

if isempty(structure)
    % ** VERY IMPORTANT NOTE **
    % It is assumed that trios of contant, mantissa and exponent are provided
    % Make sure that any additions follow this pattern, no matter how trivial it seems!
    structure.neutron_mass=1.67492716e-27;
    structure.neutron_mass_mantissa=1.67492716;
    structure.neutron_mass_exponent=-27;
    structure.hbar=1.054571596e-34;
    structure.hbar_mantissa=1.054571596;
    structure.hbar_exponent=-34;
    structure.electron_charge=1.602176462e-19;
    structure.electron_charge_mantissa=1.602176462;
    structure.electron_charge_exponent=-19;
    structure.speed_of_light=2.99792458e8;
    structure.speed_of_light_mantissa=2.99792458;
    structure.speed_of_light_exponent=8;
    structure.boltzman_K_in_meV=8.6173324e-2;
    structure.boltzman_K_in_meV_mantissa=8.6173324;
    structure.boltzman_K_in_meV_exponent=-2;
end

if nargout>0
    s=structure;
else
    nam=fieldnames(structure);
    disp('Available constants: (<name>, <name>_mantissa, <name>_exponent')
    disp('--------------------------------------------------------------')
    for i=1:3:numel(nam)
        disp(nam{i})
    end
end
