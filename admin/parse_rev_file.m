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
[startIndex,endIndex] = regexp(cont','(?<=\$Revision::).*?(?=\$)');

[rev_str,cont] = replace_revision(cont,startIndex,endIndex);

datetm = char(datetime('now','timezone','local','Format',...
    'yyyy-MM-dd HH:mm:ss Z (eee, d MMM yyy)'));
cont = regexprep(cont','(?<=\$Date::).*?(?= \$)',datetm);
datetm = [':: ',datetm,' '];
rev_str = ['::',rev_str];

fseek(fh,0,'bof');
fwrite(fh,cont);
clear clob;

function [rev_str ,cont]= replace_revision(cont,startIndex,endIndex)

rev_place = cont(startIndex:endIndex);
rev_n = str2double(rev_place);
n_places = numel(rev_place);
ns = n_sign(rev_n+1);

if ns<=n_places-1
    format_ = sprintf('%dd',n_places-1); % add front space
    rev_str = sprintf([' %-',format_],rev_n+1); 
    cont(startIndex:endIndex) = rev_str'; 
elseif ns==n_places
    format_ = sprintf('%dd',n_places);    
    rev_str = sprintf(['%-',format_],rev_n+1); 
    cont(startIndex:endIndex) = rev_str';
else
    rev_str = sprintf(' %d ',rev_n+1);
    cont = [cont(1:startIndex-1);rev_str';cont(1:endIndex+1)];    
end




function ns = n_sign(number)
% return number of digital signs in a number.
ns = 1;
rednum = floor(number/10);
while rednum>0
    ns = ns+1;
    rednum = floor(rednum/10);
end