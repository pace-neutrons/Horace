function self = hide_nfig_(self,varargin)
% method hides last n_fig2_hide figures
%
%Usage:
% self=self.hide_n_figs([n_fig2_hide ])
%
% if n_fig2hide is not provided, the method hides last
% n_fig_per_screen_ images.

if self.n_hidden_fig_ == self.fig_count_
    return;
end
if nargin == 1
    sc = prod(self.screen_capacity_nfig);
    if self.fig_count_>= sc
        n_fig2_hide = sc;
    else
        n_fig2_hide = self.fig_count_;
    end
else
    n_fig2_hide  = varargin{1};
end
n_hid_loc = 0;
n_hid = 0;
for i=self.fig_count_:-1:1
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
    if strcmp(isvis,'on')
        if n_hid_loc<n_fig2_hide
            set(fig_h,'Visible','off')
            n_hid_loc = n_hid_loc +1;
            n_hid = n_hid +1;
        end
    else
        n_hid = n_hid +1;
    end
end
self.n_hidden_fig_ = n_hid;
