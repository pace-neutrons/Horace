function [rev_str,datetm] = parse_rev_file(rev_file_name)
% Parse revision file and increase the revision number by one
% and revision date -- to the current date.
% 
% Return new revision numeber and revision date. 
%
%
%keywords = {'$Revision:','$Date:'};
%
fh = fopen(rev_file_name,'rb+');
if fh<0
    error('PARCE_REVISION:runtime_error',...
        ' Can not open file %s',rev_file_name);
end
clob = onCleanup(@()fclose(fh));

cont = fread(fh,'*char');
if isempty(cont)
    error('PARCE_REVISION:runtime_error',...
        ' Empty revision file %s',rev_file_name);
end
[startIndex,endIndex] = regexp(cont','(?<=\$Revision)(.*?)(?=\$)');

[rev_str,cont] = replace_revision(cont,startIndex,endIndex);

datetm = [':: ',char(datetime('now','timezone','local','Format',...
    'yyyy-MM-dd HH:mm:ss Z (eee, d MMM yyy)')),' '];
cont = regexprep(cont,'(?<=\$Date)(.*?)(?=\$)',datetm);


fseek(fh,0,'bof');
fwrite(fh,cont);
clear clob;

function [rev_str ,cont]= replace_revision(cont,startIndex,endIndex)

rev_place = cont(startIndex:endIndex);
rev_n = sscanf(rev_place,':: %d');
if isnan(rev_n)
    rev_n = 1;
end
rev_str = sprintf(':: %-d ',rev_n+1);
cont = regexprep(cont','(?<=\$Revision)(.*?)(?=\$)',rev_str);
