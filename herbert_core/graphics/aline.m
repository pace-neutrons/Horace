function varargout = aline(varargin)
% Change the line type and width for following plots
%
% Syntax examples:
%	>> aline(2)
%	>> aline(0.5,':')
%   >> aline('-.')
%	>> aline('-',10)
%
%   >> aline                        % displays the current value(s)
%   >> [lwidth, lstyle] = aline     % returns the current value(s)
%
% Arguments can set a sequence of type and/or size for cascade plots e.g.
%   >> aline (1,2,':','-','-.')     % Linewidth repeats 1,2,1,2,...
%                                   % Type repeats ':','-','-.'':','-','-.'...
%   >> aline ({'dot','sol'},1:0.5:4)% Example with a cell array of line types
%                                   % and implicit array of linewidths
%
% Valid line types: type either the Matlab code or text equivalent
% (only the minimum unambiguous abbreviation is necessary)
%        '-'      solid
%        '--'     dashed
%        ':'      dotted
%        '-.'     ddot (dashed-dot)
%
% Line width is in points (default size is 0.5)

% Create two row vectors, of line widths and line styles:
narg = length(varargin);

% No argument => display current colour(s)
if narg < 1
    line_width=get_global_var('genieplot','line_width');
    line_style=get_global_var('genieplot','line_style');
    if nargout==0
        disp('Current line width(s) and style(s):')
        disp(line_width)
        disp(line_style)
    else
        if nargout>=1, varargout{1}=line_width; end
        if nargout>=2
            if numel(line_style)==1
                varargout{2}=line_style{1};
            else
                varargout{2}=line_style;
            end
        end
        if nargout>2, error('Check number of output arguments'); end
    end
    return
end

line_width = [];
line_style =[];
for i = 1:narg
    try
        temp = evalin('caller',varargin{i});
    catch
        temp = varargin{i};
    end
    if isnumeric(temp) && isvector(temp)
        line_width = [line_width,temp(:)']; % make argument a row vector
    elseif iscellstr(temp)
        temp=strtrim(temp);
        line_style = [line_style,temp(:)'];   % make argument a row vector
    elseif ischar(temp) && length(size(temp))==2
        temp=strtrim(cellstr(temp));
        line_style = [line_style,temp(:)'];   % make argument a row vector
    else
        error ('Check argument type(s)')
    end
end

% Check validity of input arguments
if ~isempty(line_width)
    if min(line_width) >= 0.1 && max(line_width) <= 50
        set_global_var('genieplot','line_width',line_width);
    else
        error ('Line width(s) too small or too large - current value(s) left unchanged')
    end
end

lstyle_char = {'-','--',':','-.'};
lstyle_name = {'solid','dashed','dotted','ddot'};
if ~isempty(line_style)
    for i=1:length(line_style)
        itype = stringmatchi (line_style{i}, lstyle_char);
        if isempty(itype)
            itype = stringmatchi (line_style{i}, lstyle_name);
        end
        if isempty(itype)
            error ('Invalid line style - left unchanged (aline)')
        elseif numel(itype)>1
            error ('Ambiguous abbreviation of line style - left unchanged (aline)')
        else
            line_style{i} = lstyle_char{itype};
        end
    end
    set_global_var('genieplot','line_style',line_style);
end
