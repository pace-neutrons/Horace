function [efix_out,en_out,en_idx] = retrieve_en_ranges(efix_info,en_tr_info,udet_info,run_id,en_id)
%RETRIEVE_EN_RANGES Identify maximal enery transfer range, corresponding to
% each bunch of unique detectors. Return cellarray of possible enery transfers for each
% bunch of runs with unique detectors.
%
% Inputs:
% all_efix             -- cellarray of unique fixed energy values (arrays
%                         for indirect instrument)
% nunq_efix_run_idx    -- cellarray of non_unique indices which describe 
%                         
% ent                  -- cellarray of unique energy transfer arrays
% nunique_ent_run_idx -- cellarray (size of en) of run indices with
%                        each cell contains array of run indices, contribuing
%                        into correspondent en cell
% ien                 -- array of size run_id, containing numbers of en cells
%                        which should be included in reslut. non-unique
%                        values are there
% irun                -- array of runidices contributing into
% unique_inst_run_idx -- cellarray of the run_ids belonging to each unuque
%                        instrument
% Returns:
% en_out              -- cellarray of arrays of energy indices, contributing into
%                        each unique instrument
% en_idx              -- cellarray containing arrays of energy indices,
%                        each array contributing to a unique run.

n_unique_instruments = udet_info.n_unique;

en_out = cell(1,n_unique_instruments);
en_idx = cell(1,n_unique_instruments);
efix_out=cell(1,n_unique_instruments);
efix_idx=cell(1,n_unique_instruments);
%
% select only energy transfers which corresponds to indices specified as
% input
enidx_present = unique(en_id);
for i = 1:numel(all_ent)
    ent_i        = all_ent{i};
    ent_possible = enidx_present<=numel(ent_i);
    all_ent{i} = ent_i(enidx_present(ent_possible));
end
% Reorder input arrays according to unique run idx
for i=1:n_unique_instruments
    run_idx_selected = run_id(run_id==unique_inst_run_idx{i});

    [en_out{i},en_idx{i}]     = get_unique_val_and_its_idx(all_ent,nunq_ent_run_idx,run_idx_selected);
    [efix_out{i},efix_idx{i}] = get_unique_val_and_its_idx(all_efix,nunq_efix_run_idx,run_idx_selected);
end

function [unique_value,idx] = get_unique_val_and_its_idx(uni_val,uni_idx,new_idx_set)
% reorder array of values presented in the form:
% [unique_values_cellarray,non_unique_values_indices_cellarray]
% e.g.
% array of
% [val1,val1,val2,val2,val1,val3,val3,val3] is presented in the form:
% {val1,val2,val3},{[1,2,5],[3,5],[6,7,8]}
%
% according to other set of input indices.
%
% Return result in the same form as input.
uni_idx     = [uni_idx{:}];
selected    = ismember(uni_idx,new_idx_set);
idx         = uni_idx(selected);
uni_idx     = unique(idx);
unique_value= uni_val(uni_idx);