function [targ_ax_block,targ_proj,sym] = define_target_axes_block(obj, targ_proj, pbin, sym)
% Define target axes block from existing axes, cut inputs and the projections
% transforming the data into target image. If symmetry operations are
% provided, generate projections, which would correspond to specified
% symmetry operations and do transformations from symmetry related areas
% to target area.
%
% Inputs:
% obj       -- DnD object
% targ_proj -- the projection class which defines the
%              coordinate system of the cut
% pbin      -- binning parameters of the cut
%
% sym       -- Symmetry operations to apply to block
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
% sym       -- cellarray of modified symmetry operations, i.e.
%              each single operation has b-matrix attached to it and any
%              combinations (array) of symmetry operations are transformed
%              into generic symop

% check if default binning is necessary
default_needed = cellfun(@is_default_needed, pbin);

if isa(targ_proj,'LineProjBase')
    [targ_proj,sym] = cellfun(@(x) x.transform_proj(targ_proj), ...
        sym, 'UniformOutput', false);
else
    targ_proj = {targ_proj};
end

if any(default_needed)
    % Get the source binning ranges, transformed into target coordinate system.
    source_binning = obj.get_targ_range(targ_proj{1},default_needed,'-binning');
else
    % empty binning as it will not be deployed
    source_binning = cell(1,4);
end

targ_proj = vertcat(targ_proj{:});
targ_ax_block = targ_proj(1).get_proj_axes_block(source_binning, pbin);
targ_ax_block.filename = obj.full_filename;
end

function needed = is_default_needed(pb)

needed = numel(pb) < 2 || ...
    isinf(pb(1)) || ...
    isinf(pb(end)) || ...
    (numel(pb)==3 && pb(2)==0);
end
