function [isfitting,index,foreground,store_calcs]=multifit_get_dataset_index
% Get the most recently set datset index and type of function evaluation request
%
%   >> [index,foreground,store_calcs] = multifit_get_dataset_index
%
% Output:
% -------
%   isfitting       Logical flag:
%                      =true  if in multifit least squares fitting function
%                      =false if not
%
%   index           Index of function (empty if not fitting)
%
%   foreground      Logical flag:
%                       =true  if foreground function
%                       =false if background function
%                   Empty if not fitting
%
%   store_calcs     Logical flag:
%                       =true  if computed values of the function are being stored
%                       =false if computed values are not being saved
%                   This is equivalent to partial derivatives not being evaluated
%                  if true, or they are being evaluated if false.
%                   Empty if not fitting
%
% This function can be called inside user provided functions to control 
% the calculation of function e.g. having dataset specific branching, or
% control of random number generators.

% Simply an interface to a hidden function in the multifit /private folder
[isfitting,index,foreground,store_calcs]=multifit_store_dataset_index;
