function self = replot_figs_(self,varargin)
% plot figures again ignoring missing (deleted) figures and
% placing subsequent figures one after another,
% (possibly using new pictures sizes)
size = self.fig_size;
n_shown = 0;
for i=1:self.fig_count_
    fig_h = self.fig_list_{i};
    if isvalid(fig_h)        
        n_shown  = n_shown +1;
        [ix,iy,~] = self.calc_fig_pos(n_shown  ,size(1),size(2));
        set(fig_h, 'Position', [ix iy, size(1),size(2)])
        set(fig_h,'Visible','on')
    end
end
self.n_hidden_fig_ = 0;
