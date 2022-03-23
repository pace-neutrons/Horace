function [id,filename] = extract_id_from_filename_(file_name)
% extract run id from a filename, if run-number is
% present in the filename, and is first number among all other
% numbers, or if it is stored at the end of the filename after special
% character string, specifying this number.
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
