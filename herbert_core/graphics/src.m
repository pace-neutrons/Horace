function obj = src(fig)
% Extract the object which is the source of the figure
%
%   >>obj =  src         % get sqw/dnd/IX object attached to current figure
%   >>obj =  src(fig)    %  get sqw/dnd/IX object attached to given figure
%
% Input:
% ------
%   fig         Figure name *OR* figure number *OR* figure handle
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name is '' i.e. the empty string.
%
%             If fig is not given, or is an empty argument apart from an
%              empty character string (which is a valid name, see above),
%              the function returns the figure handle for the current
%              figure, if one exists.


% Determine the figure handle - ensuring there is one and only one figure
% indicated by input argument fig (throws an error if otherwise)
if ~exist('fig', 'var')
    fig_handle = get_figure_handle('-single');  % current figure, if it exists
else
    fig_handle = get_figure_handle(fig, '-single');
end

% get user data
obj = fig_handle.UserData;
if iscell(obj)
    class_name = class(obj{1});
    all_same_class = all(cellfun(@(x)isa(x,class_name),obj));
    if all_same_class
        obj = [obj{:}];
    end
end