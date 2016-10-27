function  obj = check_file_set_new_name_(obj,new_filename)
% set new file name to save sqw data in
%
if ~ischar(new_filename)
    error('DND_FILE_INTERFACE:invalid_argument',...
        'set_new_filename: path to save files has to be defined by sequence of characters')
end

if ~isempty(obj.file_closer_)
    obj.file_closer_ = [];
end
%
[fp,fn,fext] = fileparts(new_filename);
fn = [fn,fext];
fp = [fp,filesep];
obj.filename_ = fn;
obj.filepath_ = fp;
%
if isempty(fn)
    return
end

obj.file_id_ = fopen([fp,fn],'wb+');
if obj.file_id_ <=0
    error('DND_BINFILE_COMMON:io_error',' Can not open file %s to write data',[fp,fn])
end

obj.file_closer_ = onCleanup(@()obj.fclose());

