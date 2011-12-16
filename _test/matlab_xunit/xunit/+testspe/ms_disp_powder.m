function [data] = ms_disp_powder( data)
% function to enabe mslice disp_powder picture'

fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
   mslice;
   fig=findobj('Tag','ms_ControlWindow');
end
set(fig,'UserData',data);

ms_disp;



