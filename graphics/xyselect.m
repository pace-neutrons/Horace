function [x,y]=xyselect
% Puts cross-hairs on the current figure and print position when the left mouse button is pressed.
%
%   >> xyselect           % prints x,y value(s) to command screen
%   >> [x,y] = xyselect   % prints to screen and fills x, y as column vectors
%
% Essentially, this is the matlab intrinsic function ginput but writing values
% to the command window as well.

if nargout~=0; x=[];y=[]; end;
val=[0,0];
display ('Click left mouse button; <carriage return> to finish')
while ~isempty(val)
    val = ginput(1);
    if ~isempty(val)
        if nargout~=0; x=[x;val(1)]; y=[y;val(2)]; end;
        display (['x value: ',num2str(val(1),'%16.6g'),'    y value: ',num2str(val(2),'%16.6g')])
    end
end

% %   >> pnts  = xy   % prints to screen and fills pnts as (n x 2) array
% %                           x1  y1
% %                           x2  y2
% %                            :   :
% if nargout==1
%     x=[x,y];
% end
