function self = check_and_show_n_figs_(self,varargin)
% Shows specified number of hidden pictures
%
%   Detailed explanation goes here

[ok,mess,raise,argi] = parse_char_options(varargin,{'-raise'});
if ~ok
    error('PIC_SPREAD:invalid_argument',mess)
end

if ~raise
    raise = self.rise_stored_figures_;
end

if self.n_hidden_pic_ == 0  && ~raise
    return;
end
if isempty(argi)
    sc = prod(self.screen_capacity_npic);
    if self.pic_count_>= sc
        n_pic2_show = sc;
    else
        n_pic2_show  = self.pic_count_;
    end    
else
    n_pic2_show  = varargin{1};
end
n_shown = 0;
n_hidden = 0;
for i=self.pic_count_:-1:1
    fig_h = self.pic_list_{i};
    try
        isvis = fig_h.Visible;
        if ~strcmpi(isvis,'on')
            if n_shown < n_pic2_show
                set(fig_h,'visible','on')
                if raise
                    set(0,'currentfigure', fig_h);
                end
                n_shown = n_shown+1;
            else
                n_hidden = n_hidden +1;                
            end
        end
    catch
    end
end
self.n_hidden_pic_ = n_hidden;
