function [en_tot,unique_idx]  = get_en_transfer(exper,bin_centre,get_lidx)
%GET_EN_TRANSFER Return cellarray of energy transfer arrays, contributed
% into the array of IX_experiments.
%
% Duplicated energy transfers arrays are omitted.
%
% Inputs:
% exper     -- array of IX_experiment classes
%
% bin_centre -- currently assumed that IX_experiment contains bin boundaries
%               for each bunch of the neutron events contributing into pixel.
%               if bin_centre is true, function returns bin centres of
%               these bins rather than their bin boundaries of these
%               bunches
% get_lidx  --  If true, return cellarray of local indices,
%               if false, arry of unique indices.
%
% Returns:
% en       -- cellarray of energy transfer arrays, present in experiment
%             containing only unique energy transfer arrays.
%
% unique_idx  depending on get_lidx false or true
%       -- either (get_lidx == false)
%             array of unique indices, providing access
%             to each first unique instance of energy transfer array.
%       -- or    (get_lidx == true)
%             cellarray of arrays of local indices, each bunch
%             gives access to the indices pointing to a
%             single unique bunch of energy transfers

n_runs = numel(exper);
en_tot = cell(1,n_runs);
normas = zeros(1,n_runs);
for i=1:n_runs
    en_tot{i} = exper(i).get_en(bin_centre);
    normas(i) = norm(en_tot{i}); % kind of simplified hash for energy transfer array. 
    % May think to replace to build_hash for reliability
end
[~,idx] = sort(normas);
en_sorted = en_tot(idx);
unique_idx = ones(1,n_runs);
n_unique = 1;
for i=2:n_runs
    if isequal(en_sorted{i},en_sorted{i-1})
        unique_idx(i) = n_unique;
        continue;
    end
    n_unique = n_unique+1;
    unique_idx(i) = n_unique;
end
ridx          = 1:n_runs;
[~,ridx]      = sort(ridx(idx));
unique_idx    = unique_idx(ridx);
[un_idx,ia,ic]= unique(unique_idx);
en_tot = en_tot(ia);
if get_lidx
    n_unique = numel(un_idx);
    lidx = 1:n_runs;
    unique_idx = cell(1,n_unique);
    for i=1:n_unique
        unique_idx{i} = lidx(ic==i);
    end
else
    unique_idx = ia(:)';
end
