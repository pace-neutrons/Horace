function runid_map = recalculate_runid_map_(headers)
% recover runid-s from headers filenames
%
% Transitional function.
% TODO:incorporate into new file format
%
n_runs = numel(headers);

if iscell(headers)
    runids = cellfun(@(hd)rundata.extract_id_from_filename(hd.filename),headers);
else
    runids = arrayfun(@(hd)rundata.extract_id_from_filename(hd.filename),headers);
end

header_numbers = 1:n_runs;
un_id = unique(runids);
if any(isnan(runids)) || numel(un_id)< n_runs % this also had been done in gen_sqw;
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
