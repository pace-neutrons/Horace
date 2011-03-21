function acolor(varargin)
% Change the colour for line and markers
%
% The color can be entered as either the standard one-character 
% Matlab abbreviation or an unambiguous abbreviation of the full
% colour name.
%
% Set a single colour:
%   >> acolor('r')
%   >> acolor('k')      % black
%   >> acolor('re')
%   >> acolor('bla')
%
% Argument can set a sequence of colors for cascade plots e.g.
%   >> acolor('r','b','bla','g')
%   >> acolor({'r','y','k'})        % cell array
%
% The color can be entered as either the one-character MatLab abbreviation:
%            r, g, b, c, m, y, k, w
% or an unambiguous abbreviation of the full colour name:
%            red, green, blue, cyan, magenta, yellow, black, white

% Create vector of colors
narg = length(varargin);

% No argument => display current colour(s)
if narg < 1
    col_type=get_global_var('genieplot','color');
    disp('Current line & marker colours:')
    disp(col_type)
    return
end

col_type =[];
for i = 1:narg
    try
        temp = evalin('caller',varargin{i});
    catch
        temp = varargin{i};
    end
    if iscellstr(temp)
        temp=strtrim(temp);
        col_type = [col_type,temp(:)']; % make argument a row vector
    elseif ischar(temp) && length(size(temp))==2
        temp=strtrim(cellstr(temp));
        col_type = [col_type,temp(:)']; % make argument a row vector
    else
        error ('Check argument type(s)')
    end
end

% Check validity of input arguments
col_brev = {'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'};
col_full = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'white'};
if ~isempty(col_type)
    for i=1:numel(col_type)
        itype = string_find (col_type{i}, col_brev);
        if itype == 0
            itype = string_find (col_type{i}, col_full);
        end
        if itype>0
            col_type{i} = col_brev{itype};
        elseif itype==0
            error ('Invalid color - current value(s) left unchanged')
        elseif itype<0
            error ('Ambiguous abbreviation of color name - current value(s) left unchanged')
        end
    end
    set_global_var('genieplot','color',col_type);
end
