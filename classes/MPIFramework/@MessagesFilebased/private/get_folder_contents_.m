function fc = get_folder_contents_(mess_folder)
% Utitlity function to retrieve folder contents under Windows
% trying not to open and block message files
%
command = ['Dir ',mess_folder];
[status,cont] = system(command);
if status ~=0
    error('RECEIVE_MESSAGE:runtime_error',...
        'Error %d executing Windows Dir command on folder %s',...
        mess_folder);
end

%fc = regexp(cont,'\z','split');
cont = splitlines(cont);
fc = cellfun(@(x)select_files(x,mess_folder),cont,'UniformOutput',false);
valid = cellfun(@(x)numel(x)>1,fc);
fcc  = fc(valid);
% simplified version of output structure. Not consistent with dir, but
% sufficient for parce_folder
%fields = {'name','folder','date','bytes','isdir','datenum'};
fields = {'name','date','bytes','isdir'};
fa =cell(numel(fields),numel(fcc));
for i=1:numel(fcc)
    fa(:,i) = fcc{i}(:);
end
fc = cell2struct(fa,fields,1);


function file_info=select_files(file_string,folder)
fc = split(file_string);
if numel(fc)~=4
    file_info = '';
    return
end
if strcmpi(fc{3},'<DIR>')
    file_info = '';
    return
end
if isempty(fc{1})
    file_info = '';
    return;
end
date = [fc{1},' ',fc{2}];
fc{1} = fc{4};
fc{2} = date;
fc{3} = regexprep(fc{3},'[,.]',''); %bytes
fc{4} = false;
%fc{5} = false;
%fc{6} = datenum(fc{1},'dd/mm/yyyy HH:MM');
file_info = fc;