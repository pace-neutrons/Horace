function keep_figure(fig)
% Keep genie_figures with selected name(s) so next plot(s) appear in new window(s)
%
% Keep all genie_figures with the name of the current figure (but only if it is
% a genie_figure):
%
%   >> genie_figure_keep
%
% Keep all genie_figures with the name(s) of figures with selected figure
% name(s), number(s), or handle(s):
%
%   >> genie_figure_keep (fig)
%
% Keep all genie_figures:
%
%   >> genie_figure_keep ('-all')
%
%
% This function only operates on genie_figures, that is, those with the
% 'keep'/'make_cur' menu items.
%
% Synonym for genie_figure_keep. For more details, see the help for that
% function
%
% See also: genie_figure_keep

if nargin==0
    genie_figure_keep
else
    genie_figure_keep(fig)
end
