function handles_out=hor_saveparams(handles_in)
%
% function to save cut parameter data from current Horace
% session (like msp file in MSlice)
%
% R.A. Ewings 18/11/2008
%

%NOT YET BEEN TESTED!!

%initialise the output:
handles_out=handles_in;

%The bulk of the following code closely resembles (i.e is nicked from)
%ms_save_msp from MSlice.

default='params_template.hor';
newfile=get(handles_in.SavePars_edit,'String');


% ==== open both the default .hor file and new file as ASCII text files 
f1=fopen(default,'rt');
if (f1==-1),
   disp(['Error opening default parameter file ' default]);
   disp('Parameter file not saved.');
   return;
end

f2=fopen(newfile,'wt');
if (f2==-1),
   disp(['Error opening selected parameter file ' newfile]);
   disp('Parameter file not saved.');
   return;
end

% === write parameters line by line to the newfile mirroring structure of default file
t=fgetl(f1);	% read one line of the default file
while (ischar(t)&&(~isempty(t(~isspace(t))))),	% until reaching the end of the defauilt file do ...
   pos=findstr(t,'=');
   field=t(1:pos-1);
   fieldname=field(~isspace(field));	% obtain true fieldname by removing white spaces from field
   % if object is radio button its value is stored in the 'Value' property, otherwise in 'String'
   getstr=['get(handles_in.',fieldname];
   if eval(['strcmp(',getstr,',''Style''','),''radiobutton'');']);
      value=eval(['num2str(',getstr,',','''Value''','));']);
   else
      value=eval([getstr,',','''String''',');']);
      value=deblank(value);	% remove trailing blanks from both beginning and end
      value=strtrim(value);  
   end 
   fprintf(f2,'%s%2s%s\n',field,'= ',value);
   t=fgetl(f1);
end
fclose(f1);
fclose(f2);
disp(['Saved parameters to file ' newfile]);

handles_out=handles_in;