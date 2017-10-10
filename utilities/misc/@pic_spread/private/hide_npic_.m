function self = hide_npic_(self,varargin)
% method hides last n_pic2_hide pictures
%
%Usage:
% self=self.hide_n_figs([n_pic2_hide ])
%
% if n_pic2hide is not provided, the method hides last
% n_pic_per_screen_ images.

if self.n_hidden_pic_ == self.pic_count_
    return;
end
if nargin == 1
    n_pic2_hide = self.n_pic_per_screen_;
else
    n_pic2_hide  = varargin{1};
end
n_hid_loc = 0;
n_hid = 0;
for i=self.pic_count_:-1:1
    fig_h = self.pic_list_{i};
    try
        isvis = fig_h.Visible;
        if strcmp(isvis,'on')
            if n_hid_loc<n_pic2_hide
                set(fig_h,'visible','off')
                n_hid_loc = n_hid_loc +1;
                n_hid = n_hid +1;
            end
        else
            n_hid = n_hid +1;
        end
    catch
    end
end
self.n_hidden_pic_ = n_hid;
