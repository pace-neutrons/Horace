function obj = set_sample (obj,sample)
% Change the sample in an sqw object or array of objects
% in memory. 
%
%   >> wout = set_sample (w, sample)
%
%
% Input:
% -----
%   w           Input sqw object or array of objects
%
%   sample      Sample object (IX_sample object) or structure
%              Note: only a single sample object can be provided. That is,
%              there is a single sample for the entire sqw data set.
%               If the sample is any empty object, then the sample is set
%              to the default empty structure.
%
% Output:
% -------
%   wout        Output sqw object with changed sample loaded in memory


% Original author: T.G.Perring
%




% Perform operations
% ------------------

[set_single,set_per_obj,n_runs_in_obj]=find_set_mode_(obj,sample);

n_runs_set = 0;
for i=1:numel(obj)
    if set_single
        exper = obj(i).experiment_info;
        exper.samples = sample;
        obj(i).experiment_info = exper;
    elseif set_per_obj
        exper = obj(i).experiment_info;
        exper.samples = sample(i);
        obj(i).experiment_info = exper;
    else % split
        exper = obj(i).experiment_info;
        exper.samples = sample(n_runs_set+1:n_runs_set+n_runs_in_obj(i));
        obj(i).experiment_info = exper;
        n_runs_set = n_runs_set + n_runs_in_obj(i);
    end
end
