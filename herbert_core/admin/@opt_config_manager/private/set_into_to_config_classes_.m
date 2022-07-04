function set_into_to_config_classes_(obj,set_defaults_only,force_save)
% sets default info into a configuration classes
%
conf = obj.current_config_;
flds = fieldnames(conf);
for i=1:numel(flds)
    if strcmpi(flds{i},'info') % skip info string
        continue;
    end
    % A configuration is stored in the configuration list but to be put on Matlab path later
    if ~any(ismember(obj.known_configs_,flds{i}))
        continue;
    end
    conf_cl = feval(flds{i});
    if set_defaults_only
        if ~conf_cl.is_default
            continue
        end
    end
    settings = conf.(flds{i});
    conf_cl.set_stored_data(settings);
    if force_save
        config_store.instance().store_config(conf_cl,'-forcesave');
    end
end