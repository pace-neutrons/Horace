function [ok, current] = is_genie_figure (fig_handle)
% Determine if figure handle(s) correspond to genie_figure(s)
%
%   >> [ok, current] = is_genie_figure (fig_handle)
%
% Input:
% ------
%   fig_handle  Figure handle or array of figure handles
%
% Output:
% -------
%   ok          Logical array with the same size as fig_handle:
%               - true where the figure is a genie figure;
%               - false where not.
%
%   current     Logical array with same size as fig_handle
%               - true for genie figures which have 'current' status;
%               - false for genie figures that have 'keep' status, or figures
%                 that are not genie figures
%
% Evaluate the following to determine which genie_figures are 'keep' status:
%   keep = (ok & ~current)


% Technical details about genie_figures
% -------------------------------------
% A genie window will always have the following:
% - Property Tag with the value '<name>$current$' or '<name>$keep$', where
%   <name> is the value of the figure property Name (and which is the displayed
%   name of the plot following the figure number).
% - A uimenu with the tag 'make_cur' and one with tag 'keep'.
% - One of these uimenus will have property Enable set to 'on', the other will
%   have the property Enable set to 'off', according to the figure tag being
%   '<name>$current$' or '<name>$keep$'.
%
% To detect if a figure is a genie_figure the defining quality to be tested for
% is the presence of one of the tags '<name>$current$' and '<name>$keep$'. The
% presence of the uimenus alone is not sufficient as the visulaisation
% application mslice also has those uimenus.


ok = false(size(fig_handle));
current = false(size(fig_handle));

for i=1:numel(fig_handle)
    if ~isempty(findobj(fig_handle(i), 'Type', 'uimenu', 'Tag', 'keep')) &&...
            ~isempty(findobj(fig_handle(i),'Type', 'uimenu', 'Tag', 'make_cur'))
        fig_tag = get(fig_handle(i), 'Tag');
        if length(fig_tag) >= 9 && strcmp(fig_tag(end-8:end), '$current$')
            ok(i) = true;
            current(i) = true;
        elseif length(fig_tag) >= 6 && strcmp(fig_tag(end-5:end), '$keep$')
            ok(i) = true;
        end
    end
end
