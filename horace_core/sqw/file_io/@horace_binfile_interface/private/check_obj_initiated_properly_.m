function obj=check_obj_initiated_properly_(obj)
% Verify if data access object is properly initialized for writing data in it
%

[~,perm] = fopen(obj.file_id_);
if ~(strcmp(perm,'wb+') || strcmp(perm,'rb+'))
    obj = obj.reopen_to_write();
    fop = fopen(obj.file_id_);
    if isempty(fop)
        error('HORACE:horace_binfile_interface:runtime_error',...
            ['put_sqw called but the file %s to write can not be opened in write mode.\n'...
            'Current permissions are: "%s".\n',...
            'Initialize writer with sqw||dnd object to save data'],...
            obj.full_filename,perm);
    end
end
