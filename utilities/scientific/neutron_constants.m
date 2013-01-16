function s=neutron_constants
% Return a structure with constants for neutron units manipulation
%
%   >> s=neutron_constants      % return structure
%   >> neutron_constants        % list constants

persistent structure

if isempty(structure)
    p=physical_constants;
    structure.c_t_to_k  = 1e3*p.neutron_mass_mantissa/p.hbar_mantissa;
    structure.c_t_to_lam= 2*pi/structure.c_t_to_k;
    structure.c_t_to_emev = 0.5e7*p.neutron_mass_mantissa/p.electron_charge_mantissa;
    structure.c_t_to_ewav = 0.5e9*p.neutron_mass_mantissa/(2*pi*p.hbar_mantissa*p.speed_of_light_mantissa);
    structure.c_t_to_ethz = 0.5e7*p.neutron_mass_mantissa/(2*pi*p.hbar_mantissa);
    structure.c_t_to_q  = 2*structure.c_t_to_k;
    structure.c_t_to_sq = structure.c_t_to_q^2;
    structure.c_t_to_d  = 2*pi/structure.c_t_to_q;
    structure.c_emev_to_ewav = 100*p.electron_charge_mantissa/(2*pi*p.hbar_mantissa*p.speed_of_light_mantissa);
    structure.c_emev_to_ethz  = p.electron_charge_mantissa/(2*pi*p.hbar_mantissa);
    structure.c_k_to_emev = 5*p.hbar_mantissa*p.hbar_mantissa/(p.neutron_mass_mantissa*p.electron_charge_mantissa);
end

if nargout>0
    s=structure;
else
    nam=fieldnames(structure);
    disp('Available constants:')
    disp('--------------------')
    for i=1:numel(nam)
        disp(nam{i})
    end
end
