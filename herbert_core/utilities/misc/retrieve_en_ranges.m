function [efix_out,en_tr_out,en_tr_idx] = retrieve_en_ranges(efix_info,en_tr_info,udet_info,run_id,en_id)
%RETRIEVE_EN_RANGES Identify maximal enery transfer range, corresponding to
% each bunch of unique detectors. Return cellarray of possible enery transfers for each
% bunch of runs with unique detectors.
%
% Inputs:
% efix_info            -- compact_array of unique fixed energy values (arrays
%                         for indirect instrument)
% en_tr_info           -- compact_array of unique energy transfer arrays
% udet_info            -- compact array of detector arrays contributed into
%                         experiment
%
% run_id              -- array of runidices contributing into result
% ien                 -- array of size run_id, containing numbers of en cells
%                        which should be included in reslut.

%
% Returns:
% efix_out            -- cellarray of compact_arrays of incident energies
%                        (analyzed energies for indorect),
%                        contributed into each unique instrument.
% en_tr_out           -- cellarray  of compact_array of energy transfers,
%                        each array contributing to a unique run.
% en_tr_idx        --    cellarray of arrys of nergy transfer indices
%                        contributed into runs

n_unique_instruments = udet_info.n_unique;

en_tr_out = cell(1,n_unique_instruments);
efix_out  = cell(1,n_unique_instruments);
en_tr_idx = cell(1,n_unique_instruments);

%
% select only energy transfers which corresponds to indices specified as
% input

% Reorder input arrays according to the runs performed at for every unique
% instrument
for i=1:n_unique_instruments
    inst_runs     = udet_info.nonunq_idx{i};
    efix_out{i}   = efix_info.get_subobj(inst_runs);
    en_tr         = en_tr_info.get_subobj(inst_runs);
    % found energy indices, which may contribute into run with this
    % insrument
    contributed_runs = ismember(run_id,en_tr.nonunq_idx{i});
    idx_ent_present  = unique(en_id(contributed_runs));
    etr_idx          = cell(1,en_tr.n_unique);
    for j = 1:en_tr.n_unique
        ent_i        = en_tr.unique_val{j};           % unique energy transfer values
        idx_valid    = idx_ent_present<=numel(ent_i); % en transfer indices may contribute to this unique values
        idx_ent_j    = idx_ent_present(idx_valid);    % indices which may contribute into run
        etr_idx{j}   = idx_ent_j(:)';
        en_tr.unique_val{j}  = ent_i(idx_ent_j);
    end
    en_tr_idx{i} = etr_idx;
    en_tr_out{i} = en_tr;
end
