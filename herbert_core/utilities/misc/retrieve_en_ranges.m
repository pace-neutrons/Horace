function [en_out,en_idx] = retrieve_en_ranges(en,unique_en_run_idx,en_id,run_id,unique_inst_run_idx)
%RETRIEVE_EN_RANGES Identify maximal enery transfer range, corresponding to
% each bunch of unique detectors. Return cellarray of possible enery transfers for each
% bunch of runs with unique detectors.
%
% Inputs:
% en                  -- cellarray of unique energy transfer ranges
% unique_en_run_idx   -- cellarray (size of en) of run indices with
%                        each cell contains array of run indices, contribuing
%                        into correspondent en cell
% ien                 -- array of size irun, containing numbers of en cells
%                        which should be included in reslut
% irun                -- array of runidices contributing into
% unique_inst_run_idx -- cellarray of the run_ids belonging to each unuque
%                        instrument
% Returns:
% en_out              -- cellarray of arrays of energy indices, contributing into
%                        each unique instrument
% en_idx              -- cellarray containing arrays of energy indices,
%                        each array contributing to a unique run.

n_unique_instruments = numel(unique_inst_run_idx);
n_unique_en_transf   = numel(unique_en_run_idx);
en_out = cell(1,n_unique_instruments);
en_idx = cell(1,n_unique_instruments);

for i=1:n_unique_instruments
    for j=1:n_unique_en_transf
        is_contribufing = ismember(unique_en_run_idx{j},unique_inst_run_idx{i});
        if any(is_contribufing)
            run_id_contr      = ismember(run_id,unique_inst_run_idx{i}(is_contribufing));
            ien_contributing  = en_id(run_id_contr);
            ien_unique        = unique(ien_contributing);
            
            en_out{i} = [en_out{i},en{i}(ien_unique)];
            en_idx{i} = [en_idx{i},ien_unique];
        end
    end
end
