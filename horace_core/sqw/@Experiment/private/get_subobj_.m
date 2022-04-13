function [subexper,runid_map_out] = get_subobj_(obj,indexes,runid_map, ...
    modify_runid)
% return Experiment object, containing subset of experiments,
% requested by the method.
%
% Input:
% indexes   -- the array of indexes, which identify particular
%              experiments to include asof the runs to contribute
%              into the final subset of experiment
% runid_map -- if not empty, the map run_id->index, containing
%              information about run_id to select as the final
%              experiment info. If it is provided, first
%              argument is treated as runid-s, which are the
%              keys of the runid_map rather then direct indexes
%              of the map.
% Returns:
% subexper  -- the Experiment object, containing information
%              about runs defined by indexes and optionally,
%              runid_map.
if ~isempty(runid_map)
    keys = runid_map.keys;
    keys = [keys{:}];
    if ~any(ismember(indexes,keys)) % Old files. The pixel run indexes have
        % been renumbered from 1 to n_headers but headers do not contain
        % correct runids, despite these ID-s may be extracted from
        % filenames. Assume that indexes correspond to header numbers. (we
        % have no other chouce then assume this). The run-ids will be
        % modified and renumbered after using this procedure
        head_num = indexes;
        modify_runid = true;
    else
        head_num = arrayfun(@(id)runid_map(id),indexes);
    end
else
    head_num = indexes;
end
info = cell(4,1);
if numel(obj.detector_arrays_) == obj.n_runs
    info{1} = obj.detector_arrays_(head_num);
else
    if isempty(obj.detector_arrays_)
        info{1} = [];
    else
        info{1} = obj.detector_arrays_(1);
    end
end
info{2} = obj.instruments_(head_num);
info{3} = obj.samples_(head_num);
info{4} = obj.expdata_(head_num);

subexper  = Experiment(info{:});

id = 1:numel(indexes);
if isempty(runid_map)
    runid_map_out = containers.Map(id,id);
    indexes = id;
else
    runid_map_out = containers.Map(indexes,id);
end
if modify_runid
    exper = subexper.expdata;
    for i = 1:numel(indexes)
        exper(i).run_id = indexes(i);
    end
    subexper.expdata = exper;
end