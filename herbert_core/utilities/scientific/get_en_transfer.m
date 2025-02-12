function [en,unique_idx]  = get_en_transfer(exper,bin_centre,get_lidx)
%GET_EN_TRANSFER Return cellarray of energy transfer arrays, contributed
% into the array of IX_experiments.
%
% Duplicated energy transfers arrays are omitted.
%
% Inputs:
% exper     -- array of IX_experiment classes
% Optional:
% bin_centre -- currently assumed that IX_experiment contains bin boundaries
%               for each bunch of the contributing neutron events.
%               if bin_centre is true, function returns bin centres of
%               these bins rather than their bin boundaries. Default --
%               false
% get_lidx  --  default false. If true, return cellarray of local indices,
%               if false, arry of unique indices
%
% Returns:
% en       -- cellarray of energy transfer arrays, present in experiment
%             contains only unique energy transfer arrays.
% unique_idx  depending on get_lidx false or true
%          -- either (get_lidx == false)
%             array of unique indices, providing access
%             to each first unique instance of energy transfer array.
%          -- or    (get_lidx == true)
%             cellarray of arrays of local indices, each bunch
%             gives access to the indices pointing to a
%             single unique bunch of energy transfers
if nargin == 1
    bin_centre = false;
    get_lidx   = false;
end
if nargin == 2
    get_lidx   = false;
end
n_runs = numel(exper);
en = cell(1,n_runs);
unique_idx = zeros(1,n_runs);

en{1} = exper(1).get_en(bin_centre);
unique_idx(1) = 1;
n_unique = 1;
equal_energies = ones(1,n_runs);
for i=2:n_runs
    if isequal(exper(i).en,exper(i-1).en)
        equal_energies(i)= n_unique;
        continue;
    end
    n_unique = n_unique+1;
    unique_idx(n_unique)= i;
    en{n_unique}  = exper(i).get_en(bin_centre);
end

if n_unique ~= n_runs
    en = en(1:n_unique);
    unique_idx = unique_idx(1:n_unique);
end
if get_lidx
end