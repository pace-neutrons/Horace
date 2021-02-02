function run_files = update_duplicated_rf_id(run_files)
% Processes the list of runfiles and if some files have duplicated
% run-id-s, modify these id-s to be unique.

run_ids_all = cellfun(@get_run_id,run_files,'UniformOutput',true);
[run_ids_sorted,sid]= sort(run_ids_all);

i_udef1 = find(isnan(run_ids_sorted),1);
if isempty(i_udef1)
    i_udef1 = numel(run_ids_sorted) + 1;
end
n_undef = numel(run_ids_sorted)-i_udef1+1; % number of empty places 
%                                         in runfiles sequence
% maximal index is maxiamal present index + number of empty indexes
% (assuming empty places are eventually filled with files, 
%  containing subsequent numbers) 
max_id = max(run_ids_sorted)+n_undef ;
if isnan(max_id)
    return;
end
max_id0 = max_id;

part_1 = run_ids_sorted(1:end-1);
part_2 = run_ids_sorted(2:end);
    function new_ind = mod_id(ind1,ind2)
        if isnan(ind2)
            new_ind = ind2;
            return;
        end
        
        if ind1 == ind2
            max_id = max_id+1;
            new_ind = max_id;
        else
            new_ind = ind2;
        end
    end
id_mod = arrayfun(@mod_id,part_1,part_2,'UniformOutput',true);
if max_id == max_id0
    return;
end

run_ids_sorted = [run_ids_sorted(1),id_mod];

run_ids_all(sid) = run_ids_sorted(:);

n_runs = numel(run_files);
for i=1:n_runs
    rf = run_files{i};
    if isempty(rf)
        continue
    end
    run_files{i}.run_id = run_ids_all(i);
end
end


function id = get_run_id(run)
if isempty(run)
    id = NaN;
else
    id = run.run_id;
end
end