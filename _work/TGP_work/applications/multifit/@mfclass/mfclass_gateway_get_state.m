function [isfitting,index,foreground,store_calcs] = mfclass_gateway_get_state (obj)
% Get the most recently set datset index and type of function evaluation request
%
%   >> [isfitting,index,foreground,store_calcs] = mfclass_gateway_get_state
%
% Output:
% -------
%   isfitting       Logical flag: (empty if not not in multifit)
%                      =true  if in multifit least squares fitting function
%                      =false if in multifit but not in the least squares algorithm
%
%   index           Index of current dataset (empty if not not in multifit)
%
%   foreground      Logical flag: (empty if not not in multifit)
%                       =true  if foreground function
%                       =false if background function
%
%   store_calcs     Logical flag: (empty if not not in multifit)
%                       =true  if computed values of the function are being stored
%                       =false if computed values are not being saved
%                   This is equivalent to partial derivatives not being evaluated
%                  if true, or they are being evaluated if false.
%
% This function can be called inside user provided functions to control
% the calculation of function e.g. having dataset specific branching, or
% control of random number generators.

% Fixup until persistent variables in mfclass least-squares fitting are replaced by class properties

[isfitting,index,foreground,store_calcs]=multifit_store_state;
