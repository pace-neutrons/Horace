function sqw_type_struc = update_pixels_run_id(sqw_type_struc)
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
pix_runid = unique(sqw_type_struc.pix.run_idx);
exp_info = sqw_type_struc.experiment_info;
file_id = exp_info.runid_map.keys;
file_id = [file_id{:}];
if sqw_type_struc.pix.n_pages == 1 % all pixels are in memory and we
    % can properly analyse run-ids

    if ~all(ismember(pix_runid,file_id))  % old style pixel data, run_id-s
        % have been recalculated
        % use the fact that the headers were recalculated as subsequent numbers
        % going from 1 to n_headers
        id=1:exp_info.n_runs;
        if min(pix_runid)< 1 || max(pix_runid)>exp_info.n_runs
            error('HORACE:sqw_binfile_common:invalid_argument', ...
                'pixels runid-s were recalculated but lie outside of runid-s, defined for headers. Contact developers to deal with the issue')
        end
        % reset run-ids and runid_map stored in current experiment info.
        exp_info.runid_map = id;
        %
        exp_info = exp_info.get_subobj(pix_runid);
        sqw_type_struc.main_header.nfiles = exp_info.n_runs;
        %
    end

else % not all pixels are loaded into memory
    if ~any(ismember(pix_runid,file_id))  % old style pixel data, run_id-s
        % have been recalculated
        id=1:exp_info.n_runs;
        exp_info.runid_map = id;
    end
end
sqw_type_struc.experiment_info = exp_info;
