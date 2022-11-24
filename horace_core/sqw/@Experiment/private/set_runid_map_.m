function obj = set_runid_map_(obj,val)
%SET_RUNID_MAP_ Check and set runid_map, connecting run-id, describing the 
% experiment and the number of the experiment information header in the
% list of all experiment descriptors
%
% Main part of runid_map setter procedure
if isa(val,'containers.Map')
    obj.runid_map_ = val;
    keys = val.keys;
    keys = [keys{:}];
elseif isnumeric(val) && numel(val) == obj.n_runs
    keys = val(:)';
else
    error('HORACE:Experiment:invalid_argument', ...
        ['input for runid_map should be map, defining connection between run-ids and headers(expdata),\n', ...
        ' describing these runs or array of runid-s to set.\n', ...
        ' In fact it is: %s'], ...
        class(val))
end
obj = set_runids_map_and_synchonize_headers_(obj,keys);
%
if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end

