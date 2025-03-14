function varargout = acolor(varargin)
% ACOLOR (alter color): change the colour for line and markers for subsequent plots.
%
% The colour can be entered as either the standard one-character Matlab
% abbreviation or an unambiguous abbreviation of the full colour name. The full
% list of named colours is given below.
% You can also give colours as hexadecimal rgb codes with the form '#rrggbb'
% For example, '#FF0000' is the same as 'red', '#D95319' is 'carrot', or
%'#0F7BBC' (which is not in fact a named colour).
%
% Syntax examples:
%
% Set a single colour: e.g.
%   >> acolor('r')      % red
%   >> acolor('k')      % black (The single character 'k' is black, 'b' is blue.
%                       %        This is a Matlab convention)
%   >> acolor('re')     % red
%   >> acolor('bla')    % black (three characters to distinguish from 'blue')
%   >> acolor('#D95319')% babyblue
%
%   Equivalently, used in command mode:
%   >> acolor red
%   >> acolor bla  
%   >> acolor #D95319
%
% Set a sequence of colours that is repeatedly cycled through for a cascade of
% plots e.g.
%   >> acolor('r', 'b', 'bla', 'g')     % red, blue, black, green
%   >> acolor({'r', 'y', 'k'})          % cell array
%
%   Equivalently:
%   >> acolor  r  b  bla  g
%   >> acolor  r  y  k
%
%
% Matlab also widely uses a palette called 'gem' of nicer colours that it
% doesn't name individually, but which can be accessed here by the names
% 'denim', 'carrot', 'marigold', 'purple', 'grass', 'babyblue', 'brickred':
%
%   >> acolor('d')              % 'denim' (no ambiguity with a single character)
%   >> acolor('mari', 'baby')   % 'marigold' and 'babyblue' (distinguished from
%                               % magneta and blue by several characters)
%
%   A palette name (only 'gem' currently available) sets the sequence defined by
%   the individual colours in the palette:
%   >> acolor('gem')            % equivalent to {'denim','carrot',...'brickred'}
%
%   Equivalently:
%   >> acolor  d
%   >> acolor  mari  baby
%   >> acolor  gem
%
% 
% Display the current colour(s), and all available colours:
%   >> acolor
%
% Return the current colour(s):
%   >> [col, cycle_type] = acolor;  % col: if single colour: character vector;
%                                   %      if more then one colour: cell array
%                                   %      of character vectors.
%                                   % cycle_type: method for cycling through
%                                   %      colours, line styles and markers
%                                   %      (see below for an explanation)
%
%
% Cycling through colours, line styles and markers
% ------------------------------------------------
% When plotting an array of 1D datasets, it can be helpful to have different
% colors and different line styles and marker types to distinguish between
% plots. A set of colors can be set with acolor, and sets of line styles and
% widths, and marker types and sizes, with the functions aline and amark
% respectively.
% Two options are available to cycle through the colors and the line and marker
% properties:
%   >> acolor(..., '-fast') Cycle in order through all the set colors with the
%                           same line and marker properties, before incrementing
%                           each of those properties.
%
%   >> acolor(..., '-with') Increment the color and all the line and marker
%                           properties in together. [Default behaviour]
%
% In both cases, the set of colors and properties are repeatedly cycled through
% until all datasets in the array of 1D datasets have been plotted.
%
%
% Available colours
% -----------------
% The color can be entered as either the one-character Matlab abbreviation:
%           r, g, b, c, m, y, k, w
% or an unambiguous abbreviation of the full colour name:
%           red,  green,  blue,  cyan,  magenta,  yellow,  black,  white
%
% Matlab also widely uses a palette of nicer colours that it doesn't name, but
% which can be accessed here by unambiguous abbreviations of the names
%           denim,  carrot,  marigold,  purple,  grass,  babyblue,  brickred


% Initialise available colour names, palette names and indicies to colorCodes
% ---------------------------------------------------------------------------
[colorCodes, colorNames, colorName_to_colorCode, paletteNames, ...
    paletteColor_to_colorCode] = initialise_colors;


% Resolve input arguments
% -----------------------
% - If acolor is called with function syntax, then we can have either any number
%   of character vectors, or a single cell array of character vectors possibly
%   followed by a single character vector (the 'fast' or 'with' options).
% - If called with command syntax, then all input arguments must be character
%   vectors. We do not allow variable names to be passed, so do not evaluate any
%   of these character vectors in the calling function workspace.

nonEmptyCharVec = @(x)(is_string(x) && ~isempty(deblank(x)));
if nargin>0 && all(cellfun(nonEmptyCharVec, varargin))
    % All input arguments are non-empty character vectors
    args = varargin;
    cycle_type = cycle_option (args{end});
    if ~isempty(cycle_type)
        % Argument was a valid cycle option; strip from the argument list
        args = args(1:end-1);
    end
    
elseif any(nargin==[1,2]) && iscell(varargin{1}) && ~isempty(varargin{1}) && ...
        all(cellfun(nonEmptyCharVec, varargin{1}(:)))
    % Must have been function syntax; check for optional argument
    if nargin==2
        cycle_type = cycle_option (varargin{2});
        if isempty(cycle_type)
            % The argument was not a valid option; throw an error
            error('HERBERT:graphics:invalid_argument', ['The second ', ...
                'argument is not a valid option']);
        end
    end
    args = varargin{1}(:)'; % expand the cell array
    
elseif nargin==0
    args = {};
    cycle_type = '';
    
else
    % There is an input argument but is not consistent with function syntax
    error('HERBERT:graphics:invalid_argument', ['Each input argument ', ...
        'must be a color name or a hexadecimal color code']);
end


% If there are input arguments, set a new current colour or colours
% -----------------------------------------------------------------
if numel(args)>0
    % Determine which elements of args are colour names, and the corresponding
    % index for each into colorNames
    icolor = cellfun(@(x)(stringmatchi(x, colorNames)), args, 'UniformOutput', false);
    iscolor = cellfun(@(x)(isscalar(x)), icolor);
    
    % Determine which elements of args are palette names, and the corresponding
    % index for each into paletteNames
    ipalette = cellfun(@(x)(stringmatchi(x, paletteNames)), args, 'UniformOutput', false);
    ispalette = cellfun(@(x)(isscalar(x)), ipalette);
    
    % Determine which of the elements of args are hexadecimal colour codes
    ishexcol = cellfun(@(x)(ishexcolor(x)), args);
    
    if ~all(iscolor + ispalette + ishexcol == 1)
        error('HERBERT:graphics:invalid_argument', ['Each input argument ', ...
            'must be a color name or a hexadecimal color code']);
    end
    
    % Expand palettes into a vector of indices into colorCodes
    indCode = cell(1, numel(args));
    indCode(iscolor) = cellfun(@(x)(colorName_to_colorCode(x)), ...
        icolor(iscolor), 'UniformOutput', false);
    indCode(ispalette) = cellfun(@(x)(paletteColor_to_colorCode{x}), ...
        ipalette(ispalette), 'UniformOutput', false); 
    indCode(ishexcol) = {0};    % 0 indicates no reference into colorCode
    
    % Resolve colorCode indices into the primary (single character) colour codes
    % or in the case of colour names and palettes into their hexadecimal color
    % codes. Keep explicit hexadecimal codes that do not have colour names.
    indCode = cell2mat(indCode);
    current_colors = cell(1,numel(indCode));
    current_colors(indCode>0) = colorCodes(indCode(indCode>0));
    current_colors(indCode==0) = args(ishexcol);
    
    % Store the cell array of colour codes and hexadecimal codes in the geniplot
    % configuration
    genieplot.set('colors', current_colors);
end

if ~isempty(cycle_type)
    genieplot.set('color_cycle', cycle_type);
end


% Query the current colours if there are no input arguments or there is an
% output argument
% ---------------
if nargin==0 || nargout>0
    % The current colors are held as the single character primary colour codes
    % or hexadecimal codes in the genieplot singleton. Substitute codes with
    % colour names where possible
    current_colors = genieplot.get('colors');
    [Lin, Loc] = ismember(current_colors, colorCodes);
    colorCodes_of_colorNames = colorCodes(colorName_to_colorCode);
    [~, Loc] = ismember(colorCodes(Loc(Lin)), colorCodes_of_colorNames);
    current_colors(Lin) = colorNames(Loc);
    cycle_type = genieplot.get('color_cycle');
    
    if nargout==0
        % Display current colours and the available colour names
        disp('Current color sequence:')
        disp(strjoin(current_colors, ', '))
        if numel(current_colors)>1
            if strcmp(cycle_type, 'with')
                disp('[Colors cycle with line and marker properties]')
            else
                disp('[Colors cycle in full before line and marker properties increment]')
            end
        end
        disp(' ')
        disp('Available color names:')
        disp(strjoin(colorNames, ', '))
        disp(' ')
        disp('Available palettes:')
        disp(strjoin(paletteNames, ', '))
        disp(' ')
    else
        % Return the current colours
        if numel(current_colors)==1
            varargout{1} = current_colors{1};   % return as character vector
        else
            varargout{1} = current_colors;
        end
        if nargout>=2
            varargout{2} = cycle_type;
        end
    end
end


%-------------------------------------------------------------------------------
function [colorCodes, colorNames, colorName_to_colorCode, paletteNames, ...
    paletteColor_to_colorCode] = initialise_colors
% Return the valid colour and palette names, and indicies into colour codes
%
%   colorCodes      Cell array (row) of the eight primary Matlab colour codes
%                   and the hexadecimal codes of all the colours in the
%                   available palettes.
% 
%   colorNames      Cell array (row) of the full names of the eight primary
%                   Matlab colours and of the colours in the available palettes.
%                   The character strings must be unique, even though two names
%                   might refer to the same colorCode (e.g. 'red' and 'r').
%
%   colorName_to_colorCode      Indices in colorCodes corresponding to the names
%                   in colorNames.
%
%   paletteNames    Cell array (row) of palettes, that is, the names of
%                   collections of a series colors.
%
%   paletteColor_to_colorCode   Cell array of arrays of indices into colorCodes,
%                   one array for each palette, corresponding to the colour
%                   names in the palettes.


% The algorithm *requires* that every element of colorNames is matched to an
% element in colorCodes
colorCodes = {'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w', ...
    '#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};

colorNames = {...
    'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'white', ...
    'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w', ...
    'denim', 'carrot', 'marigold', 'purple', 'grass', 'babyblue', 'brickred'};
colorName_to_colorCode = [1:8, 1:8, 9:15];    % indices into colorCodes

% Available palette names and the indices of the individual palette colours into
% colorCodes
paletteNames = {'gem'};             % cell array of palette namaes
paletteColor_to_colorCode = {9:15}; % cell array of index arrays into colorCode

% Developer help: the algorithm in this function require that the concatenation
% of colorNames and paletteNames contains unique members. It is easy to make a
% mistake, so explicitly check here.
allNames = [colorNames, paletteNames];
if numel(unique(lower(allNames))) ~= numel(allNames)
    error('HERBERT:graphics:runtime_error', ['Design error: ', ...
        'non-unique reference colour names. Please inform the developers.']);
end


%-------------------------------------------------------------------------------
function cycle_type = cycle_option (arg)
% Determine if an argument is a valid colour cycle option
%
%   >> cycle_type = cycle_option (arg)
%
% Input:
% ------
%   arg         Argument to be tested.
%
% Output:
% -------
%   cycle_type  If arg was one of '-fast' or '-with', cycle_type is returned as
%               'fast' or 'with' respectively. Otherwise cycle_type is empty.

cycle_type = '';    % assume the worst
if is_string(arg)
    if strcmpi(arg, '-fast')
        cycle_type = 'fast';
    elseif strcmpi(arg, '-with')
        cycle_type = 'with';
    end
end
        

%-------------------------------------------------------------------------------
function status = ishexcolor(str)
% Determine is a character vectors has the form '#rrggbb' with each character
% pair being a hexadecimal in the range 0 to 255
if is_string(str) && numel(str)==7 && str(1:1)=='#'
    try
        R = hex2dec(str(2:3));
        G = hex2dec(str(4:5));
        B = hex2dec(str(6:7));
        if all([R,G,B]>=0 & [R,G,B]<=255)
            status = true;
        end
    catch
        status = false;
    end
    return
end
status = false;
