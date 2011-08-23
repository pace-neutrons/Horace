function [fig_name, ok, mess] = genie_figure_name(handle)
% Return name(s) of figure(s)
%
%   >> fig_name=genie_figure_handle (fig_handle)
%
%   fig_handle  Figure handle or cellstr of figure handles
%
%   fig_name    Cell array of names of any figures with names that match one of the input names
%   ok          True if all OK, false otherwise
%   mess        '' if OK, error message if not OK
%
%  If given figure name(s) rather than handle(s), then these are passed through
%  transparently (apart from conversion to column vector) unless one or more
%  of the names is not a figure name, in which case an error is thrown.

if isnumeric(handle)   % could be array of figure handles
    id=handle(:);
    id=id(ishandle(id));
    id=findobj(id,'type','figure');     % keep only those handles that are to figures
    fig_name=cell(size(id));
    for i=1:numel(id)
        fig_name{i}=get(id(i),'Name');
    end
    ok=true; mess=''; return
    
elseif ischar(handle) || iscellstr(handle)
    if ischar(handle) && numel(size(handle))==2
        handle=cellstr(handle);
    elseif ~iscellstr(handle)
        fig_name={}; ok=false; mess='Check validity of figure name(s)'; return
    end
    fig_name=strtrim(handle(:)); % trim leading and training blanks
    for i=1:numel(fig_name)
        if isempty(findobj('name',fig_name{i},'type','figure'))
            fig_name={}; ok=false; mess='Check validity of figure name(s)'; return
        end
    end
    ok=true; mess=''; return
    
else
    fig_name={}; ok=false; mess='Check validity of figure handle(s)'; return
end
