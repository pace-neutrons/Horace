function check_obj_initiated_properly_(obj)
% Verify if data access object is properlty initialized for writing data in
%

if obj.file_id_ < 0
    error('DND_BINFILE_COMMON:runtime_error',...
        ['put_sqw called but the file to write has not been initiated.\n'...
        'initialize writer with current sqw file']);
end

[~,perm] = fopen(obj.file_id_);
if ~(strcmp(perm,'wb+') || strcmp(perm,'rb+'))
    error('DND_BINFILE_COMMON:runtime_error',...
        ['put_sqw called but the file to write has not been initiated.\n'...
        'Current permissions are: "%s".\n',...
        'Initialize writer with sqw||dnd object to save data'],...
        perm);
end
if isempty(obj.sqw_serializer_)
    error('DND_BINFILE_COMMON:runtime_error',...
        ['put_sqw called on non-initialized faccess object.\n'...
        'initialize writer with  sqw||dnd object to save']);
end




