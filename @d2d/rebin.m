function wout = rebin(win, varargin)
% rebin_xy - rebin dataset 2d in x and y directions. 
%
% Syntax:
%   >> new_dataset = rebin(dataset_2d,x_option,y_option)
%
% Inputs:
% -------
%   dataset_2d:     d2d object to be rebinned
%   x_option:       xref or xdesc
%   y_option:       yref or ydesc
%
% Outputs:
% --------
%   new_dataset:    Dataset rebinnned appropriately. 
%
% Description:
% ------------
% rebins the p1-dimension of an d2d object according x_option and
% the p2-dimension according to y_option.
%
% For further explanation of xdesc/ydesc and xref/yref please consult
% the help for rebin_p1 and/or rebin_p2.
%
% This only accepts the x and y options in the array format, i.e.
%
% dataset_2d = rebin(a,[xlo, dx, xhi],[ylo, dy, yhi])  or
%
% dataset_2d = rebin(a,[xlo, dx, xhi, xlo2, dx2, xhi2...],[ylo, dy, yhi,
% ylo2, dy2, yhi2...]) etc.
%
% can be given array data in dataset_2d or column arrays for xlo, dx, xhi, ylo, dy,
% yhi, as in rebin_p1 and rebin_p2.
%
% This function mirrors the libisis rebin_xy function. See libisis
% documentation for advanced usage.

wout = dnd_data_op(win, @rebin_xy, 'd2d' , 2, varargin{:});