function  [obj,missing_fields] = copy_contents_(obj,other_obj,keep_internals)
% Copy constructor
%
%
this_pos = obj.get_pos_info();
other_pos = other_obj.get_pos_info();
missing_fields = {};
n_missing = 0;

flds = fieldnames(this_pos);
for i=1:numel(flds)
    fld = flds{i};
    if isfield(other_pos,fld)
        obj.(fld) = other_pos.(fld);
    else
        n_missing = n_missing + 1;
        missing_fields{n_missing} = fld;
    end
end
%
if other_obj.file_id_>0
    [file,acc] = fopen(other_obj.file_id_);
    if ismember(acc,{'rb+','wb+'}) % transfer write access to the new object
        %other_obj = other_obj.fclose();
        %other_obj = open_obj_file(other_obj,file,'rb');
        obj = open_obj_file(obj,file,'rb+');
    else
        obj = open_obj_file(obj,file,'rb');
    end
else
    obj.filename_ = other_obj.filename;
    obj.filepath_ = other_obj.filepath;
end
if keep_internals
    return;
end
% copy fields which are not saved
obj.sqw_serializer_ = other_obj.sqw_serializer_;
obj.sqw_holder_   = other_obj.sqw_holder_;
obj.real_eof_pos_ = other_obj.real_eof_pos_;
obj.upgrade_map_  = other_obj.upgrade_map_;
obj.convert_to_double_ = other_obj.convert_to_double_;



function obj= open_obj_file(obj,file,mode)
% open object's file with apporpriate access rights.
[fp,fn,fe] = fileparts(file);
obj.filename_ = [fn,fe];
obj.filepath_ = [fp,filesep];
obj.file_id_ = fopen(file,mode);
if obj.file_id_ <= 0
    error('SQW_FILE_IO:io_error',...
        'Can not open file %s in %s mode',file,mode)
end
obj.file_closer_ = onCleanup(@()obj.fclose());
