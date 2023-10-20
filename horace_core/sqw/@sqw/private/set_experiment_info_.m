function obj = set_experiment_info_(obj,val)
%SET_EXPERIMENT_INFO_ main setter for experiment_info property

if isempty(val)
    obj.experiment_info_ = Experiment();
elseif isa(val,'Experiment')
    obj.experiment_info_ = val;
else
    error('HORACE:sqw:invalid_argument',...
        'Experiment info can be only instance of Experiment class, actually it is %s',...
        class(val));
end
obj.main_header_.nfiles = obj.experiment_info_.n_runs;