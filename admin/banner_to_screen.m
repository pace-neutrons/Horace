function banner_to_screen(str)
% Write a banner to the screen containing the provided text
%
%   >> banner_to_screen(str)

disp('================================================================================')
disp('================================================================================')
disp('===                                                                          ===')

strout='===                                                                          ===';
str=['===    ',deblank(str),' '];
if numel(str)<=80
    strout(1:numel(str))=str;
else
    strout=str(1:80);
end
disp(strout)

disp('===                                                                          ===')
disp('================================================================================')
disp('================================================================================')
