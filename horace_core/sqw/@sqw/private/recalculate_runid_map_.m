function runid_map = recalculate_runid_map_(headers)
% recover runid-s from headers filenames
%
% Transitional function. 
% TODO:incorporate into new file format

n_runs = numel(headers);
runids = zeros(n_runs ,1);
for i=1:n_runs
    if iscell(headers)
        runids(i) = rundata.extract_id_from_filename(headers{i}.filename);
    else
        runids(i) = rundata.extract_id_from_filename(headers(i).filename);
    end
end
header_numbers = 1:n_runs;
if any(isnan(runids)) % this also had been done in gen_sqw;
    % rundata_write_to_sqw_ procedure in gen_sqw_files job.
    % It have setup update_runlabels to true, which aslo made
    % duplicated headers unique
    runids = header_numbers;
end
runid_map = containers.Map(runids,header_numbers);
