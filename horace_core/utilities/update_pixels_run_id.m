function sqw_type = update_pixels_run_id(sqw_type,unique_pix_id)
% The routine is used in loading old binary sqw data where run-id-s stored
% in headers may or may not be consistent with the run-id(s) stored in
% pixels.
%
% The routine tries to analyse pixels run_id(s) and check if the id-s are
% consistent with the run-id numbers, defined in headers. If
% inconsistencies are found, the routine updates runid map and drops the
% headers, not contributing into pixels any more.
%
% run_id map in any form, so it is often tried to be restored from filename.
% here we try to verify, if this restoration is correct if we can do that
% without critical drop in performance.
if ~exist('unique_pix_id','var')
    pix_runid = unique(sqw_type.pix.run_idx);
    pix_runid_known = sqw_type.pix.num_pages == 1;
else
    pix_runid = unique_pix_id;
    pix_runid_known = true;
end
exp_info = sqw_type.experiment_info;
file_id = exp_info.runid_map.keys;
file_id = [file_id{:}];
if pix_runid_known  % all pixels are in memory or pix_runid are known and we
    % can properly analyse run-ids

    if ~all(ismember(pix_runid,file_id))  % old style pixel data, run_id-s
        % have been recalculated
        % use the fact that the headers were recalculated as subsequent numbers
        % going from 1 to n_headers
        if  max(pix_runid)>exp_info.n_runs
            warning('HORACE:old_file_format', ...
                ['\n*** Can not identify direct correspondence between pixel run-id(s) and experiment info run-id(s)\n', ...
                '*** Pixel run id(s): %s\n*** Header id(s): %s\n', ...
                '*** Assigning pixel run-is(s) to the first file headers'], ...
                disp2str(pix_runid),disp2str(file_id));

            id =  ones(1,exp_info.n_runs)*realmax('single');
            n_unique_pix= numel(pix_runid);
            for i=1:n_unique_pix
                id(i) = pix_runid(i);
            end

        else
            id=1:exp_info.n_runs;
        end
        % reset run-ids and runid_map stored in current experiment info.
        exp_info.runid_map = id;
        %
    end
    if numel(pix_runid)< numel(file_id)
        exp_info = exp_info.get_subobj(pix_runid);
        sqw_type.main_header.nfiles = exp_info.n_runs;
    end

else % not all pixels are loaded into memory or pre-calculated and run-id-s may be wrong
    %
    if ~any(ismember(pix_runid,file_id))  % old style pixel data, run_id-s
        % have been recalculated for pixels and our only hope is that
        % headers are in the order of run-id
        id=1:exp_info.n_runs;
        exp_info.runid_map = id;
    end
end
sqw_type.experiment_info = exp_info;
sqw_type.main_header.nfiles = exp_info.n_runs;
