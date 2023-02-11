function sqw_type_struc = update_pixels_run_id(sqw_type_struc,unique_pix_id)
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
    pix_runid = unique(sqw_type_struc.data.pix.run_idx);
    pix_runid_known = sqw_type_struc.data.pix.page_size >= sqw_type_struc.data.pix.num_pixels;
else
    pix_runid = unique_pix_id;
    pix_runid_known = true;
end
headers = sqw_type_struc.header;
head_id = sqw_type_struc.runid_map.keys;
head_id = [head_id{:}];
if pix_runid_known  % all pixels are in memory or pix_runid are known and we
    % can properly analyse run-ids

    if ~all(ismember(pix_runid,head_id))  % old style pixel data, run_id-s
        % have been recalculated
        % use the fact that the headers were recalculated as subsequent numbers
        % going from 1 to n_headers
        head_id =1:numel(headers);        
        if  max(pix_runid)>numel(headers)
            warning('HORACE:old_file_format', ...
                ['\n*** Can not identify direct correspondence between pixel run-id(s) and experiment info run-id(s)\n', ...
                '*** Pixel run id(s): %s\n*** Header id(s): %s\n', ...
                '*** Assigning pixel run-is(s) to the first file headers'], ...
                disp2str(pix_runid),disp2str(head_id));

            keys =  ones(1,headers.n_runs)*realmax('single');
            n_unique_pix= numel(pix_runid);
            for i=1:n_unique_pix
                keys(i) = pix_runid(i);
            end

        else
            keys = head_id;
        end
        % reset run-ids and runid_map stored in current experiment info.        
        sqw_type_struc.runid_map = containers.Map(keys ,head_id);
        %
    end
    if numel(pix_runid)< numel(head_id)
        [headers,runid_map] = get_subobj(headers,head_id,pix_runid);
        sqw_type_struc.main_header.nfiles = numel(headers);
        sqw_type_struc.runid_map = runid_map;
        sqw_type_struc.header  = headers;
    end

else % not all pixels are loaded into memory or pre-calculated and run-id-s may be wrong
    %
    if ~any(ismember(pix_runid,head_id))  % old style pixel data, run_id-s
        % have been recalculated for pixels and our only hope is that
        % headers are in the order of run-id
        id=1:headers.n_runs;
        sqw_type_struc.runid_map = containers.Map(id,id);
    end
end


function [sub_headers,runid_map] = get_subobj(headers,header_id,runids_to_keep)
% Return bunch of headers, containing subset of runs requested
%
% Inputs:
% headers     - celarray of headers
% runid_map   - the header indexes (id-s);
% runids_to_keep
%             - array of runid-s to keep


ind_to_keep = ismember(header_id,runids_to_keep);
sub_headers   = headers(ind_to_keep);
runid_map     = containers.Map(runids_to_keep,1:numel(sub_headers));