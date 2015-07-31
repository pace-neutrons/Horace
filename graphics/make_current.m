function make_current(varargin)
% Make requested figure(s) current for plotting
%
%   >> genie_figure_make_cur        % make the current figure active for plotting
%   >> genie_figure_make_cur(fig)   % make the numbered or named figure(s) active
%   >> genie_figure_make_cur('-all')% make one of each figure name active
%
% Input:
% ------
%   fig         Figure name or cellstr of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
% Only operates on figures created with the keep/make_cur menu items.
% If more than one figure with the same name is provided, then the most
% recently active is made current.


% Synonym for genie_figure_make_cur

if nargin==0
    genie_figure_make_cur
else
    genie_figure_make_cur(fig)
end
