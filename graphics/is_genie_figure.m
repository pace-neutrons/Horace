function [ok,curr] = is_genie_figure (fig_handle)
% Determine if a figure_handle is one to a genie figure
%
%   >> ok = is_genie_figure (fig_handle)
%
% Input:
% ------
%   fig_handle  Figure handle or array of figure handles (assumed to be valid)
%
% Output:
% -------
%   ok          Logical array with the same size as fig_handle of true
%              where the figure is a genie figure, false where not
%   curr        Logical array with same size as fig_handle, with true for
%              genie figures which are current, flase if kept (or not genie
%              figures)


% The defining qualities are a tag ending '$current$' or '$keep$', and
% the existence of 'Keep' and 'Make_current' uimenus
ok=false(size(fig_handle));
curr=false(size(fig_handle));
for i=1:numel(fig_handle)
    if ~isempty(findobj(fig_handle(i),'Type','uimenu','Tag','keep')) &&...
            ~isempty(findobj(fig_handle(i),'Type','uimenu','Tag','make_cur'))
        fig_name=get(fig_handle(i),'Tag');
        if length(fig_name)>=9 && strcmp(fig_name(end-8:end),'$current$')
            ok(i)=true;
            curr(i)=true;
        elseif length(fig_name)>=6 && strcmp(fig_name(end-5:end),'$keep$')
            ok(i)=true;
        end
    end
end
