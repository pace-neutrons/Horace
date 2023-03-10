function [targ_ax_block,targ_proj] = define_target_axes_block(obj, targ_proj, pbin,varargin)
% Define target axes block from existing axes, cut inputs and the projections
% transforming data into target image.

% Inputs:
% obj       -- DnD object
% targ_proj -- the projection class which defines the
%              coordinate system of the cut
% pbin      -- bining parameters of the cut
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


% Get the source binning ranges, transformed into target coordinate system.
% It is actually AxesBlockBase method, so source projection is provided as
% input of this method. Left in this form until data_sqw_dnd is a AxesBlockBase
source_binning = obj.targ_range(targ_proj,'-binning');
%
targ_ax_block  = targ_proj.get_proj_axes_block(source_binning,pbin);
targ_ax_block.full_filename = obj.full_filename;

