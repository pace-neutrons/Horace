function range = targ_range(obj,targ_proj)
%TARG_RANGE calculate the full range of the image to be produced by target
% projection from the current image,
%
% 
%

source_proj = obj.proj;
%
% cross-assign appropriate projections to enable possible optimizations
source_proj.targ_proj = targ_proj;
targ_proj.targ_proj   = source_proj;

if isa(source_proj,class(targ_proj))
    cur_range = obj.img_range;
    full_range = expand_box(cur_range(1,:),cur_range(2,:));
    full_targ_range = source_proj.from_this_to_targ_coord(full_range);
    range = [min(full_targ_range,[],2);max(full_targ_range,[],2)];
else
    range = search_for_range(obj,source_proj);
end

function range = search_for_range(obj,source_proj)
% find the maximal range, the current grid occupies in target coordinate
% system
%
% The most primitive search algorithm possible.
%
[range0,dE_range] = transf_range(obj,source_proj,1);
difr = 1;
node_mult = 2;
while difr>1.e-3 && node_mult<16
    range = transf_range(obj,source_proj,node_mult);
    difr = calc_difr(range0,range);
    range0 = range;
end
%
if source_proj.do_3D_transformation
    range  = [range,dE_range];
end

function [loc_range,dE_range] = transf_range(obj,source_proj,multiplier)

if source_proj.do_3D_transformation
    shell = obj.axes.get_bin_nodes('-3D','-hull',multiplier);
    dE_range = obj.axes.img_range(:,4);
else
    shell = obj.axes.get_bin_nodes('-hull',multiplier);
    dE_range = [];
end
shell_transf = source_proj.from_this_to_targ_coord(shell);
loc_range = [min(shell_transf,[],2),max(shell_transf,[],2)]';

function difr = calc_difr(range0,range)
% calculate maximal difference between two ranges
min_difr = max(-(range(1,:)-range0(1,:)));
max_difr = max((range(2,:)-range0(2,:)));
difr     = max(min_difr,max_difr);