function subexper = get_subobj_(obj,runids_to_keep,runid_to_keep_are_indexes)
% Return Experiment object, containing subset of experiments,
% requested by the method.
%
% Inputs:
% obj       -- initialized instance of the Experiment, containing
%              information about experiments(runs) contributed into sqw
%              object.
% runids_to_keep
%            -- run_id-s,which identify particular experiments(runs)
%              to include the  experiments(runs) contributing
%              into the final subset  of experiments.
% runid_to_keep_are_indexes
%          --  if true, tread input runids_to_keep as
%              direct indexes of the experiments to keep rather
%              then run_id(s). Mainly used for debugging.
%
% Returns:
% subexper  -- the Experiment object, containing information
%              about experiments(runs) defined by
%              runids_to_keep.

if runid_to_keep_are_indexes
    head_num = runids_to_keep;
else
    runid_map = obj.runid_map;
    keys = runid_map.keys;
    keys = [keys{:}];
    if ~any(ismember(runids_to_keep,keys)) % Old files. If the pixel run
        % indexes have been renumbered from 1 to n_headers but headers do not contain
        % correct runids, despite these ID-s may be extracted from
        % filenames. Assume that indexes correspond to header numbers. (we
        % have no other choice then assume this and if this is incorrect,
        % we can not recover correct correspondence between run information
        % and pixels id).
        head_num = runids_to_keep;
        if min(head_num)<1 || max(head_num)>obj.n_runs
            error('HORACE:Experiment:invalid_argument',...
                'requested run_indexes to extract lie outside the range of existing run indexes')
        end
        exp = obj.expdata;
        for i=1:obj.n_runs
            exp(i).run_id = i;
        end
        obj.expdata = exp; % old runid_map gets recalculated on assignment
        obj.runid_recalculated_ = true;
    else
        head_num = arrayfun(@(id)runid_map(id),runids_to_keep);
    end
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
info{2} = obj.instruments_.get_subset(head_num);
info{3} = obj.samples_(head_num);
info{4} = obj.expdata_(head_num);

subexper  = Experiment(info{:});
if obj.runid_recalculated_
    subexper.runid_recalculated_ = true;
end
