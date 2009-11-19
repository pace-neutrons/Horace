function handles_out=hor_readparams(handles_in)
%
% function to read in stored cut parameter data from a previous Horace
% session (like msp file in MSlice). A lot of the following code is
% inspired by (/nicked from) ms_load_msp from MSlice.
%
% R.A. Ewings 18/11/2008
%

%NOT YET BEEN TESTED!!

%initialise the output:
handles_out=handles_in;

% === open .hor parameter file for reading as an ASCII text file
fullname=get(handles_in.LoadPars_edit,'String');
fid=fopen(fullname,'rt');
if fid==-1,
   disp(['Error opening parameter file ' fullname '. Return.']);
   return;
end


%=== READ .HOR FILE LINE BY LINE
disp(['Proceed reading parameter file ' fullname]);
t=fgetl(fid);
while (ischar(t))&&(~isempty(t(~isspace(t)))),
   pos=findstr(t,'=');
   field=t(1:pos-1);
   field=field(~isspace(field));
   %
   if ~isempty(field),
      value=t(pos+1:length(t));
      value=deblank(value);	% remove trailing blanks from both the beginning and end of string
      value=strtrim(value);
      if ~strcmp(field(end-4:end),'radio')%we are not considering a radio button
          eval(['set(handles_in.',field,',','''String''',',''',value,''');']);
      else
          eval(['set(handles_in.',field,',','''Value''',',',value,');']);
      end
   end 
   t=fgetl(fid);
end
fclose(fid);
disp(['Successfully read parameter file ' fullname]);

handles_out=handles_in;