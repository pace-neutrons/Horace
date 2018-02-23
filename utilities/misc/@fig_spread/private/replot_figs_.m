function self = replot_figs_(self,varargin)
% plot figures again ignoring missing (deleted) figures and
% placing subsequent figures one after another,
% (possibly using new pictures sizes)
%
% $Revision$ ($Date$)
%
size = self.fig_size;
if verLessThan('matlab','8.4')
    figure_exist = @(x)ishandle(x);
else
    figure_exist = @(x)isvalid(x);    
end
n_shown = 0;
for i=1:self.fig_count_
    fig_h = self.fig_list_{i};
    if figure_exist(fig_h)
        n_shown  = n_shown +1;
        [ix,iy,~] = self.calc_fig_pos(n_shown  ,size(1),size(2));
        set(fig_h, 'Position', [ix iy, size(1),size(2)])
        set(fig_h,'Visible','on')
        % rise the image
        rize_figure_(fig_h);
    end
end
self.n_hidden_fig_ = 0;
