function wout = rebunch(win,varargin)
% rebunch a d2d object.
%
% >> new_dataset_2d = rebunch(dataset_2d,xbins, ybins)
%
% rebunches an d2d object with ybins elements grouped together
%
% inputs: 
%
%   dataset_2d:         d2d object or array
%   xbins:              Number of bins to group together in the p1
%                       dimension.
%   ybins:              Number of bins to group together in p2 dimension
%
% output: 
%
%   new_dataset_2d:     d2d object
%
% if given an array of d2d, each dataset will be rebunched to
% xbins and ybins, if xbins and ybins are arrays of the same length of the dataset array, then
% dataset(i) will be rebunched in p1 dimension with xbins(i) and p2 dimension with ybins(i).
%
% This mirrors the Libisis command rebunch_xy, see libisis documentation for
% advanced usage.
wout = dnd_data_op(win, @rebunch_xy, 'd2d' , 2, varargin{:});