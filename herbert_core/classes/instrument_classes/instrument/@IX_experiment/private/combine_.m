function [obj,file_id_array,skipped_inputs,this_runid_map] = combine_(obj,exper_cellarray,allow_equal_headers,keep_runid,varargin)
% COMBINE_ : properly combines input IX_experiment array with elements
% contained in exper_cellarray, identifying possible duplicates
% and either ignoring them, or throwing error depending on the input
% parameters.
%
% Inputs:
% obj             -- single instance or array of IX_experiment objects
% exper_cellarray -- cellarray containing IX_experiments arrays
%                    or Experiment classes to combine their IX_experiments
%                    into obj.
% allow_eq_headers-- if true, headers with the same runid and
%                    same values are allowed and accounted for
%                    in combine operations. If false, routine
%                    throws HORACE:IX_experiment:invalid_argument
%                    if the IX_experiment have the same run_id
%                    and the same values.
% keep_runid      -- true if run_id-s stored in input IX_experiment-s 
%                    should be kept or false if final obj run_id should be
%                    recalculated starting from 1 to number of kept runs.
% WARNING:        -- run_id(s) modified if keep_runid == false
%                    must be synchronized with run_id(s) stored
%                    in pixels, which means that keep_runid ==
%                    false could be used mainly in tests or in gen_sqw
%                    operations
% Optional:
% this_runid_map  -- the map containing information about
%                    run_id(s) stored in the object as keys
%                    and pointing to the number of element in obj array
%                    as value.
%
% Returns:
% obj             -- resulting array, containing unique
%                    instances of IX_experiment classes with
%                    all non-unique IX_experiments excluded.
% skipped_inputs  -- cellarray (with size of input exper_cellarray) of
%                    logical arrays, (each of size of corresponding
%                    exper_cellarray element)containing true where input
%                    object was dropped from output obj and false
%                    where it has been kept.
% file_id_array   -- array contains run_ids for each input
%                    IX_experiment value present in exper_cellarray.
%                    Where input IX_experiments with equal run_id-s
%                    and values are rejected, corresponding
%                    elements of this array contain the
%                    values of rejected run_id-s. These values will be used
%                    in calculations of pixels run_id for each contributing
%                    file.
% this_runid_map --  the map which connects run_id(s) of data, stored in
%                    the obj with the positions of the data objects in the
%                    object array.
if nargin<5
    this_runid_map = obj.get_runid_map();
else
    this_runid_map = varargin{1};
end
if isempty(exper_cellarray)
    file_id_array = arrayfun(@(x)x.run_id,obj);
    if ~keep_runid
        [obj,this_runid_map,file_id_array] = recalc_runid(obj,this_runid_map,file_id_array);
    end
    obj = arrayfun(@(x)build_hash(x),obj);
    skipped_inputs = {};
    return;
end

if isa(exper_cellarray{1},'Experiment') % extract IX_experiments to combine
    % them with input object.
    exper_cellarray = cellfun(@(x)(x.expdata),exper_cellarray,'UniformOutput',false);
end
n_existing_runs = numel(obj);
% Caclulate number of runs defined by all input IX_experiment data
n_runs = cellfun(@(x)numel(x),exper_cellarray);
n_runs = sum(n_runs)+n_existing_runs;
% Create file_id list for all input headers regardless they are included or
% in final result or not.
file_id_array = zeros(1,n_runs);
id_now = arrayfun(@(x)x.run_id,obj);
file_id_array(1:n_existing_runs) = id_now;

% allocate space for all input headers (final array will be shrinked if not
% all included in the result)
base_runs     = cell(1,n_runs);
obj_cell = arrayfun(@(x)build_hash(x),obj,'UniformOutput',false);
base_runs(1:n_existing_runs) = obj_cell;


n_exper_to_add = numel(exper_cellarray);
skipped_inputs = cell(1,n_exper_to_add);
ic = n_existing_runs;
for i=1:n_exper_to_add
    % retrieve arrays for additional IX_experiment-s to add to result
    add_exper= exper_cellarray{i};
    n_runs   = numel(add_exper);
    skipped_input = false(1,n_runs);
    for j=1:n_runs
        ic = ic+1;
        % extract particular IX_experiments to check for addition
        add_IX_exper      = add_exper(j);
        % hash will be used either forever in a future, or in comparison below.
        add_IX_exper      = add_IX_exper.build_hash();        
        run_id            = add_IX_exper.run_id;
        file_id_array(ic) = run_id; % this is run_id for current IX_experiment

        if this_runid_map.isKey(run_id) % run_id is already added to combine.
            % check if runs with the same run_id contain the same
            % IX_experiments
            present_run_pos  = this_runid_map(run_id);
            present_IX_exper = base_runs{present_run_pos};

            [present_IX_exper,~,is_new] = present_IX_exper.build_hash();
            if is_new
                % store it back not to recaclulate hash again in a future
                base_runs{present_run_pos} = present_IX_exper;
            end

            if present_IX_exper==add_IX_exper
                if ~allow_equal_headers
                    error('HORACE:IX_experiment:invalid_argument',[...
                        'Can not combine such runs.\n' ...
                        'filename, efix, psi, omega, dpsi, gl, gs cannot be the same for two runs with the same run_id\n' ...
                        'File: N%d, contributed run: %d, filename %s is the same as the already found RunN:%d, Run_id:%d'], ...
                        i,j,add_IX_exper.filename, present_run_pos,run_id);
                end
            else
                error('HORACE:IX_experiment:invalid_argument',[...
                    'Two IX_experiments with the same run_id contain different information:.\n' ...
                    'filename, efix, psi, omega, dpsi, gl, gs cannot be the same for two runs with the same run_id\n' ...
                    'File: N%d, contributed run: %d, filename %s is the same as the already found RunN:%d, Run_id:%d'], ...
                    i,j,add_IX_exper.filename, present_run_pos,run_id);
            end
            skipped_input(j)= true;
            continue;
        end
        if obj(1).emode ~= add_IX_exper.emode
            error('HORACE:IX_experiment:not_implemented',...
                'you can not currently combine together runs for direct and indirect instruments')
        end
        % store new unique run to add to existing ones
        n_existing_runs           = n_existing_runs+1;
        this_runid_map(run_id)    = n_existing_runs;

        base_runs{n_existing_runs}= add_IX_exper;
    end
    skipped_inputs{i} = skipped_input;
end

if numel(obj) ~= n_existing_runs
    obj = [base_runs{:}];
end
if ~keep_runid
    [obj,this_runid_map,file_id_array] = recalc_runid(obj,this_runid_map,file_id_array);
end
end


function [obj,id_map,id_array] = recalc_runid(obj,id_map,file_id_array)
% recacluae run_id changing it from 1 to number of runs. Replace all
% existing run_ids with numbers corresponding to number of objects in obj
% array
% Inputs:
% obj      -- array of IX_experiment elements
% id_map   -- map which relates IX_experiment.run_id with number of
%             IX_experiment object in obj array
% file_id_array
%          -- array of run_id-s, used by
% Returns:
% obj      -- IX_experiment array containing modified runid-s
% id_map   -- map of id->object number
%id_array  -- arrays of run_id-s modified so that each old_run_id is
%             replaced by new run_id
%

id_array = zeros(1,numel(file_id_array));
for i=1:numel(file_id_array)
    id_array(i) = id_map(file_id_array(i));
end
%
ids = 1:numel(obj);
id_map = containers.Map(ids,ids);

for i=1:numel(obj)
    obj(i).run_id = i;
end
end

