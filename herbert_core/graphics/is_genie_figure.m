function [ok, is_current, name] = is_genie_figure (fig_handle)
% Determine if figure handle(s) correspond to genie_figure(s)
%
%   >> [ok, is_current, name] = is_genie_figure (fig_handle)
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
%   is_current   Logical array with same size as fig_handle
%               - true for genie figures which have 'current' status;
%               - false for genie figures that have 'keep' status, or figures
%                 that are not genie figures
%
%   name        Name(s) of the plot(s)
%               - If a single figure handle, then a character vector, and
%                 if the name is empty, has the value ''
%               - Otherwise, a cell array with the same size as fig_handle,
%                 with elements '' if the name is empty 
%
% Evaluate the following to determine which genie_figures are 'keep' status:
%   keep = (ok & ~is_current)


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
% presence of the uimenus alone is not sufficient as the visualisation
% application mslice also has those uimenus.
%
% The name is found by extracting from the figure property 'Tag', rather than
% from the figure property Name. This is because it is possible to inadvertently
% break synchronisation, whereas the Tag is core defining property to give the
% functionality of genie_windows.


ok = false(size(fig_handle));
is_current = false(size(fig_handle));
name = repmat({''}, size(fig_handle));

for i=1:numel(fig_handle)
    if ~isempty(findobj(fig_handle(i), 'Type', 'uimenu', 'Tag', 'keep')) &&...
            ~isempty(findobj(fig_handle(i),'Type', 'uimenu', 'Tag', 'make_cur'))
        fig_tag = get(fig_handle(i), 'Tag');
        if is_string(fig_tag)
            nchar = numel(fig_tag);
            if nchar >= 9 && strcmp(fig_tag(end-8:end), '$current$')
                % Figure is a genie_figure with 'current' status
                ok(i) = true;
                is_current(i) = true;
                if nchar > 9
                    name{i} = fig_tag(1:end-9);
                end
            elseif nchar >= 6 && strcmp(fig_tag(end-5:end), '$keep$')
                % Figure is a genie_figure with 'keep' status
                ok(i) = true;
                if nchar > 6
                    name{i} = fig_tag(1:end-6);
                end
            else
                % Not a genie_figure; get the name from the property Name
                name = fig_handle(i).Name;
            end
        end
    end
end

if numel(fig_handle)==1
    name = name{1};     % single name, so extract from a cell array
end
