function obj = build_runid_map_(obj)
% Build runid map from the run_id-s in IX_experiment headers
% and set this map as internal map for the object
%
run_ids = obj.expdata.get_run_ids();
nruns = numel(run_ids);

unique_runid = unique(run_ids);

id = 1:nruns;
if numel(unique_runid) ~= obj.n_runs || any(isnan(unique_runid))
    run_ids = id;
    exp = obj.expdata_;
    for i=1:nruns
        exp(i).run_id = run_ids(i); % this is a very convoluted way of saying 
                                    % exp(i).run_id = i; but run_ids and id
                                    % are needed to form the map below.
    end
    obj.expdata_ = exp;
    obj.runid_recalculated_ = true;
else
    obj.runid_recalculated_ = false;    
end
obj.runid_map_ = containers.Map(run_ids,id);

