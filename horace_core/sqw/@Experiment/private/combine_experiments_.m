function [exp,nspe] = combine_experiments_(exp_cellarray,allow_equal_headers,keep_runid)
%COMBINE_EXPEERIMENTS_
% Take cellarray of experiments (e.g., generated from each runfile build
% during gen_sqw generation)
% and combine then together into single Experiment info class
% Inputs:
% exp_cellarray -- cellarray of Experiment classes, related to
%                  different runs or combination of runs
% allow_equal_headers
%               -- if true, equal runs are allowed.
%                At present, we insist that the contributing spe data are distinct
%                in that:
%                - filename, efix, psi, omega, dpsi, gl, gs cannot all be
%                  equal for two spe data input. If allow_equal_headers is
%                  set to true, this check is disabled
%
% keep_runid    -- if true, the procedure keeps run_id-s
%                  defined for contributing experiments.
%                  if false, the run-ids are reset from 1 for
%                  first contributed run to n_runs for the last
%                  contributing run (nxspe file)

n_contrib = numel(exp_cellarray);
nspe = zeros(n_contrib,1);
for i=1:n_contrib
    nspe(i) = exp_cellarray{i}.n_runs;
end
n_tot = sum(nspe);

instr  = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER', ...
                                     'IX_inst');                         % previously cell(1,n_tot);
sampl  = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER', ...
                                     'IX_samp');                         % previously cell(1,n_tot);
%{
% temporary suppression of use of compressed detectors until #959/PR999 
% is merged here and in the for loop below
detectors = unique_references_container('GLOBAL_NAME_DETECTORS_CONTAINER', ...
                                        'IX_detector_array');
%}
% warning('stop here so you can check that instr and sampl should no longer be set as cells');
detectors = []; % default empty detectors until the unique_references_containers are activated.

instr{1}   = exp_cellarray{1}.instruments{1};
sampl{1}   = exp_cellarray{1}.samples{1};
expinfo    = repmat(IX_experiment(),1,n_tot);
expinfo(1) = exp_cellarray{1}.expdata(1);
if ~allow_equal_headers
    neq_hashes = cell(1,n_tot);
    neq_hashes{1} = expinfo(1).get_neq_hash();
end
if exp_cellarray{1}.n_runs == 1
    i_start = 2;
    j_start = 1;
else % despice headers in the first run are certainly satisfy
    % the conditions, the following Experiment-s may contain the same
    % IX_experiments, so hashes for the first Experiment have to be
    % recalculated
    i_start = 1;
    j_start = 2;
end
ic = 2;
for i=i_start:n_contrib
    for j=j_start:exp_cellarray{i}.n_runs
        instr{ic}  = exp_cellarray{i}.instruments{j};
        sampl{ic}  = exp_cellarray{i}.samples{j};
        expinfo(ic)= exp_cellarray{i}.expdata(j);
        if ~keep_runid
            expinfo(ic).run_id = ic;
        end
        % Check experiment consistency:
        % At present, we insist that the contributing spe data are distinct in that:
        %   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
        %   - emode, lattice parameters, u, v, sample must be the same for all spe data input
        if sampl{ic} ~= sampl{1} || expinfo(1).emode ~= expinfo(ic).emode
            error('HORACE:Experiment:runtime_error',[...
                'The emode and sample for all runs contributing to experiment have to be the same.\n',...
                'File N%d, contributed run %d differs from the first run '],i,j);
        end
        if allow_equal_headers
            ic = ic+1;
            continue;
        end
        neq_hashes{ic} = expinfo(ic).get_neq_hash();
        if ismember(neq_hashes{ic},neq_hashes(1:ic-1))
            error('HORACE:Experiment:runtime_error',[...
                'filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data inputs\n' ...
                'File: N%d, contributed run %d differs from the first run '],i,j);
        end

        ic = ic+1;
    end
end
% Here detectors==[] but will be a unique_references_container when the
% above code for it is activated.
exp = Experiment(detectors, instr, sampl,expinfo);
