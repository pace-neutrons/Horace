function make_current(varargin)
% Set genie_figure(s) active for plotting
%
% If the current figure is a genie_figure, make it the active genie_figure:
%
%   >> genie_figure_make_cur
%
% Make one genie_figure active for each of the name(s) of figures with selected
% figure name(s), number(s), or handle(s), if there is one available:
%
%   >> genie_figure_make_cur (fig)
%
% Make one of each genie_figure name active, if there is one available:
%
%   >> genie_figure_make_cur ('-all')
%
%
% This function only operates on genie_figures, that is, those with the
% 'keep'/'make_cur' menu items.
%
% Synonym for genie_figure_make_cur. For more details, see the help for that
% function
%
% See also: genie_figure_make_cur


if nargin==0
    genie_figure_make_cur
else
    genie_figure_make_cur(varargin{:})
end
