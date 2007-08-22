function wout = rebunch_p1(win,varargin)
% rebunch a d2d object in p1 dimension.
%
% >> new_dataset_2d = rebunch_p1(dataset_2d,xbins)
%
% rebunches an d2d object with xbins elements grouped together
%
% inputs: 
%
%   dataset_2d:         d2d object or array
%   xbins:              Number of bins to group together
%
% output: 
%
%   new_dataset_2d:     d2d object
%
% if given an array of d2d, each dataset will be rebunched to
% xbins, if ybins is an array of the same length of the dataset array, then
% dataset(i) will be rebunched with xbins(i).
%
% This mirrors the Libisis command rebunch_x, see libisis documentation for
% advanced usage.

wout = dnd_data_op(win, @rebunch_x, 'd2d' , 2, varargin{:});