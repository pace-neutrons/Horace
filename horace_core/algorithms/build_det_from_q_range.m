function  [det_pos,par_file_name] = build_det_from_q_range(q_range,efix,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs,filename)
% Create fake detector file which would cover the q-range provided as input
%
% Inputs:
% q_range --  3xNdet array of [h,k,l] momentums corresponding to the
%             detectors positions (in elastic scattering)
%             or
%             3x3 matrix in the format [qh_min,qh_step,qh_max;
%             qk_min;qk_step,qk_max;ql_min;q;_step,q;_max] providing
%             q-range (at zero energy transfer) to evaluate sqw file.
%             The fake detectors positions would be calculated from the
%             q-range provided.]
%             or 1x3 vector [q_min,q_step,q_max] providing the same
%             range in all 3 hkl directions.
%
%
% Goniometer and sample position, defining q-transformation:
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
% Optional (Not implemented)
%  filename  -- if present, defines the name of the par file to save
%               detector information. If absent, detector infornation is
%               stored in mem-file.
%
% Outputs:
% det_pos     The structure containing calculated detectors positions (in
%             Horace format)
%Not implemented:
% par_file_name -- if provided, disables par file saving and contains the
%             name of mem file containing the detector positions
%             information.
%

if ischar(q_range) || ~isnumeric(q_range)
    error('FAKE_SQW:invalid_argument','q_range should be a matrix')
end
if ~exist('filename','var')
    par_file_name = ['q_det_',upper(str_random(6)),'.mem'];
    save_real_file = false;
else
    save_real_file = true;
    par_file_name  = filename;
end
if nargout > 1
    save_real_file = false;
    [fp,fn]  = fileparts(par_file_name);
    par_file_name = fullfile(fp,[fn,'.mem']);
end
if size(q_range,2) ~=3
    error('FAKE_SQW:invalid_argument',...
        'second dimension of the q-range matrix should is not 3 but %d',...
        size(q_range,2))
end
if all(size(q_range) == [3,3])
    [q1,q2,q3] = ndgrid(q_range(1,1):q_range(1,2):q_range(1,3),...
        q_range(2,1):q_range(2,2):q_range(2,3),...
        q_range(3,1):q_range(3,2):q_range(3,3));
    nq = numel(q1);
    q_range = [reshape(q1,nq,1),reshape(q2,nq,1),reshape(q3,nq,1)];
elseif all(size(q_range) == [1,3])
    [q1,q2,q3] = ndgrid(q_range(1):q_range(2):q_range(3),...
        q_range(1):q_range(2):q_range(3),...
        q_range(1):q_range(2):q_range(3));
    nq = numel(q1);
    q_range = [reshape(q1,nq,1),reshape(q2,nq,1),reshape(q3,nq,1)];
end

lat = oriented_lattice(alatt,angdeg,psi,u,v,omega,dpsi,gl,gs);
[~, ~, spec_to_rlu] = lat.calc_proj_matrix();

%
c=neutron_constants;
k_to_e = c.c_k_to_emev;
ki = sqrt(efix/k_to_e);
%
detdcn  = ([1;0;0]- spec_to_rlu\q_range'/ki)' ;
[azim,el,r] = cart2sph(detdcn(:,2),detdcn(:,3),detdcn(:,1));

det_pos = convert_to_det_pos(azim,pi/2-el,r);
%
det_pos = get_hor_format(det_pos',par_file_name);



function det_pos = convert_to_det_pos(azim,theta,r)
np = numel(azim);
det_pos = [r,theta*(180/pi),azim*(180/pi),ones(np,1),ones(np,1),(1:np)'];
