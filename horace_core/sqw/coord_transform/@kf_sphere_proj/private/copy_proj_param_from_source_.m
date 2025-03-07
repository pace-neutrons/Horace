function obj = copy_proj_param_from_source_(obj,cut_source)
% COPY_PROJ_PARAM_FROM_SOURCE_ core of overloaded aProjectionBase
% copy_proj_param_from_source method, which sets up kf_sphere_proj
% specific properties necessary for this kind of projection to work.
%
% Namely, in addition to standard projection properties, this
% projection works on sqw objects only and requests incident
% energies and set of transformation matrices, used for
% convertion from instrument frame to Crystal Cartesian
% coordinate system. These matrices are stored in
% Experiment/IX_dataset array.

if ~isa(cut_source,'sqw')
    error('HORACE:kf_sphere_proj:invalid_argument', ...
        'this projection may be used to cut sqw objects only. It does not work on %s', ...
        class(cut_source));
end
% retrieve common projection parameters

%
experiment  = cut_source.experiment_info;
emodes = experiment.get_emode();
efix_cor = experiment.get_efix(true);
if efix_cor.n_unique > 1
    error('HORACE:kf_sphere_proj:not_implemented', ...
        'Processing multiple incident energies is not yet implemented')
end
obj.do_check_combo_arg = false;

obj.Ei = efix_cor.unique_val{1};
obj.emode_ = emodes(1);
%TODO: retrieve energy transfer values if it is indirect mode
%(not yet implemented)

% retrieve matrices used for conversion from Crystal Cartesian to
% spectrometer coordinate system.
ix_exper = experiment.expdata;
alatt  = obj.alatt;
angdeg = obj.angdeg;
obj.cc_to_spec_mat_ = arrayfun(...
    @(ex) inv(calc_proj_matrix(ex,alatt, angdeg,1)), ix_exper, 'UniformOutput', false);
obj.do_check_combo_arg = true;
obj.run_id_mapper_ = experiment.runid_map;

obj = obj.check_combo_arg();
