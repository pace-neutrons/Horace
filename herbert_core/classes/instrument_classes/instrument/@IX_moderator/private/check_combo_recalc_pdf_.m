function obj = check_combo_recalc_pdf_(obj,do_recompute_pdf)
%
if ~all(obj.mandatory_field_set_)
    mandatory_field_names = obj.saveableFields('mandatory');
    error('HERBERT:IX_moderator:invalid_argument', ...
        ' Must give all mandatory properties namely: %s.\n Properties: %s have not been set', ...
        disp2str(mandatory_field_names), ...
        disp2str(mandatory_field_names(~obj.mandatory_field_set_)));
end
% check pulse model parameters. Its mandatory parameters so they have been
% set
valid = isnumeric(obj.pp_) && (numel(obj.pp_)==obj.n_pp_(obj.pulse_model_) || ...
    isinf(obj.n_pp_(obj.pulse_model_))) || isnan(obj.n_pp_(obj.pulse_model_));
if ~valid
    error('HERBERT:IX_moderator:invalid_argument',...
        'The number or type of pulse parameters is inconsistent with the pulse model')
end

flux_model_prop_set = sum(obj.flux_model_par_set_);
if flux_model_prop_set  == 1
    error('HERBERT:IX_moderator:invalid_argument',...
        'Must give flux model and flux model parameters together')
elseif flux_model_prop_set == 2
    % Must check the number of parameters is consistent with the flux model
    if numel(obj.pf_)~=obj.n_pf_(obj.flux_model_)
        error('IX_moderator:invalid_argument',...
            'The number of flux parameters is inconsistent with the flux model')
    end
end
%
if do_recompute_pdf
    obj.pdf_ = recompute_pdf_(obj);   % recompute the lookup table
end
