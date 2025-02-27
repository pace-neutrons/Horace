function [efix_out,en_tr_out,en_tr_idx_minmax] = retrieve_en_ranges(efix_info,en_tr_info,udet_info,run_id,en_id)
%RETRIEVE_EN_RANGES Identify maximal enery transfer range, corresponding to
% each bunch of unique detectors. Return cellarray of possible enery transfers for each
% bunch of runs with unique detectors.
%
% Inputs:
% efix_info            -- compact_array of unique fixed energy values (arrays
%                         for indirect instrument)
% ent                  -- compact_array of unique energy transfer arrays
% udet_info            -- compact array of detector arrays contributed into
%                         experiment
%
% ien                 -- array of size run_id, containing numbers of en cells
%                        which should be included in reslut.
% run_id              -- array of runidices contributing into
%
% Returns:
% efix_out            -- compact_array of energy transfers, contributed
%                        into
%                        each unique instrument
% en_tr_out          -- cellarray containing arrays of energy indices,
%                        each array contributing to a unique run.
% en_tr_idx_minmax   -- cellarray of minmax values of energy transfer
%                        indices contributed into runs

n_unique_instruments = udet_info.n_unique;

en_tr_out = cell(1,n_unique_instruments);
efix_out  = cell(1,n_unique_instruments);
en_tr_idx_minmax = cell(1,n_unique_instruments);

%
% select only energy transfers which corresponds to indices specified as
% input

% Reorder input arrays according to the runs performed at for every unique
% instrument
for i=1:n_unique_instruments
    inst_runs     = udet_info.nunq_idx{i};
    efix_out{i}   = efix_info.get_subobj(inst_runs);
    en_tr         = en_tr_info.get_subobj(inst_runs);    
    % found energy indices, which may contribute into this run
    contributed_runs = ismember(run_id,en_tr.nonunq_idx()); 
    idx_ent_present   = unique(en_id(contributed_runs));
    min_max_etr_idx = cell(1,en_tr.n_unique);
    for j = 1:en_tr.n_unique
        ent_i        = en_tr_info.uniq_val{j};        % unique energy transfer values
        idx_valid    = idx_ent_present<=numel(ent_i); % en transfer indices may contribute to this unique values        
        idx_ent_j    = idx_ent_present(idx_valid);    % indices which may contribute into run
        min_max_etr_idx{j} = min_max(idx_ent_j(:)');
        en_tr_info.uniq_val{j} = ent_i(idx_ent_j);
    end
    en_tr_idx_minmax{i} = min_max_etr_idx;
    en_tr_out{i} = en_tr;
end

