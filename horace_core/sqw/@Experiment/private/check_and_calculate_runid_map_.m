function  obj = check_and_calculate_runid_map_(obj,force_runid_recalculation)
% Builds runid_map and sets  runid_map_ and runid_recalculated_
% properties using contents of expdata property.
%
% Inputs:
% force_runid_recalculation -- If true, recalculate runid regardless of
%                              consistency of runid stored in expdata.
%

if numel(obj.expdata_) == 0
    obj.runid_map_ = [];
    obj.runid_recalculated_ = false;
    return;
end

runids = obj.expdata.get_run_ids();
nruns = numel(runids);
if ~force_runid_recalculation
    unique_runid = unique(runids);
end

id = 1:nruns;
if force_runid_recalculation || numel(unique_runid) ~= obj.n_runs || any(isnan(unique_runid))
    obj.runid_recalculated_ = true;
    runids = id;
    exp = obj.expdata_;
    for i=1:nruns
        exp(i).run_id = runids(i);
    end
    obj.expdata_ = exp;
else
    obj.runid_recalculated_ = false;
end
obj.runid_map_ = containers.Map(runids,id);
