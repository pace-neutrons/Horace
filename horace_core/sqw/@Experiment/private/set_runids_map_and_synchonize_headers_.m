function  obj = set_runids_map_and_synchonize_headers_(obj,runid_map_keys)
% set runid to the headers(IX_experiments) and synchronize these
% runid-s with runid map if this map exist. Build runid map if it does not
% exist
%
% Inputs:
% runid_map_keys -- run_ids of the runs to use as the keys of the runid map
%

if obj.n_runs ~= numel(runid_map_keys)
    error('HORACE:Experiment:invalid_arguent', ...
        'number of elements in runid map (%d) is no equal to number of experiments stored in Expriment (%d)', ...
        numel(runid_map_keys),obj.n_runs)
end
exp = obj.expdata;

if ~isempty(obj.runid_map_)
    indxes = obj.runid_map_.values;
    indxes  = [indxes{:}];
else
    indxes = 1:obj.n_runs;
    obj.runid_map_ = containers.Map(runid_map_keys,indxes);
end
for i=1:numel(indxes)
    exp(indxes(i)).run_id = runid_map_keys(i);
end
obj.expdata_ = exp;
obj.runid_map_ = containers.Map(runid_map_keys,indxes);

