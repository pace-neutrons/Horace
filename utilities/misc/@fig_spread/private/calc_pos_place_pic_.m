function self = calc_pos_place_pic_(self,fig_handle,varargin)
% Calculate the position of the picture and place it to the position
% according to the next picture settings.
%
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
if self.pic_count_==0
    if self.resize_pictures_
        size = self.pic_size;
        ps(3) = size(1);
        ps(4) = size(2);
    else
        % if pictures are not resized, use first picture size as the size
        % of all subsequent pictures.
        self.pic_size = [ps(3),ps(4)];
    end
else
    size = self.pic_size;
    ps(3) = size(1);
    ps(4) = size(2);
    
end
% store the info about active picture handles
self.pic_count_=self.pic_count_+1;
self.pic_list_{self.pic_count}=fig_handle;


[ix,iy,~] = self.calc_fig_pos(self.pic_count_,ps(3),ps(4));

set(fig_handle, 'Position', [ix iy, ps(3),ps(4)])
if rise_fig
    figure(fig_handle)
    %set(0,'CurrentFigure',fig_handle);
    drawnow;
end


