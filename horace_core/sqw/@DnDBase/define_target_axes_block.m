function [targ_ax_block,targ_proj] = define_target_axes_block(obj, targ_proj, pbin, sym)
% Define target axes block from existing axes, cut inputs and the projections
% transforming the data into target image.
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

% check if default binning is necessary
default_needed = cellfun(@is_default_needed, pbin);

targ_proj = cellfun(@(x) x.transform_proj(targ_proj), ...
                    sym, 'UniformOutput', false);

if any(default_needed)
    % Get the source binning ranges, transformed into target coordinate system.
    source_binning = cellfun(@(proj) obj.get_targ_range(proj,default_needed,'-binning'), ...
                             targ_proj, 'UniformOutput', false);
else
    % empty binning as it will not be deployed
    source_binning = repmat({cell(1,4)}, numel(sym), 1);
end

targ_ax_block = cellfun(@(proj, sb) get_proj_axes_block(proj, sb, pbin), targ_proj, source_binning);
targ_ax_block = targ_ax_block(:);
targ_proj = vertcat(targ_proj{:});
for i = 1:numel(targ_ax_block)
    targ_ax_block(i).filename = obj.full_filename;
end

end

function needed = is_default_needed(pb)

needed = numel(pb) < 2 || ...
         isinf(pb(1)) || ...
         isinf(pb(end)) || ...
         (numel(pb)==3 && pb(2)==0);
end
