function fig_num = get_figure_number (fig_handle)
% Get the figure number(s) for a figure handle or array of figure handles
%
%   >> val = get_figure_number(fig_handle)
%
% Input:
% ------
%   fig_handle  Figure handle, or array of figure handles
%
% Output:
% -------
%   val         Corresponding figure number(s)
%
% Need to have this because get(h,'Number') returns property 'NumberTitle'
% in the old-type graphics. In the new-style graphics it returns the figure
% number, but any abbreviation of 'Number' returns 'NumberTitle'.


if verLessThan('matlab','8.4')
    fig_num=fig_handle;
else
    fig_num=zeros(size(fig_handle));
    for i=1:numel(fig_handle)
        fig_num(i)=get(fig_handle(i),'Number');
    end
end
