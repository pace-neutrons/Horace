function obj = check_combo_arg_(obj)
%CHECK_COMBO_ARG_ Check validity of interdependent fields
%
%   >> obj = check_combo_arg(w)
%
% Throws 'HORACE:CurveProjBase:invalid_argument' or
% 'HORACE:kf_sphere_proj:not_implemented' depending on the
% issue containing the message suggesting the reason for
% failure if the inputs are inconsistent with each other.
%
% Normalizes input vectors to unity and constructs the
% transformation to new coordinate system when operation is
% successful
if any(abs(obj.offset_)>eps('double'))
    error('HORACE:kf_sphere_proj:not_implemented',[ ...
        'non-zero offset is not implemented for this type of projection.\n' ...
        'There are doubts that it should be implemented at all'])
end
if isempty(obj.Ei_)
    obj.ki_mod_ = 0;
    obj.ki_ = [0,0,0];
end

if ~(isempty(obj.run_id_mapper_)&&isempty(obj.cc_to_spec_mat_)) % allow construction with Ei only
    if obj.run_id_mapper_.n_members ~= numel(obj.cc_to_spec_mat_)
        error('HORACE:kf_sphere_proj:invalid_argument',[ ...
            'number of transformation matrices must be equal to number of keys\n' ...
            'which describe relation between these marrices and pixels run-id\n' ...
            'In fact, they are different. N-martices: %d, n_keys: %d '], ...
            numel(obj.cc_to_spec_mat_),obj.run_id_mapper_.n_members);
    end
end
if obj.emode_ == 1
    obj.ki_mod_ = sqrt(obj.Ei_/neutron_constants('c_k_to_emev')); % incident
    obj.ki_ = [obj.ki_mod_;0;0];
elseif obj.emode_==2
    error('HORACE:kf_sphere_proj:not_implemented', ...
        'kf_sphere_proj is not yet implemented for emode %d', ...
        obj.emode_)
    %obj.ki_mod_=sqrt((efix+eps(:))/neutron_constants('c_k_to_emev')); % [ne x 1]
else
    error('HORACE:kf_sphere_proj:not_implemented', ...
        'kf_sphere_proj is not implemented for emode %d', ...
        obj.emode_)
end
