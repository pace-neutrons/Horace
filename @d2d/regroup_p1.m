function wout = regroup_p1(win,varargin)
% regroup dataset 2d objects in libisis
%
% dataset_new = regroup_p1(dataset_1d,params), or 
% dataset_new = regroup_p1(dataset_1d,xlo,dx,xhi)
%
% regroups an d2d object according to parameters given
% where params=[xlo,dx,xhi] describe the binning paramaters to ensure that bins have minimum width 
% determined by the parameter dx, but ensuring the bin boundaries are always coincedent with original
% bin boundaries.
%
% input: either params = [xlo, dx, xhi] or as separate arguments xlo to xhi = range
% dx = minimum bin width, d2d to regroup
%
% output: d2d that has been regrouped
% 
% if given an array of d2d, each will be regrouped using the params
% given.
%
% If params are given as arrays of the same size as dataset_1d, then 
% dataset_1d(i) will be regrouped with the parameters xlo(i), dx(i), xhi(i).
% 
% When given in the params array, xlo, dx and xhi should be column vectors,
% otherwise they can be either row or column vectors, as long as they are
% the same size as the dataset array.
%
% This mirrors the Libisis command regroup_x, see libisis documentation for
% advanced usage.

wout = dnd_data_op(win, @regroup_x, 'd2d' , 2, varargin{:});