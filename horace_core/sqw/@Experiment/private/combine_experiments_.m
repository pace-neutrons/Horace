function [obj,nspe] = combine_experiments_(obj,exp_cellarray,allow_equal_headers,keep_runid)
%COMBINE_EXPEERIMENTS_
% Take cellarray of experiments (e.g., generated from each runfile build
% during gen_sqw generation)
% and combine then together into single Experiment info class
% Inputs:
% obj           -- first experiment to add other experinents to.
% exp_cellarray -- additional Experiment class or cellarray of Experiment
%                  classes, related to different runs or combination of runs
%
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
% Returns:
% obj           -- Experiment class containing combined input
%                  experiments
% nspe          -- number of unique runs, contributing into
%                  resulting Experiment
if numel(obj)>1
    error('HORACE:Experiment:invalid_argument', ...
        ['combine_experiments accepts only single Experiment object to add other experiments to.' ...
        ' Provided array of Experiments'])
end
nspe = obj.n_runs;
if isempty(exp_cellarray)|| numel(exp_cellarray)== 0
    return;
end
if isa(exp_cellarray,'Experiment')
    if numel(exp_cellarray) == 1
        exp_cellarray = {exp_cellarray};
    else
        exp_cellarray = num2cell(exp_cellarray);
    end
end

n_contrib = numel(exp_cellarray)+1;
nspe    = zeros(n_contrib,1);
nspe(1) = obj.n_runs;
for i=2:n_contrib
    nspe(i) = exp_cellarray{i}.n_runs;
end
ntotal = sum(nspe);

instr  = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER', ...
    'IX_inst');                         % previously cell(1,n_tot);
sampl  = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER', ...
    'IX_samp');                         % previously cell(1,n_tot);
%
% TODO: is this work in progress?
%detectors = unique_references_container('GLOBAL_NAME_DETECTORS_CONTAINER', ...
%    'IX_detector_array');

%detectors = []; % default empty detectors until the unique_references_containers are activated.
expinfo    = obj.expdata;
expinfo    = expinfo.combine(exp_cellarray,keep_runid,obj.runid_map);


instr{1}   = obj.instruments{1};
sampl{1}   = obj.samples{1};
% TODO: is these two rows below work in progress?
det        = cell(1,ntotal);
det{1}     = obj.detector_arrays{1};

ic = 2;
for i=1:n_contrib-1
    for j=1:exp_cellarray{i}.n_runs
        instr{ic}  = exp_cellarray{i}.instruments{j};
        sampl{ic}  = exp_cellarray{i}.samples{j};
        det{ic}    = exp_cellarray{i}.detector_arrays{j};
        % Check experiment consistency:
        % At present, we insist that the contributing spe data are distinct in that:
        %   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
        %   - emode, lattice parameters, u, v, sample must be the same for all spe data input
        if sampl{ic} ~= sampl{1}
            error('HORACE:Experiment:runtime_error',[...
                'The emode and sample for all runs contributing to experiment have to be the same.\n',...
                'File N%d, contributed run %d differs from the first run '],i,j);
        end
        if allow_equal_headers
            ic = ic+1;
            continue;
        end
        ic = ic+1;
    end
end

obj.do_check_combo_arg = false;
obj.instruments     = instr;
obj.samples         = sampl;
obj.detector_arrays = det;
obj.expdata         = expinfo;
obj.do_check_combo_arg = true;
obj = obj.check_combo_arg();

