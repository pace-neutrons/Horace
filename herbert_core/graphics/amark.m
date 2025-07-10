function varargout = amark(varargin)
% AMARK (alter mark): Change the marker type and size for subsequent plots.
% - There are a number of marker type that can be set acoording to their symbol
%   type or in some cases their named equivalents - see below for full list.
%   [Default: 'o'  (circle)]
% - Marker sizes are in points. [Default: 6]
%
% Note: if you only set marker type(s) then the current marker size(s) are left
% unchanged, and vice versa.
%
% Syntax examples:
%	>> amark(6)         % set marker size to 6 points
%   >> amark('+')       % set marker type to '+' sign
%	>> amark(10,'p')    % set marker size to 10 , and marker type to pentagram
%	>> amark('p',10)    % The same (the order of arguments doesn't matter)
%
%   Equivalently, used in command mode:
%   >> amark  6
%   >> amark  p         % set marker type to pentagram
%   >> amark  +         % set marker type to plus (also see below)
%   >> amark  10  p
%   >> amark  p  10
%   but note:
%   >> amark  '+' 10    % Must use quotation marks for
%                       %   '+'   '*'   '^'   '>'   '<'   '|'
%                       % because if they are followed by further characters, 
%                       % the command can be ambiguous. For eaxmple,
%                       %       amark + 10
%                       % is a valid arithmetic expression and is interpreted
%                       % as such by the Matlab parser.
%
% Set a sequence of marker types and/or sizes that is repeatedly cycled
% through for a cascade of plots e.g.
%   >> amark(5, 10, 'x', 'o', 'p')      % Size repeats 5, 10, 5, 10, ...
%                                       % Type repeats 'x','o','p','x','o','p'...
%   >> amark({'v','p'}, 5:15)           % Example with a cell array of marker types
%                                       % and implicit array of sizes
%   Equivalently:
%   >> amark  5  10  x  o  p
%   >> amark  v  p  5:15                % (note:a cell array is not readable in
%                                       %  command mode)
%   
% Display the current values:
%   >> amark
%
% Return the current values:
%   >> [msize, mtype] = amark;
%
%
% Valid marker types:
% -------------------
%   'o'               Circle
%   '+'               Plus sign
%   '*'               Asterisk
%   '.'               Point
%   'x'               Cross
%   '_'               Horizontal line (Matlab 2020b and later only)
%   '|'               Vertical line   (Matlab 2020b and later only)
%   's' or 'square'   Square
%   'd' or 'diamond'  Diamond
%   '^'               Upward-pointing triangle
%   'v'               Downward-pointing triangle
%   '>'               Right-pointing triangle
%   '<'               Left-pointing triangle
%   'p' or 'pentagram'    Five-pointed star (pentagram)
%   'h' or 'hexagram'     Six-pointed star (hexagram)


% Valid style names accepted by this function, and their matching matlab style
% codes, which are also accepted.
% (The single letter codes are unambiguous abbreviations of the full names, so a
% separate array of codes is not needed)
if verLessThan('MATLAB','9.9')  % prior to R2020b
    marker_type_names = {'o','+','*','.','x','square','diamond', ...
        '^','v','>','<','pentagram','hexagram'};
else
    marker_type_names = {'o','+','*','.','x','_','|','square','diamond', ...
        '^','v','>','<','pentagram','hexagram'};
end


% If there are input arguments, set new marker type(s) and/or marker size(s)
% --------------------------------------------------------------------------
if nargin>0
    % Parse input arguments
    vals = cellfun(@(x)parse_function_syntax(x, marker_type_names), ...
        varargin, 'UniformOutput', false);
    if any(cellfun(@isempty, vals))
        % Not every argument is valid, so might have been called in command mode (in
        % which case e.g. the string '4' would be valid)
        vals = cellfun(@(x)parse_command_syntax(x, marker_type_names), ...
            varargin, 'UniformOutput', false);
        if any(cellfun(@isempty, vals))
            error('HERBERT:graphics:invalid_argument', ['One or more input ', ...
                'arguments could not be resolved as valid marker type(s) ',...
                'or marker size(s)']);
        end
    end
    
    % Collect all numeric values as marker sizes, and update the stored marker
    % sizes if any were given
    is_size = cellfun(@isnumeric, vals);
    tmp = vals(is_size);
    if ~isempty(tmp)
        marker_sizes = cat(2, tmp{:});          % single row vector
        marker_sizes(marker_sizes==0) = 0.001;  % select smallest size (0.001 pixels)
        genieplot.set('marker_sizes', marker_sizes);
    end
    
    % Collect all other values (they are non-empty row cell arrays, including
    % scalars), and substitute names of marker types with the corresponding codes;
    % update stored marker types if any were given.
    tmp = vals(~is_size);
    if ~isempty(tmp)
        marker_types = lower(cat(2, tmp{:}));    % single row vector, lower case
        marker_types = cellfun(@(x)(x(1:1)), marker_types, ...
            'UniformOutput', false); % keep first characters only
        genieplot.set('marker_types', marker_types);
    end
end


% Query the current marker types and marker sizes if there are no input arguments
% or there is an output argument
% ------------------------------
if nargin==0 || nargout>0
    marker_sizes = genieplot.get('marker_sizes');
    marker_types = genieplot.get('marker_types');
    if nargout==0
        % Display the current marker types and sizes
        disp('Current marker_type(s):')
        disp(['   ''', strjoin(marker_types, '''  '''), ''''])
        disp('Current marker_size(s):')
        disp(marker_sizes)
        % Display the available marker types
        disp('Available marker_types:')
        marker_types_available = cellfun(@(x)(x(1:1)), marker_type_names, ...
            'UniformOutput', false);
        disp(['   ''', strjoin(marker_types_available, '''  '''), ''''])
    else
        % Return the current marker types and marker sizes
        varargout{1} = marker_sizes;
        if nargout>=2
            if isscalar(marker_types)
                varargout{2} = marker_types{1};
            else
                varargout{2} = marker_types;
            end
        end
    end
end


%-------------------------------------------------------------------------------
function val = parse_function_syntax (arg, str)
% Determine if an argument is non-empty and is one of:
% - An array of non-negative reals.
% - A character vector that matches one and only one of a cell array of
%   character vectors, or if not, is an unambiguous abbreviation of one of them.
% - A cell array of non-empty character vectors each of which matches one and
%   only one of a cell array of character vectors, or if not, is an unambiguous
%   abbreviation of one of them.
%
% Input:
% ------
%   arg     Argument to be validated
%           Can be a numeric array, a character vector, or a cell array of
%           character vectors
%   str     Row cell array (assumed non-empty) of valid character vectors (all
%           assumed non-empty)
%
% Output:
% -------
%   val     If arg was valid:
%           - row vector of non-negative reals, or
%           - row cell array of character vectors, all of which are members of
%             input argument str
%           If not valid:
%           - set to []

nonEmptyCharVec = @(x)(is_string(x) && ~isempty(deblank(x)));

if ~isempty(arg) && isnumeric(arg) && isreal(arg) && all(isfinite(arg)) && ...
        all(arg(:)>=0)
    val = arg(:)';  % make val a row vector
elseif nonEmptyCharVec(arg)
    arg = deblank(arg);
    ind = stringmatchi (arg, str);
    if isscalar(ind)
        val = str(ind);
    else
        val = [];
    end
elseif ~isempty(arg) && iscell(arg) && all(cellfun(nonEmptyCharVec, arg(:)))
    arg = deblank(arg);
    ind = cellfun(@(x)(stringmatchi(x, str)), arg(:)', 'UniformOutput', false);
    ok = cellfun(@isscalar, ind);
    if all(ok)
        ind = cat(2, ind{:});   % make ind a row vector
        val = str(ind);
    else
        val = [];
    end
else
    val = [];
end

%-------------------------------------------------------------------------------
function val = parse_command_syntax (arg, str)
% Determine if a character vector is non-empty and can be parsed as one of:
% - An array of non-negative reals.
% - A character vector that matches one and only one of a cell array of
%   character vectors, or if not, is an unambiguous abbreviation of one of them.
% - A cell array of non-empty character vectors each of which matches one and
%   only one of a cell array of character vectors, or if not, is an unambiguous
%   abbreviation of one of them.


% non-negative reals; if not, determine if it matches one of a cell array of
% character strings.
%
% Input:
% ------
%   arg     Character vector to be validated
%   str     Cell array (assumed non-empty) of valid character vectors (all
%           assumed non-empty)
%
% Output:
% -------
%   val     If arg was valid:
%           - row vector of non-negative reals, or
%           - cell array with the single character vector that was found in
%             input argument str
%           If not valid:
%           - set to []

nonEmptyCharVec = @(x)(is_string(x) && ~isempty(deblank(x)));

val = [];   % assume the worst
if nonEmptyCharVec(arg)
    arg = deblank(arg);
    [val, ok] = str2num(arg);  % do not str2double, as need to be able to read arrays
    if ok
        if isreal(val) && all(isfinite(val(:))) && all(val(:)>=0)
            val = val(:)';  % make val a row vector
        end
    else
        ind = stringmatchi (arg, str);
        if isscalar(ind)
            val = str(ind);
        end
    end
end
