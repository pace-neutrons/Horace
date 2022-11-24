function obj = check_and_set_expdata_(obj,val)
%CHECK_AND_SET_EXPDATA_ check and set the classes, containing main
%information about every run of the experiment

if all(isempty(val))
    if ~isa(val,'IX_experiment')
        obj.expdata_ = [];
        obj.runid_map_ = [];
        return;
    end
end
if ~isa(val,'IX_experiment')
    error('HORACE:Experiment:invalid_argument', ...
        'Sample must be one or an array of IX_experiment objects or empty. Actually it is: %s',...
        class(val))
end
obj.expdata_ = val(:)';
obj = build_runid_map_(obj);

if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end
