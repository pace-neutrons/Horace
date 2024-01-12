function [ok, n] = is_string (varargin)
% Determine if an argument is a character vector
%
%   >> [ok, n] = is_string (arg)
%   >> [ok, n] = is_string (arg1, arg2,...)
%
% This is identical to is_charVector, but the functionality of may change in the
% future to account for Matlab string class as input, whereas the functionality
% of is_charVector is not planned to be similarly changed.
%
% See also is_charVector
%
%
% Input:
% ------
%   arg1, arg2...   Input arguments
%
% Output:
% -------
%   ok              Logical array (row vector) with elements that are
%                   - true if corresponding input variable is a character vector
%                     (i.e. row vector of characters, or the empty character, '')
%                   - false otherwise
%
%   n               Row vector with the number of characters in the
%                   corresponding input arguments.
%                   Where an input argument is not a character vector, the
%                   element is set to NaN


[ok, n] = is_charVector (varargin{:});
