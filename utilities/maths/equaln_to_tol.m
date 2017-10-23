function [ok,mess]=equaln_to_tol2(a,b,varargin)
% Check if two arguments are equal within a specified tolerance
%
%   >> ok = equaln_to_tol (a, b)
%   >> ok = equaln_to_tol (a, b, tol)
%   >> ok = equaln_to_tol (..., keyword1, val1, keyword2, val2,...)
%   >> [ok, mess] = equal_to_tol (...)
%
% Any cell arrays, structures or objects are recursively explored.
% Two NaNs are treated as equivalent. To treat NaNs as inequivalent use
% the mirror function equal_to_tol.
%
% See also equal_to_tol
%
% Input:
% ------
%   a,b     test objects (scalar objects, or arrays of objects with same sizes)
%
%   tol     Tolerance criterion for numeric arrays (Default: [0,0] i.e. equality)
%           It has the form: [abs_tol, rel_tol] where
%               abs_tol     absolute tolerance (>=0; if =0 equality required)
%               rel_tol     relative tolerance (>=0; if =0 equality required)
%           If either criterion is satified then equality within tolerance
%           is accepted.
%             Examples:
%               [1e-4, 1e-6]    absolute 1e-4 or relative 1e-6 required
%               [1e-4, 0]       absolute 1e-4 required
%               [0, 1e-6]       relative 1e-6 required
%               [0, 0]          equality required
%               0               equivalent to [0,0]
%           If  set to 0, then this is equivalent to [0,0]
%
%
% Valid keywords are:
%  'ignore_str'      Ignore the length and content of strings or cell arrays
%                   of strings (true or false; default=false)
%
%
% Output:
% -------
%   ok      true if every element satisfies tolerance criterion, false if not
%   mess    error message if ~ok ('' if ok)


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


warn = warning('off','MATLAB:structOnObject');
cleanup_obj = onCleanup(@()warning(warn));

% Parse input
opt.ignore_str = false;
if nargin==2
    % Simple case of two variables to be compared
    tol = [];
else
    if nargin==3 && isnumeric(varargin{1})
        % Case of no optional arguments - save an expensive call to parse_arguments
        tol = varargin{1};
    else
        % Optional arguments
        flagnames = {'ignore_str'};
        [par, opt, ~, ~, ok, mess] = parse_arguments(varargin, opt, flagnames);
        if ~ok, error(mess), end
        
        % Check single parameter tol and that it is numeric
        if numel(par)==1 && isnumeric(par{1})
            tol = par{1};
        elseif numel(par)==0
            tol = [];
        else
            error('Check number and type of input arguments')
        end
    end
end

% Set nan_equal and tolerance
opt.nan_equal = true;   % as this is equaln_to_tol

if isempty(tol) || isequal(tol,0)
    opt.tol = [0,0];
elseif numel(tol)==2 && all(tol>=0)
    opt.tol = tol;
else
    error('Check ''tol'' has form [abs_tol, rel_tol] where both are >=0')
end

% Now perform comparison
name_a = inputname(a);
name_b = inputname(b);
if isempty(name_a), name_a = 'Arg1'; end
if isempty(name_b), name_b = 'Arg2'; end
[ok,mess]=equal_to_tol_private(a,b,opt,name_a,name_b);
