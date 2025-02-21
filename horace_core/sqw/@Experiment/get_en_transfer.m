function [en,unique_idx]  = get_en_transfer(obj,bin_centre,get_lidx)
%GET_EN_TRANSFER Return cellarray of energy transfer arrays, contributed
% to the experiment.
%
% Duplicated energy transfers arrays are omitted.
% 
% Inputs:
% obj        -- initialized instance of experiment
% Optional:
% bin_centre -- currently assumed that IX_experiment contains bin boundaries
%               for each bunch of the contributing neutron events.
%               if bin_centre is true, function returns bin centres of
%               these bins rather than their bin boundaries. Default --
%               false
% get_lidx  --  default false. If true, return compact_array of energy transfers
%               highlighting unique energy transfer values and 
%               if false, array of unique indices
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
[en,unique_idx]  = get_en_transfer(obj.expdata_,bin_centre,get_lidx);
if get_lidx
    en = compact_array(unique_idx,en);
end
