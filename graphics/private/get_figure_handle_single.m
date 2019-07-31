function [fig_handle, ok, mess] = get_figure_handle_single (fig)
% Get the figure handle of a single figure
%
%   >> [fig_handle, ok, mess] = get_figure_handle_single    % current figure
%   >> [fig_handle, ok, mess] = get_figure_handle_single (fig)
%
% Input:
% ------
%   fig         Figure name *OR* figure number *OR* figure handle.
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name will be '' i.e. the empty string.
%
%               If fig is not given, or an empty argument apart from a
%              character string, returns figure handle for the current
%              figure, if one exists.
%
%               Normally fig would contain a single character string, or
%              scalar figure number or handle. However, you can give a
%              cell array of names, or array of nmbers or handles; these
%              sre effectivelly search options from which to find a single
%              instance. Likewise, note that there could be more than one
%              figure with the same name, which will then return an error.
%
% Output:
% -------
%   fig_handle  Figure handle
%   ok          True if one and only one figure was found; false otherwise
%   mess        Empty string if OK==true; error message if OK==false.


if nargin==0 || (isempty(fig) && ~is_string(fig))
    % Catch case of no input
    if isempty(findobj(0,'Type','figure'))
        [fig_handle,ok,mess]=error_return('No current figure exists');
    else
        fig_handle=gcf;
        ok=true;
        mess='';
    end
else
    [fig_handle,ok,mess]=get_figure_handle(fig);
    if ok
        if isempty(fig_handle)
            [fig_handle,ok,mess]=error_return...
                ('No figure with given name(s), figure handle(s) or figure number(s)');
        elseif numel(fig_handle)>1
            [fig_handle,ok,mess]=error_return...
                ('More than one figure with given name(s), figure handle(s) or figure number(s)');
        end
    end
end

%--------------------------------------------------------------------------------------------------
function [fig_handle,ok,mess]=error_return(mess)
% Standard return arguments
fig_handle=empty_default_graphics_object();
ok=false;
