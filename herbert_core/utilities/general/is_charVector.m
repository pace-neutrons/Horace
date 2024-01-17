function [ok, n] = is_charVector (varargin)
% Determine if an argument is a character vector
%
%   >> [ok, n] = is_charVector (arg)
%   >> [ok, n] = is_charVector (arg1, arg2,...)
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


if nargin == 1
    % Single input argument
    % Don't create an anonymous function if only a single input - it turns out
    % to take a significant fraction of the running total time
    var = varargin{1};
    ok = ischar(var) && (isrow(var) || isempty(var));
    if ok
        n = numel(var);
    else
        n = NaN;
    end
    
elseif nargin > 1
    % Two or more input arguments
    % Create anonymous function so can call cellfun
    ok = cellfun(@(x)(ischar(x) && (isrow(x) || isempty(x))), varargin);
    n = NaN(size(varargin));
    n(ok) = cellfun(@numel,varargin(ok));
    
else
    % No input arguments
    ok = false(1,0);
    n = NaN(1,0);
end
