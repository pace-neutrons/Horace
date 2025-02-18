function [en_transf,unique_idx]  = get_en_transfer(exper,bin_centre,get_lidx)
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
%               if false, array of unique indices.
%
% Returns:
% en       -- cellarray of energy transfer arrays, one per each element of
%             input exper array.
%             If two arguments are requested, this cellarray contains
%             unique energy transfer values only
%
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
en_transf = cell(1,n_runs);
for i=1:n_runs
    en_transf{i} = exper(i).get_en(bin_centre);
end
if nargout>1
    Diff =[1.e-8,1.e-8];
    unique_idx = calc_eq_indices(en_transf,Diff);
    n_unique = numel(unique_idx);
    ent_selected = cell(1,n_unique);
    for i=1:n_unique
        first_unique = unique_idx{i}(1);
        if ~get_lidx
            unique_idx{i} = first_unique;
        end
        ent_selected{i} = en_transf{first_unique};
    end
    en_transf = ent_selected;
end