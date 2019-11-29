function self = check_and_show_n_figs_(self,varargin)
% Shows specified number of hidden pictures
%
%   Detailed explanation goes here

[ok,mess,raise,force,argi] = parse_char_options(varargin,{'-raise','-force'});
if ~ok
    error('PIC_SPREAD:invalid_argument',mess)
end

if ~raise
    raise = self.rise_stored_figures_;
end

if self.n_hidden_fig_ == 0  && ~(raise || force)
    return;
end
if isempty(argi)
    sc = prod(self.screen_capacity_nfig);
    if self.fig_count_>= sc
        n_fig2_show = sc;
    else
        n_fig2_show  = self.fig_count_;
    end
else
    n_fig2_show  = varargin{1};
end
n_shown = 0;
n_hidden = 0;
for i=1:self.fig_count_
    fig_h = self.fig_list_{i};
    try
        isvis = fig_h.Visible;
    catch
        try  % figure is deleted
            isvis = get(fig_h,'Visible');
        catch
            continue;
        end
    end
    
    if ~strcmpi(isvis,'on')
        if n_shown < n_fig2_show
            set(fig_h,'visible','on')
            if raise
                rize_figure_(fig_h);
            end
            n_shown = n_shown+1;
        else
            n_hidden = n_hidden +1;
        end
    end
end
self.n_hidden_fig_ = n_hidden;
