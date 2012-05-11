function [x,y,z]=xyzselect
% Puts cross-hairs on the current figure (area or surface plot) and print position when the left mouse button is pressed.
%
%   >> xyzselect              % prints x,y,z value(s) to command screen
%   >> [x,y,z] = xyzselect    % prints to screen and fills x,y,z as row vectors
%
% Essentially, this is the matlab intrinsic function ginput but writing values
% to the command window as well.

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

% %   >> pnts  = xyz      % prints to screen and fills pnts as (n x 2) array
% %                           x1  y1  z1
% %                           x2  y2  z2
% %                            :   :   :
% if nargout==1
%     x=[x,y,z];
% end
