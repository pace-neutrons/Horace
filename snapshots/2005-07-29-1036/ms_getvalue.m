function value=ms_getvalue(input)
% Get value property of object with given tag from the mslice control
% window. This is similar to the ms_setvalue function (but not quite). Uses
% the ms_getstring routine.

h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp(['No Control widow opened, can not get parameter value']);
   return;
end

% get the value of the tag as a string
str=ms_getstring(h_cw,['ms_' input]);

% convert string into a value
value= str2num(str);