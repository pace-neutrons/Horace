function self = calc_pos_place_fig_(self,fig_handle,varargin)
% Calculate the position of the picture and place it to the position
% according to the next picture settings.
%
%
%
% $Revision: 1524 $ ($Date: 2017-09-27 15:48:11 +0100 (Wed, 27 Sep 2017) $)
%
keywords={'-rise'};
[ok,mess,rise_fig]=parse_char_options(varargin,keywords);
if ~ok
    error('PIC_SPREAD:invalid_argument',mess);
end
if ~rise_fig
    rise_fig = self.rise_stored_figures_;
end

ps = get(fig_handle,'Position');
if self.fig_count_==0
    if self.resize_figures_
        size = self.fig_size;
        ps(3) = size(1);
        ps(4) = size(2);
    else
        % if pictures are not resized, use first picture size as the size
        % of all subsequent pictures.
        self.fig_size = [ps(3),ps(4)];
    end
else
    size = self.fig_size;
    ps(3) = size(1);
    ps(4) = size(2);
    
end
% store the info about active picture handles
self.fig_count_=self.fig_count_+1;
self.fig_list_{self.fig_count}=fig_handle;


[ix,iy,~] = self.calc_fig_pos(self.fig_count_,ps(3),ps(4));

set(fig_handle, 'Position', [ix iy, ps(3),ps(4)])
keep_figure(fig_handle);
if rise_fig
    rize_figure_(fig_handle);
end


