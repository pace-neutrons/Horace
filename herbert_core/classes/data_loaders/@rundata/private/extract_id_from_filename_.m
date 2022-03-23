function [id,filename] = extract_id_from_filename_(file_name)
% Extract run id from a filename, if run-number is
% present in the filename, and is first number among all other
% numbers. Alternativelym it may be stored at the end of the filename after 
% special character string, specifying this number.
% Inputs:
% file_name - string containing filename with runid or mangled string
%             containg special representation of runid in the form 
%             fildname$id$string_representation_of_id;
% Output:
% id        - number (id) extracted from filename. NaN if routine has not 
%              been able to identify any numbers in the filename
% filename  - unchanged filename if file_name did not contained $id$ or
%             unmabgled par of file_name if $id% was present
%

[~,filename,fext] = fileparts(file_name);
% the way of writing special filenames and run_id map
% with current file format, not introducing new file format
% will be removed/ignored in the future versions of the file
% format
id_source = filename;
fn_is_soruce = true;
loc = strfind(id_source,'$id$');
if isempty(loc)
    id_source = fext;
    fn_is_soruce = false;
    loc = strfind(id_source,'$id$');
else

end
if isempty(loc)
    [l_range,r_range] = regexp(filename,'\d+');
    if isempty(l_range)
        id = NaN;
        return;
    end
    id = str2double(filename(l_range(1):r_range(1)));
    filename = [filename,fext];
else
    id       = str2double(id_source(loc(1)+4:end));
    if fn_is_soruce
        filename = [id_source(1:loc(1)-1),fext];
    else
        filename = [filename,id_source(1:loc(1)-1)];
    end
end
