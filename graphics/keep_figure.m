function keep_figure(fig)
% Keep figure(s) so next plot appears in a new window
%
%   >> keep_figure          % keep the current figure
%   >> keep_figure(fig)     % keep the numbered or named figures
%   >> keep_figure('-all')  % keep all figures
%
% Input:
% ------
%   fig         Figure name or cellstr of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
% Only operates on figures created with the keep/make_cur menu items.


% Synonym for genie_figure_keep

if nargin==0
    genie_figure_keep
else
    genie_figure_keep(fig)
end
