function [targ_ax_block,targ_proj] = define_target_axes_block(w, targ_proj, pbin, sym)
% define target axes from existing axes, inputs and the target projections
% Inputs:
%  w        -- sqw object
% targ_proj -- the projection class which defines the
%              coordinate system of the cut
% pbin      -- bining parameters of the cut
%
% sym       -- Symmetry operations to apply to block
%
% Retugns:
% targ_axes_block
%           -- the axes block which corresponds to the target
%              projection and have binning defined by pbin
%              parameter
% targ_proj
%           -- the input target projection, which extracted
%              some input parameters from source projection
%              (e.g. lattice if undefined, etc)
[targ_ax_block, targ_proj] = w.data_.define_target_axes_block(targ_proj, pbin, sym);
