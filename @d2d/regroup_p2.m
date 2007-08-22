function wout = regroup_p2(win,varargin)
% regroup dataset 2d objects in libisis
%
% dataset_new = regroup_p2(dataset_2d,params), or 
% dataset_new = regroup_p2(dataset_2d,ylo,dy,yhi)
%
% regroups an d2d object according to parameters given
% where params=[ylo,dy,yhi] describe the binning paramaters to ensure that bins have minimum width 
% determined by the parameter dy, but ensuring the bin boundaries are always coincedent with original
% bin boundaries.
%
% input: either params = [ylo, dy, yhi] or as separate arguments ylo to yhi = range
% dy = minimum bin width, dataset_2d to regroup
%
% output: d2d that has been regrouped
% 
% if given an array of dataset_2d, each will be regrouped using the params
% given.
%
% If params are given as arrays of the same size as dataset_2d, then 
% dataset_2d(i) will be regrouped with the parameters ylo(i), dy(i), yhi(i).
% 
% When given in the params array, ylo, dy and yhi should be column vectors,
% otherwise they can be either row or column vectors, as long as they are
% the same size as the dataset array.
%
% This mirrors the Libisis command regroup_y, see libisis documentation for
% advanced usage.
%
wout = dnd_data_op(win, @regroup_y, 'd2d' , 2, varargin{:});