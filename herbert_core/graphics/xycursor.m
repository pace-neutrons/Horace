function [x,y]=xycursor (rot)
% Place cross-hairs on a plot and prompt to write x, y, (x,y) or text to be written at a mouse click
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

if nargout~=0; x=[];y=[]; end;
val=[0,0];
display ('Click left mouse button for menu; <carriage return> to finish')
while ~isempty(val)
    val = ginput(1);
    if ~isempty(val)
        if nargout~=0; x=[x;val(1)]; y=[y;val(2)]; end;
        k=menu('Cursor function:','x','y','xy','text','exit');
        if k==1
            str = num2str(val(1),'%16.6g');
            display (['x value: ',str])
            hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
            text(val(1),val(2),['  ',str],'rotation',rotation);
            
        elseif k==2
            str = num2str(val(2),'%16.6g');
            display (['y value: ',str])
            hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
            text(val(1),val(2),['  ',str],'rotation',rotation);
            
        elseif k==3
            str1 = num2str(val(1),'%16.6g');
            str2 = num2str(val(2),'%16.6g');
            display (['x value: ',str1,'    y value: ',str2])
            hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
            text(val(1),val(2),['  (',str1,', ',str2,')'],'rotation',rotation);
            
        elseif k==4
            string = char(inputdlg('Cursor','Text to write to graphics window:'));
            if ~isempty(string)
                text(val(1),val(2),string,'rotation',rotation);
            end
            
        else
            break
            
        end
    end
end
