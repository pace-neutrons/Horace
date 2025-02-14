function [en_out,pix_idx] = merge_en_ranges(en,unique_en_run_idx,ien,run_id,unique_inst_run_idx)
%MERGE_EN_RANGES Identify maximal enery transfer range, corresponding to
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
%

n_unique_instruments = numel(unique_inst_run_idx);
n_unique_en_transf = numel(unique_en_run_idx);
en_out = cell(1,n_unique_instruments);
pix_idx = cell(1,n_unique_instruments);

all_idx = 1:numel(ien);
for i=1:n_unique_instruments
    for j=1:n_unique_en_transf
        is_contribufing = ismember(unique_en_run_idx{j},unique_inst_run_idx{i});
        if any(is_contribufing)
            ien_contributing  = ien(is_contribufing);
            loc_pix_idx       = all_idx(is_contribufing);
            en_out{i}  = [en_out{i},en{i}(ien_contributing)];
            pix_idx{i} = [pix_idx{i},loc_pix_idx];
        end
    end
end
