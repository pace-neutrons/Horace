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
    rise_fig = self.rize_stored_figures;
end

ps = get(fig_handle,'Position');

if self.pic_count_==0
    if ~self.resize_pictures_
        % if pictures are not resized, use first picture size as the size
        % of all subsequent pictures.
        self.pic_size_=[ps(3),ps(4)];
    end
    % Y-position of the first picture.
    iy = self.screen_size_(2)-self.pic_size_(2)-self.top_border;
    % real number of pictures to be placed on screen.
    self.n_pic_per_screen_ = floor((self.screen_size_(1)-self.left_border)/self.pic_size_(1))*...
        floor((self.screen_size_(2)-self.top_border)/self.pic_size_(2));
else
    ps2 = get(self.pic_list_{self.pic_count}, 'Position');
    iy = ps2(2);
end
%
ix = self.current_shift_x_;
if ix+self.pic_size(1)>self.screen_size_(1)
    if self.overlap_borders
        ix = self.left_border;
    else
        ix=0;
    end
    iy = iy-self.pic_size(2);
else
end
if iy<0 % tne next row of images will come out of the screen. Reset
    iy = self.screen_size_(2)-self.pic_size(2)-self.top_border;
end
set(fig_handle, 'Position', [ix iy, self.pic_size_(1),self.pic_size_(2)])
if rise_fig
    figure(fig_handle) 
    %set(0,'CurrentFigure',fig_handle);
    drawnow;
end


self.current_shift_x_ = ix+self.pic_size_(1);
self.current_shift_y_ = iy;


% store the info about active picture handles
self.pic_count_=self.pic_count_+1;
self.pic_list_{self.pic_count}=fig_handle;
