function cursor (direction_in)
% Draws cross-hairs on the screen. When the left mouse button is depressed,
% a dialogue box requests for the current x, y, (x,y) value, or for a text string
% to be drawn on the plot.
%
% Syntax:
%   >> cursor
%
%   >> cursor v     % numerical values and text are drawn vertically.
%

if nargin==0
    direction = 'h';
else
    try
        direction = evalin('caller',direction_in);
    catch
        direction = direction_in;
    end
end

if strcmp(lower(direction),'v')
    rotation = 90;
elseif strcmp(lower(direction),'h')
    rotation = 0;
elseif ~strcmp(lower(direction),'none')
    error ('Unrecognised text orientation')
end

val=[0,0];
display ('Click left mouse button; <carriage return> to finish')
while ~isempty(val)
    val = ginput(1);
    if ~isempty(val)
        k=menu('Cursor function:','x','y','xy','text','exit');
        if k==1
            str = num2str(val(1),'%16.6g');
            display (['x value: ',str])
            if ~strcmp(lower(direction),'none')
                hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
                text(val(1),val(2),['  ',str],'rotation',rotation);
            end
        elseif k==2
            str = num2str(val(2),'%16.6g');
            display (['y value: ',str])
            if ~strcmp(lower(direction),'none')
                hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
                text(val(1),val(2),['  ',str],'rotation',rotation);
            end
        elseif k==3
            str1 = num2str(val(1),'%16.6g');
            str2 = num2str(val(2),'%16.6g');
            display (['x value: ',str1,'    y value: ',str2])
            if ~strcmp(lower(direction),'none')
                hold on; plot(val(1),val(2),'linestyle','none','marker','x','markersize',6); hold off;
                text(val(1),val(2),['  (',str1,', ',str2,')'],'rotation',rotation);
            end
        elseif k==4
%            string = input ('Text to write (<CR> to exit): ','s');
            string = char(inputdlg('Cursor','Text to write to graphics window:'));
            if ~isempty(string)
                text(val(1),val(2),string,'rotation',rotation);
            end
        else
            return
        end
    end
end
