function  lat = convert_old_input_to_lat(varargin)
% Convert old style input, containing lattice and goniometer parameter into
% oriented lattice
%
% Inputs:
%
% alatt           Lattice parameters (Ang^-1)  [vector length 3, or array size [nfile,3]]
% angdeg          Lattice angles (deg)         [vector length 3, or array size [nfile,3]]
% u               First vector defining scattering plane (r.l.u.)  [vector length 3, or array size [nfile,3]]
% v               Second vector defining scattering plane (r.l.u.) [vector length 3, or array size [nfile,3]]
%^1 psi           Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%^2 omega         Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%^2 dpsi          Correction to psi (deg)            [scalar or vector length nfile]
%^2 gl            Large goniometer arc angle (deg)   [scalar or vector length nfile]
%^2 gs            Small goniometer arc angle (deg)   [scalar or vector length nfile]
% Notes:
% nfile considered to be max dimension of scalar variables or first
%       dimension of vecor variable. All parameters with nfiles 1 are expanded
%       to size nfiles as the result of this method.
% ^1    This parameter is optional for some formats of spe files. If
%       provided, overides the information contained in the the "spe" file.
% ^2    Optional parameter. If absent, the default value defined by the class
%       is used instead;
%
% Returns:
% lat   [nfile,1] array of oriented lattice objects initialized by input
%       variables.
%
%
if nargin<5
    error('HERBERT:convert_old_input:invalid_argument',...
        'At least 5 input arguments alatt,angdeg,u,v and psi are requested. Got %d arguments',...
        nargin);
end
% gensqw old format call was:
%  [1       2    3 4  5]
% alatt, angdeg,u,v,psi
% oriented lattice requests:
% alatt,angdeg,psi,u,v
%  1      2     5  3 4
% Rearrange parameters:
seq = 1:numel(varargin);
seq(3) = 5; seq(4) = 3; seq(5) =4;
lat_par = varargin(seq);
n_latpar = numel(lat_par);
% The names of the rearranged input parameters
latpar_names={'alatt','angdeg','psi','u','v','omega','dpsi','gl','gs'};
% sizes of the rearranged lattice and goniometer parameters:
par_sizes   = [3,3,1,3,3,1,1,1,1];

%identify the replication factor, which is provided as multiple values of
% some variable:
lat_par_sizes = arrayfun(@(x)numel(x{1}),lat_par);
if numel(lat_par_sizes) < numel(par_sizes)
    par_sizes = par_sizes(1:numel(lat_par_sizes));
end
lat_rep = lat_par_sizes./par_sizes;
rep_factor = max(lat_rep);
% Replicate all
if rep_factor > 1
    % check if all parameters to replicate have correct size:
    not_acceptable = lat_rep>1 & lat_rep ~= rep_factor;
    if any(not_acceptable)
        ind = find(not_acceptable);
        error('HERBERT:convert_old_input:invalid_argument',...
            'All input parameters should have size 1 or %d. In fact, the parameters N%s have sizes: %s',...
            rep_factor,evalc('disp(ind)'),evalc('disp(lat_par_sizes(ind))'))
    end
    lat = repmat(oriented_lattice,rep_factor,1);
    for j=1:rep_factor
        for i=1:n_latpar
            val = lat_par{i};
            name= latpar_names{i};
            if numel(val) == par_sizes(i)
                lat(j).(name) = val;
            else
                if par_sizes(i)>1
                    lat(j).(name) = val(j,:);
                else
                    lat(j).(name) = val(j);
                end
            end
        end
    end
else
    lat = oriented_lattice(lat_par{:});
end
