function expt_idx = get_experiment_idx_ (obj, run_idx, sparse_lookup)
% Get the indices in the experiment_info for an array of run indices in the pixel data
%
%   >> expt_idx = get_experiment_idx_ (obj, run_idx)
%   >> expt_idx = get_experiment_idx_ (obj, run_idx, sparse_lookup)
%
% The sqw object property 'experiment_info' contains arrays of information
% for the contributing runs to the sqw object; the pixel data as held in the sqw
% object property 'pix.run_idx' contains the run identifer. This routine returns
% the index into the arrays in 'experiment_info' that correspond to the input
% run identifiers.
%
% Input:
% ------
%   obj             Instance of Experiment object.
%   run_idx         Array of run indices selected from the pix field of an sqw object.
%                   The array can have any size.
%
% Optionally:
%   sparse_lookup   Force a sparse intermediate lookup array or a full lookup
%                   array according as the value true or false.
%                   This overrules the default behaviour that selects full if
%                   the range of the run indices in the pix field is less than
%                   10^5 or more than 50% of the elements in the full lookup are
%                   non-zero.
%
% NOTE: ths option is currently disabled. See Re #1837 to check and enable
%       it if necessary
% 
%
% Output:
% -------
%   expt_idx        Index into the arrays of experiment information held in the
%                   input Experiment object in eexpdata field array 
%                   corresponding to the values of run_idx.
%                   The size of expt_idx is the same as that of run_idx.


if isempty(run_idx)     % catch and return if trivial case of empty run_idx
    expt_idx = zeros(size(run_idx));
    return
end

map = obj.runid_map;
expt_idx = map.get_values_for_keys(run_idx(:),true,1);

if any(isnan(expt_idx))
    error('HORACE:Experiment:invalid_argument',...
        'One or more input run indices do not appear in the sqw object runid map');
end
expt_idx = reshape(expt_idx, size(run_idx));
