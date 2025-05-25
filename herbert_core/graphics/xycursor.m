function [x,y]=xycursor (rot)
% Place cross-hairs on a plot and prompt to write x, y, (x,y) or text on the plot
%
%   >> xycursor
%   >> xycursor('v')          % numerical values and text are drawn vertically.
%   >> xycursor(rot)          % draw at angle rot to the horizontal
%   >> [x,y] = xycursor(...)  % As above and fills x, y as column vectors

if nargin==0
    rotation=0;
elseif ischar(rot)
    if strcmpi(rot,'h')
        rotation=0;
    elseif strcmpi(rot,'v')
        rotation=90;
    else
        error('Check input argument')
    end
elseif isnumeric(rot)
    rotation=rot;
else
    error('Check input argument')
end

if nargout~=0
    x=[];
    y=[];
end
val=[0,0];
disp ('Click left mouse button for menu; <carriage return> to finish')
while ~isempty(val)
    val = ginput(1);
    if ~isempty(val)
        if nargout~=0
            x=[x;val(1)];
            y=[y;val(2)];
        end
        k=menu('Cursor function:','x','y','xy','text','exit');
        switch k
          case 1
            str = num2str(val(1),'%16.6g');
            display (['x value: ',str])
            hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
            text(val(1),val(2),['  ',str],'rotation',rotation);

          case 2
            str = num2str(val(2),'%16.6g');
            display (['y value: ',str])
            hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
            text(val(1),val(2),['  ',str],'rotation',rotation);

          case 3
            str1 = num2str(val(1),'%16.6g');
            str2 = num2str(val(2),'%16.6g');
            display (['x value: ',str1,'    y value: ',str2])
            hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
            text(val(1),val(2),['  (',str1,', ',str2,')'],'rotation',rotation);

          case 4
            string = char(inputdlg('Cursor','Text to write to graphics window:'));
            if ~isempty(string)
                text(val(1),val(2),string,'rotation',rotation);
            end

          otherwise
            break

        end
    end
end

end

