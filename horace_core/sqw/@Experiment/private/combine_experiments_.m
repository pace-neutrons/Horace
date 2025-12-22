function [obj,nspe,run_id_array] = combine_experiments_(obj,exp_cellarray,allow_equal_headers,keep_runid)
%COMBINE_EXPEERIMENTS_
% Take cellarray of experiments (e.g., generated from each runfile build
% during gen_sqw generation)
% and combine then together into single Experiment info class
% Inputs:
% obj           -- first experiment to add other experiments to.
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
% run_id_array   -- array of final run_id-s for all input nxspe. one id per
%                  input run
if numel(obj)>1
    error('HORACE:Experiment:invalid_argument', ...
        ['combine_experiments accepts only single Experiment object to add other experiments to.' ...
        ' Provided array of Experiments'])
end
nspe = obj.n_runs;
if isempty(exp_cellarray)|| numel(exp_cellarray)== 0
    expinfo    = obj.expdata;    
    [~,run_id_array]    = expinfo.combine(exp_cellarray,allow_equal_headers,keep_runid,obj.runid_map);
    return;
end
if isa(exp_cellarray,'Experiment')
    if isscalar(exp_cellarray)
        exp_cellarray = {exp_cellarray};
    else
        exp_cellarray = num2cell(exp_cellarray);
    end
end

n_contrib = numel(exp_cellarray)+1;
nspe    = zeros(n_contrib,1);
nspe(1) = obj.n_runs;
for i=1:n_contrib-1
    nspe(i+1) = exp_cellarray{i}.n_runs;
end
% ntotal = sum(nspe);

%detectors = []; % default empty detectors until the unique_references_containers are activated.
expinfo    = obj.expdata;
[expinfo,run_id_array,skipped_runs]    = expinfo.combine(exp_cellarray,allow_equal_headers,keep_runid,obj.runid_map);


instr   = obj.instruments;
sampl   = obj.samples;
% TODO: is these two rows below work in progress?
det     = obj.detector_arrays;

ic = instr.n_objects;
for i=1:n_contrib-1
    skipped_run = skipped_runs{i};
    for j=1:exp_cellarray{i}.n_runs
        if skipped_run(j) % the run have been rejected 
            continue;
        end
        ic = ic+1;        
        instr{ic}  = exp_cellarray{i}.instruments{j};
        sampl{ic}  = exp_cellarray{i}.samples{j};
        det{ic}    = exp_cellarray{i}.detector_arrays{j};
        % Check experiment consistency:
        % At present, we insist that the contributing spe data are distinct in that:
        %   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two spe data input
        %   - emode, lattice parameters, u, v, sample must be the same for all spe data input
        if sampl{ic} ~= sampl{1}
            error('HORACE:Experiment:runtime_error',[...
                'The sample for all runs contributing to experiment have to be the same.\n',...
                'File N%d, contributed run %d differs from the first run '],i,j);
        end

    end
end

obj.do_check_combo_arg = false;
obj.instruments     = instr;
obj.samples         = sampl;
obj.detector_arrays = det; % 
obj.expdata         = expinfo;
obj.do_check_combo_arg = true;
obj = obj.check_combo_arg();

