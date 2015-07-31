function [x,y]=xyselect
% Create cross-hairs on current figure and print x,y pairs on mouse click.
%
% Move the cross-hairs with the mouse and press the left mouse button to 
% print the position. Continue until hit return, when cross-hairs
% disappear.
%
%   >> xyselect           % prints x,y value(s) to command screen
%   >> [x,y] = xyselect   % prints to screen and fills x, y column vectors
%
% Essentially, this is the matlab intrinsic function ginput but writes
% values to the command window as well.

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
