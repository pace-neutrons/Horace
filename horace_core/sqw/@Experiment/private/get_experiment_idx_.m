function expt_idx = get_experiment_idx_ (obj, run_idx, sparse_lookup)
% Get the experiment indices for an array of run indices in the pixel data
% 
%   >> expt_idx = get_experiment_idx_ (obj, run_idx)
%   >> expt_idx = get_experiment_idx_ (obj, run_idx, sparse_lookup)
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
% Output:
% -------
%   expt_idx        Index into the arrays of experiment information held in the
%                   input Experiment object corresponding to the values of
%                   run_idx.
%                   The size of expt_idx is the same as that of run_idx.

map = obj.runid_map;
keys = cell2mat(map.keys);      % row vector
values = cell2mat(map.values);  % row vector

% Fill a lookup array with the elements indexed by the keys containing the
% values corresponding to those keys. Elements with indices that are not in the
% list of keys will be set to zero.
max_key = max(keys);
min_key = min(keys);
range_keys = max_key - min_key + 1;

% The default is to use a sparse lookup array if both:
% (1) a default range threshold is exceeded, and
% (2) the lookup array is more sparse than a default fractional threshold
% A full or sparse lookup array can be forced by specifying the optional
% argument sparse_lookup as false or true.
if ~exist('sparse_lookup','var')
    range_key_threshold = 10000;
    frac_sparse_threshold = 0.5;
    if (range_keys < range_key_threshold) || (numel(keys) > frac_sparse_threshold * range_keys)
        make_sparse_lookup = false;
    else
        make_sparse_lookup = true;
    end
else
    make_sparse_lookup = logical(sparse_lookup);    % handle case of numeric input
end

if make_sparse_lookup
    % Use a sparse array to hold the lookup array if the range of the keys is
    % greater than a threshold and the keys are sparse than a sparcity
    % threshold. This avoids wasteful use of memory (or even trying to allocate
    % physically unavailable memory) if the range of the key values is large.
    % We cannot assume that the keys are in sorted order, so a binary chop
    % algorithm is not possible without performing a sort first (which is an
    % Nlog(N) method).
    lookup = sparse(1, keys - min_key + 1, values, 1, range_keys);
else
    % Use full lookup array for speed, even if there is some waste of memory
    % allocation.
    lookup = zeros(1, range_keys);
    lookup(keys - min_key + 1) = values;
end

try
    expt_idx = lookup(run_idx - min_key + 1);
    if issparse(expt_idx)
        expt_idx = full(expt_idx);  % convert to full array in case of sparse lookup
    end
    expt_idx = reshape(expt_idx, size(run_idx));
catch
    error('HORACE:Experiment:invalid_argument',...
        'One or more input run indices lie outside the range in the sqw object runid map');
end
if any(expt_idx==0)
    error('HORACE:Experiment:invalid_argument',...
        'One or more input run indices do not appear in the sqw object runid map');
end
