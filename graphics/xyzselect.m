function [x,y,z]=xyzselect
% Create cross-hairs on current figure and print x,y,z triples on mouse click.
%
% Move the cross-hairs with the mouse and press the left mouse button to 
% print the position. Continue until hit return, when cross-hairs
% disappear.
%
%   >> xyzselect              % prints x,y,z value(s) to command screen
%   >> [x,y,z] = xyzselect    % prints to screen and fills x,y,z column vectors
%
% This is similar to the matlab intrinsic function ginput but extended to
% area and surface plots, and writes values to the command window as well.

if nargout~=0; x=[];y=[];z=[]; end;
val=[0,0];
display ('Click left mouse button; <carriage return> to finish')
while ~isempty(val)
    val = ginput(1);
    if ~isempty(val)
        val3d = select3d;
        if ~isempty(val3d)
            if nargout~=0; x=[x;val3d(1)]; y=[y;val3d(2)]; z=[z;val3d(3)]; end;
            display (['x value: ',num2str(val3d(1),'%16.6g'),...
                  '    y value: ',num2str(val3d(2),'%16.6g'),...
                  '    z value: ',num2str(val3d(3),'%16.6g')])
        else
            display('Point lies outside data')
        end
    end
end
