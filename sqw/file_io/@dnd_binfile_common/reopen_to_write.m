function obj = reopen_to_write(obj)
if isempty(obj.filename)
    error('SQW_FILE_IO:runtime_error',...
        'DND_BINFILE_COMMON::reopen_to_write: can not reopen file if filename is not defined')
    
end
obj.file_closer_ = [];
fn = fopen(obj.file_id_);
if ~isempty(fn)
    fclose(obj.file_id_);
end
fname = fullfile(obj.filepath,obj.filename);
fid = fopen(fname,'rb+');
if fid<1
    error('SQW_FILE_IO:runtime_error',...
        'DND_BINFILE_COMMON::reopen_to_write: error reopening file %s in write access mode',...
        fname)
    
end
obj.file_id_ = fn;
obj.file_closer_ = onCleanup(@()obj.fclose());

