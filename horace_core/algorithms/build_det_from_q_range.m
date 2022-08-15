function  [det_pos,par_file_name] = build_det_from_q_range(q_range,efix,lattice,varargin)
% Create fake detector file which would cover the q-range provided as input
%
% Inputs:
% q_range --  3xNdet array of [h,k,l] momentum transfers, corresponding to the
%             detectors positions (in elastic scattering)
%             or
%             3x3 matrix in the format [qh_min,qh_step,qh_max;
%             qk_min;qk_step,qk_max;ql_min;q;_step,q;_max] providing
%             q-range (at zero energy transfer) to evaluate sqw file.
%             The fake detectors positions would be calculated from the
%             q-range provided.]
%             or 1x3 vector [q_min,q_step,q_max] providing the same
%             range in all 3 hkl directions.
%     TODO: allow to accept any energy loss (not only elastic) in direct
%           and indirect modes.
%
%
% Goniometer and sample position, defining q-transformation:
%   efix       Fixed energy (meV)                 [scalar or vector length nfile]
%   lattice    oriented_lattice object, defining the transformation from
%
% Optional (Not implemented)
%  filename  -- if present, defines the name of the par file to save
%               detector information. If absent, detector information is
%               returned in outputs.
%
% Outputs:
% det_pos     The structure containing calculated detectors positions (in
%             Horace format)
%Not implemented:
% par_file_name -- if provided, disables par file saving and contains the
%             name of mem file containing the detector positions
%             information.
%
if isnumeric(lattice) % old style inputs, left here for compartibility with
    % old code
    % Here alatt, angdeg and other lattice components are provided
    % separately as inputs for the function.
    if ischar(varargin{end}) && ~ismember(varargin{end},{'deg','rad'})
        filename = varargin{end};
        last_par = numel(varargin)-1;
    else
        filename = '';
        last_par = numel(varargin);
    end
    lattice = convert_old_input_to_lat(lattice,varargin{1:last_par});
else
    if nargin<4
        filename ='';
    else
        filename = varargin{end};
    end
end
if ~(ischar(filename)|| isstring(filename))
    error('HORACE:build_det_from_q_range:invalid_argument',...
        '4-th parameter, if present, have to be a string, describing generated detectors filename')
end


if ischar(q_range) || ~isnumeric(q_range)
    error('HORACE:build_det_from_q_range:invalid_argument',...
        'q_range should be a matrix')
end
if isempty(filename)
    par_file_name = ['q_det_',upper(str_random(6)),'.mem'];
else
    par_file_name  = filename;
end
if nargout > 1
    [fp,fn]  = fileparts(par_file_name);
    par_file_name = fullfile(fp,[fn,'.mem']);
end
if size(q_range,2) ~=3
    error('HORACE:build_det_from_q_range:invalid_argument',...
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

[~, ~, spec_to_rlu] = lattice.calc_proj_matrix();

% TODO: Done for elastic only. Make the same for two other modes
% if memory transfers are provided for inelastic (direct and indirect):
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
