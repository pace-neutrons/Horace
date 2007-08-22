function wout = rebunch_p2(win,varargin)
% rebunch a d2d object.
%
% >> new_dataset_2d = rebunch_p2(dataset_2d,ybins)
%
% rebunches an d2d object with ybins elements grouped together
%
% inputs: 
%
%   dataset_2d:         d2d object or array
%   ybins:              Number of bins to group together
%
% output: 
%
%   new_dataset_2d:     d2d object
%
% if given an array of d2d, each dataset will be rebunched to
% ybins, if ybins is an array of the same length of the dataset array, then
% dataset(i) will be rebunched with ybins(i).
%
% This mirrors the Libisis command rebunch_y, see libisis documentation for
% advanced usage.

wout = dnd_data_op(win, @rebunch_y, 'd2d' , 2, varargin{:});