function [obj,this_runid_map] = combine_(obj,exper_cellarray,keep_runid,this_runid_map)
% COMBINE_ : properly combines input IX_experiment array with elements
% contained in exper_cellarray, ignoring possible duplicates
% Inputs:
% obj             -- sinle instance or array of IX_experiment objects
% exper_cellarray -- exper_cellarray cellarray containing
%                     IX_experiments arrays
% keep_runid      -- boolean, which includes true if run_id-s
%                    stored in IX_experiment data should be
%                    kept or final obj run_id should be
%                    recalculated.
% WARNING:        -- run_id(s) modified if keep_runid == false
%                    must be synchronized with run_id(s) stored
%                    in pixels, which means that keep_runid ==
%                    false could be used mainly in tests
% Optional:
% this_runid_map  -- the map containing information about
%                    run_id(s) stored in the object as keys
%                    and pointing to the nuber of element in obj
%                    as value.
%
% Returns:
% obj             -- resulting array, containing unique
%                    instances of IX_experiment classes with
%                    all non-unique IX_experiments excluded.
% this_runid_map --  the map which connects run_id(s) of data, stored in
%                    the obj with the positions of the data objects in the
%                    object array.

if isempty(exper_cellarray)
    if ~keep_runid
        obj = recalc_runid(obj);
        ids = 1:numel(obj);
        this_runid_map = contains.Map(ids,ids);
    end
    return;
end
if nargin<4
    this_runid_map = obj.get_runid_map();
end

if isa(exper_cellarray{1},'Experiment')
    res_data = cellfun(@(x)[{x.expdata},{x.runid_map}],exper_cellarray);
    exper_cellarray= res_data(1,:);
    runid_map      = res_data(2,:);
else
    runid_map      = cellfun(@(x)(x.get_runid_map),exper_cellarray,'UniformOutput','false');
end
% cellarray of runs stored in object. done this way to allow fast
% expansion array expansion
base_runs     = num2cell(obj);
n_unique_runs = numel(base_runs);

n_exper_to_add = numel(exper_cellarray);
for i=1:n_exper_to_add
    % retrieve arrays and maps for additional experiment to add
    add_map  = runid_map{i};
    add_exper= exper_cellarray{i};
    keys     = add_map.keys;
    n_runs   = add_exper.n_runs;

    for j=1:n_runs
        % extract particular IX_info to check for addition
        addrun_num    = addmap(keys{j});
        add_IX_exper  = add_exper(addrun_num);

        if this_runid_map.isKey(keys{j}) % run_id is present in obj
            % check if runs with the same run_id contain the same
            % IX_experiments
            this_run_pos  = this_runid_map(keys{j});
            this_IX_exper = base_runs{this_run_pos};
            % TODO: use hashable
            [this_hash,this_IX_exper,is_new] = this_IX_exper.get_neq_hash();
            if is_new
                % store it back not to recaclulate hash again in a future
                base_runs{this_run_pos} = this_IX_exper;
            end
            add_hash = add_IX_exper.get_neq_hash();
            if this_hash ~= add_hash
                error('HORACE:Experiment:runtime_error',[...
                    'Can not combine such runs.\n' ...
                    'filename, efix, psi, omega, dpsi, gl, gs cannot be different for two runs with same run_id\n' ...
                    'File: N%d, contributed run %d is the same as the RunN:%, Run_id:%d'], ...
                    i,j,this_runid_map.isKey(keys{j}),keys{j});
            end
            continue;
        end
        if obj(1).emode ~= add_IX_exper.emode
            error('HORACE:IX_experiment:not_implemented',...
                'you can not currently combine together runs for direct and indirect instruments')
        end
        % store new unique run to add to existing ones
        n_unique_runs = n_unique_runs+1;
        this_runid_map(keys{j}) = n_unique_runs;
        base_runs(n_unique_runs) = add_IX_exper;
    end
end

if numel(obj) ~= n_unique_runs
    obj = cell2mat(base_runs);
end
if ~keep_runid
    obj = recalc_runid(obj);
    ids = 1:numel(obj);
    this_runid_map = contains.Map(ids,ids);
end
end


function [obj,id_map] = recalc_runid(obj,id_map)
for i=1:numel(obj)
    obj(i).run_id = i;
end
end

