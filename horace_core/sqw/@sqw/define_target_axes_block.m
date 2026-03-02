function [targ_ax_block,targ_proj,sym] = define_target_axes_block(w, targ_proj, pbin, sym)
% Define target axes from existing axes, inputs and the target projections.
% If symmetry operations are provided, generate projections, which would 
% correspond to specified symmetry operations and do transformations 
% from symmetry related areas to target area.
%
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
% sym       -- cellarray of modified symmetry operations, i.e. 
%              each single operation has b-matrix attached to it and
%              combination (array) of symmetry operations is transformed
%              into generic symop

[targ_ax_block, targ_proj,sym] = w.data_.define_target_axes_block(targ_proj, pbin, sym);
