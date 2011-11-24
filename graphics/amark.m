function amark(varargin)
% Change the marker type and size
%
% Syntax examples:
%	>> amark(6)
%	>> amark(10,'+')
%   >> amark('+')
%	>> amark('+',10)    *** NOT VALID IN COMMAND LINE MODE
%
% Arguments can set a sequence of type and/or size for cascade plots e.g.
%   >> amark (13,14,'+','*','.')
%   >> amark ({'v','p'},5:15)       % example with a cell array
%
% Valid marker types:
%     '+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'
%                               |    |    |  triangles   |    |    |
%                               |    |                        |    |
%                      square --|    |       5-pointed star --|    |
%                      diamond ------|       6-pointed star -------|
%
%
% Size of markers is in points (default size is 6)

% Create two row vectors, of marker sizes and marker types:
narg = length(varargin);

% Display current marker size and type if no arguments given
if narg < 1
    %marker_size=get_global_var('genieplot','marker_size');
    %marker_type=get_global_var('genieplot','marker_type');
    [marker_size,marker_type]=get(graph_config,'marker_size','marker_type');	
    disp('Current marker size(s) and type(s):')
    disp(marker_size)
    disp(marker_type)
    return
end

marker_size = [];
marker_type =[];
for i = 1:narg
    try
        temp = evalin('caller',varargin{i});
    catch
        temp = varargin{i};
    end
    if isnumeric(temp) && isvector(temp)
        marker_size = [marker_size,temp(:)'];   % make argument a row vector
    elseif iscellstr(temp)
        temp=strtrim(temp);
        marker_type = [marker_type,temp(:)'];   % make argument a row vector
    elseif ischar(temp) && length(size(temp))==2
        temp=strtrim(cellstr(temp));
        marker_type = [marker_type,temp(:)'];   % make argument a row vector
    else
        error ('Check argument type(s)')
    end
end

% Check validity of input arguments
if ~isempty(marker_size)
    if min(marker_size) >= 0.1 && max(marker_size) <= 50
        %set_global_var('genieplot','marker_size',marker_size);
		set(graph_config,'marker_size',marker_size);
    else
        error ('Marker size is too small or too large - left unchanged (amark)')
    end
end

markers = {'+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};
if ~isempty(marker_type)
    for i=1:length(marker_type)
        itype = string_find (marker_type{i}, markers);
        if itype==0
            error ('Invalid marker type - left unchanged (amark)')
        elseif itype<0
            error ('Ambiguous abbreviation of marker type - left unchanged (amark)')
        end
    end
    %set_global_var('genieplot','marker_type',marker_type);
    set(graph_config,'marker_type',marker_type);	
end
