function [targ_ax_block,targ_proj] = define_target_axes_block(obj, targ_proj, pbin)
% Define target axes block from existing axes, cut inputs and the projections
% transforming the data into target image.

% Inputs:
% obj       -- DnD object
% targ_proj -- the projection class which defines the
%              coordinate system of the cut
% pbin      -- binning parameters of the cut
%
% Returns:
% targ_axes_block
%           -- the axes block which corresponds to the target
%              projection and have binning defined by pbin
%              parameter
% targ_proj
%           -- the input target projection, which extracted
%              some input parameters from source projection
%              (e.g. lattice if undefined, etc)

% check if default binning is necessary
default_needed = cellfun(@is_default_needed,pbin);
if any(default_needed)
    % Get the source binning ranges, transformed into target coordinate system.
    source_binning = obj.targ_range(targ_proj,'-binning');
else
    % empty binning as it will not be deployed
    source_binning = cell(1,4);
end
%
targ_ax_block  = targ_proj.get_proj_axes_block(source_binning,pbin);
targ_ax_block.full_filename = obj.full_filename;


function needed = is_default_needed(pb)

if numel(pb)<2
    needed = true;
    return;
end
needed =  isinf(pb(1))||isinf(pb(end));
if numel(pb)==3 && pb(2)==0
    needed = true;
end

