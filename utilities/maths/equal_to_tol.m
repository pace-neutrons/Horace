function [ok,mess]=equal_to_tol(a,b,varargin)
% Check if two arguments are equal within a specified tolerance
%
%   >> ok = equal_to_tol (a, b)
%   >> ok = equal_to_tol (a, b, tol)
%   >> ok = equal_to_tol (..., keyword1, val1, keyword2, val2,...)
%   >> [ok, mess] = equal_to_tol (...)
%
% Any cell arrays, structures or objects are recursively explored.
% Comparison of two NaNs always results in failure. To equate NaNs use
% the mirror function equaln_to_tol.
%
% See also equaln_to_tol
%
% Note: legacy usage has scalar tol and equates NaNs as equal. This usage is
% deprecated. Please use the new syntax. Note that the usage: equal_to_tol(a,b)
% can be interpreted as new style or legacy format; it will be interpreted as
% the new format, which may result in errors in previously running code.
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
%
%
% -----------------------------
% *** Deprecated use: ***
% -----------------------------
% The legacy input argument usage has a scalar tolerance, where a negative
% number refers to a relative tolerance.
%
%   tol     tolerance (default: equality required)
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%           To apply an absolute as well as a relative tolerance, set the
%           value of the legacy keyword 'min_denominator' (see below)
%
% Valid keywords are:
%  'ignore_str'      Ignore the length and content of strings or cell arrays
%                   of strings (true or false; default=false)
%  'nan_equal'       Treat NaNs as equal (true or false; default=true)
%  'min_denominator' Minimum denominator for relative tolerance calculation
%                   (>=0; default=0).
%                    When the denominator in a relative tolerance is less than
%                   this value, the denominator is replaced by this value.
%
%                    Emulate [abs_tol,rel_tol] by setting
%                       tol = -rel_tol
%                       min_denominator = abs_tol / rel_tol


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% The following code is pretty commplex as it has to handle legacy input as
% well. Touch at your peril!
warn = warning('off','MATLAB:structOnObject');
cleanup_obj = onCleanup(@()warning(warn));

% Parse input arguments
if nargin==2
    % Resolve ambiguity of legacy input or not in favour of new format
    legacy = false;
    tol = [];
    opt.ignore_str = false;
    opt.nan_equal = false;
    
else
    % Have to determine if legacy format and handle accordingly
    legacy = [];    % undetermined input as yet
    
    if nargin==3 && isnumeric(varargin{1})
        % Case of no optional arguments - save an expensive call to parse_arguments
        tol=varargin{1};
        opt.ignore_str = false;
        
        % Determine if legacy input; it must be if scalar tol
        if isscalar(varargin{1})
            legacy = true;
            opt.nan_equal = true;   % legacy default
            min_denominator = 0;    % legacy default
        else
            legacy = false;
            opt.nan_equal = false;
        end
        
    else
        % Optional arguments must have been given; parse input arguments
        % opt filled with default for new format; strip min_denominator away later
        opt = struct(...
            'ignore_str',false,...
            'nan_equal',false,...   % new format default for nan_equal
            'min_denominator',0);
        flagnames = {'ignore_str','nan_equal'};
        [par, opt, present, ~, ok, mess] = parse_arguments(varargin, opt, flagnames);
        if ~ok, error(mess), end
        
        % Check single parameter tol and that it is numeric
        if numel(par)==1 && isnumeric(par{1})
            tol = par{1};
            if isscalar(tol)
                legacy = true;
            else
                legacy = false;
            end
        elseif numel(par)==0
            tol = [];
        else
            error('Check number and type of input arguments')
        end
        
        % Determine if legacy input if not already determined
        % (Only way to understand this if-elseif-else is to draw a truth table)
        legacy_options = (present.nan_equal || present.min_denominator);
        if (isempty(legacy) && legacy_options) || (~isempty(legacy) && legacy)
            legacy = true;
            if ~present.nan_equal
                opt.nan_equal = true;   % set legacy default
            end
            if ~isnumeric(opt.min_denominator) || ~isscalar(opt.min_denominator)...
                    || isnan(opt.min_denominator) || opt.min_denominator<0
                error('Check value of ''min_denominator''')
            end
            min_denominator = opt.min_denominator;
            
        elseif ~(legacy_options || (~isempty(legacy) && legacy))
            legacy = false;
            
        else
            error('Check number, type and format of input arguments')
        end
        % Strip away temporary field
        opt = rmfield(opt, 'min_denominator');
    end
end

% At this point we know:
% - If legacy input or not, and nan_equal and ignore_str are set
% - If tol has been given it is a numeric, and if legacy tol is scalar
if legacy
    if isempty(tol), tol=0; end
    if tol>=0
        opt.tol = [tol,0];
    else
        opt.tol = [min_denominator*abs(tol),abs(tol)];
    end
else
    if isempty(tol) || isequal(tol,0)
        opt.tol = [0,0];
    elseif numel(tol)==2 && all(tol>=0)
        opt.tol = tol;
    else
        error('Check ''tol'' has form [abs_tol, rel_tol] where both are >=0')
    end
end

% Now perform comparison
name_a = inputname(1);
name_b = inputname(2);
if isempty(name_a), name_a = 'Arg1'; end
if isempty(name_b), name_b = 'Arg2'; end
[ok,mess]=equal_to_tol_private(a,b,opt,name_a,name_b);
