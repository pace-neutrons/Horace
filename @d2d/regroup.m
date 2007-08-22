function wout = regroup (win, varargin)
% regroup a d2d object.
%
% >> regroup_xy(dataset_2d,xparams,yparams)
%
% regroups a d2d object along the p1-dimension according to the
% xparams array and along the p2-dimension according to the yparams array.
% where xparams=[xlo,dx,xhi] and yparams=[ylo,dy,yhi] describe the p1 and p2 dimension 
% binning paramaters to ensure that bins have minimum width determined by
% the parameter dx/dy, but ensuring the bin boundaries are always coincedent with
% original bin boundaries.
%
% if given an array of dataset_2d, each dataset will be regrouped with the
% x and y parameters. 
%
% xlo, dx, xhi, ylo, dy, yhi can be given as column vectors of the same
% length as dataset_2d such that each dataset_2d will be rebinned with the
% coresponding values in the column vectors. 
%
% This mirrors the Libisis command regroup, see libisis documentation for
% advanced usage.

wout = dnd_data_op(win, @regroup_xy, 'd2d' , 2, varargin{:});