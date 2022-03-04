function runid_map = recalculate_runid_map_(headers)
% recover runid-s from headers filenames
%
% Transitional function. 
% TODO:incorporate into new file format
%
n_runs = numel(headers);
runids = zeros(n_runs,1);
for i=1:n_runs
    if iscell(headers)
        runids(i) = rundata.extract_id_from_filename(headers{i}.filename);
    else
        runids(i) = rundata.extract_id_from_filename(headers(i).filename);
    end
end
header_numbers = 1:n_runs;
if any(isnan(runids)) % this also had been done in gen_sqw;
    % rundata_write_to_sqw_ procedure of gen_sqw_files_job.
    % It have setup update_runlabels to true, which also made
    % duplicated headers unique
    runids = header_numbers;
end
if isempty(runids)
    runid_map = containers.Map();    
else
    runid_map = containers.Map(runids,header_numbers);
end
