function [ix,iy,n_frames] = calc_fig_pos_(self,n_fig,size_x,size_y)
% calculate the position of the picture number nfig on the screen
% given the picture size and screen size
%

screen_capacity = self.screen_capacity_nfig;
nfig_per_screen = prod(screen_capacity);
%
n_frames = floor(n_fig*(1-eps)/nfig_per_screen);
cur_fig = n_fig - n_frames*nfig_per_screen;


n_y_row = floor((cur_fig-1)/screen_capacity(1));
n_x_row = cur_fig-n_y_row*screen_capacity(1)-1;


iy = self.screen_size_(2)-self.top_border - (n_y_row+1)*size_y;
ix = self.left_border+n_x_row*size_x;




