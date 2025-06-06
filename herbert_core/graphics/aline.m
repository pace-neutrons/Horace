function varargout = aline(varargin)
% ALINE (alter line): change the line style and width for subsequent plots.
% - The available line styles are: '-',  '--',  ':',  '-.' (Default: '-')
%     or their namedequivalents: 'solid' 'dashed' 'dotted' 'ddot' (i.e. dash-dot)
% - Line widths are in points (Default: 0.5). If set to 0, then will be set to
%   thinnest supported line.
%
% Note: if you only set line width(s), then the current line style(s) are left
% unchanged, and vice versa.
%
% Syntax examples:
%	>> aline(2)             % set line width to 2 points
%   >> aline('-.')          % set line style to dash-dot
%	>> aline(0.5, 'ddot')   % set line width to 0.5, and line style to dash-dot
%	>> aline('ddot', 0.5)   % The same (the order of arguments doesn't matter)
%	>> aline('-.', 0.5)     % Can use linestyle code or name 
%
%   Equivalently, used in command mode:
%   >> aline  2
%   >> aline  -.            % set line style to dash-dot
%   >> aline  :             % set line style to dot (also see below)
%   >> aline  0.5  ddot
%   >> aline  ddot  0.5      
%   >> aline  -.   0.5
%   but note:
%   >> aline  ':'   0.5     % Must use quotation marks for ':' and '-' because
%                           % if they are followed by further characters, the 
%                           % command can be ambiguous. For example, 
%                           %       aline - 0.5
%                           % is a valid arithmetic expression and is
%                           % interpreted as such by the Matlab parser
%
% Set a sequence of line style and/or line width that is repeatedly cycled
% through for a cascade of plots e.g.
%   >> aline(1, 2, '--', '-', '-.')     % Linewidth repeats 1,2,1,2,...
%                                       % Type repeats ':','-','-.'':','-','-.'...
%   >> aline({'dot','sol'}, 1:0.5:4)    % Example with a cell array of line types
%                                       % and implicit array of linewidths
%   Equivalently:
%   >> aline  1  2  --  -  -.
%   >> aline  dot  sol  1:0.5:4         % (note:a cell array is not readable in
%                                       %  command mode)
%
% Display the current values:
%   >> aline
%
% Return the current values:
%   >> [lwidth, lstyle] = aline;    % lwidth is a row vector
%                                   % lstyle is a character vector if a single
%                                   % style; a cell array if more than one
%
%
% Available line styles:
% ----------------------
% The Matlab code or text equivalent (only the minimum unambiguous abbreviation
% is necessary):
%        '-'      solid [Default]
%        '--'     dashed
%        ':'      dotted
%        '-.'     ddot (dashed-dot)
%
% Line width is in points (Default: 0.5)


% Valid style names accepted by this function, and their matching matlab style
% codes, which are also accepted.
line_style_names = {'solid','dashed','dotted','ddot'};
line_style_codes = {'-',    '--',    ':',    '-.'};


% If there are input arguments, set new line style(s) and/or line width(s)
% ------------------------------------------------------------------------
if nargin>0
    % Parse input arguments
    vals = cellfun(@(x)parse_function_syntax(x, [line_style_names, line_style_codes]), ...
        varargin, 'UniformOutput', false);
    if any(cellfun(@isempty, vals))
        % Not every argument is valid, so might have been called in command mode (in
        % which case e.g. the string '4' would be valid)
        vals = cellfun(@(x)parse_command_syntax(x, [line_style_names, line_style_codes]), ...
            varargin, 'UniformOutput', false);
        if any(cellfun(@isempty, vals))
            error('HERBERT:graphics:invalid_argument', ['One or more input ', ...
                'arguments could not be resolved as valid linewidth(s) or linestyle(s)']);
        end
    end
    
    % Collect all numeric values as linewidths, and update the stored line
    % widths if any were given
    is_width = cellfun(@isnumeric, vals);
    tmp = vals(is_width);
    if ~isempty(tmp)
        line_widths = cat(2, tmp{:});           % single row vector
        line_widths(line_widths==0) = 0.001;    % select thinnest line (0.001 pixels)
        genieplot.set('line_widths', line_widths);
    end
    
    % Collect all other values (they are non-empty row cell arrays, including
    % scalars), and substitute names of linestyles with the corresponding codes;
    % update stored line styles if any were given.
    tmp = vals(~is_width);
    if ~isempty(tmp)
        line_styles = lower(cat(2, tmp{:}));    % single row vector, lower case
        [Lin, Loc] = ismember(line_styles, line_style_names);
        line_styles(Lin) = line_style_codes(Loc(Lin));
        genieplot.set('line_styles', line_styles);
    end
end


% Query the current line styles and line widths if there are no input arguments
% or there is an output argument
% ------------------------------
if nargin==0 || nargout>0
    line_widths = genieplot.get('line_widths');
    line_styles = genieplot.get('line_styles');
    if nargout==0
        % Display the current line width(s) and line style(s)
        disp('Current line style(s):')
        disp(['   ''', strjoin(line_styles, ''',   '), ''''])
        disp('Current line width(s):')
        disp(line_widths)
    else
        % Return the current line width(s) and line style(s)
        varargout{1} = line_widths;
        if nargout>=2
            if isscalar(line_styles)
                varargout{2} = line_styles{1};
            else
                varargout{2} = line_styles;
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
