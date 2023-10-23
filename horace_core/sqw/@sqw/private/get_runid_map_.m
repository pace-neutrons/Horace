function map = get_runid_map_(obj)
%GET_RUNID_MAP_ main getter for runid map

if isempty(obj.experiment_info_)
    map = [];
else
    map = obj.experiment_info_.runid_map;
end
