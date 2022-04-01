function subexper = get_subobj_(obj,indexes,runid_map)
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
    indexes = arrayfun(@(id)runid_map(id),indexes);    
end
info = cell(4,1);
if numel(obj.detector_arrays_) == obj.n_runs
    info{1} = obj.detector_arrays_(indexes);    
else
    info{1} = obj.detector_arrays_(1);        
end
info{2} = obj.instruments_(indexes);
info{3} = obj.samples_(indexes);
info{4} = obj.expdata_(indexes);

subexper  = Experiment(info{:});