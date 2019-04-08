function  [obj,missing_fields] = copy_contents_(obj,other_obj,keep_internals)
% Copy constructor with possibility to set up the data positions directly.
%
% Due to constrains of Matlab Object Model (or some misunderstanding),
% exactly the same routine  has to be present in dnd_binfile_common\private
% folder.
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
%
%
this_pos = obj.get_pos_info();
if isa(other_obj,'dnd_file_interface')
    other_pos = other_obj.get_pos_info();
    input_is_class = true;
elseif isstruct(other_obj) % we assume that there is sturcute, containing the positions
    keep_internals = true;
    input_is_class = false;
    other_pos = other_obj;
else
    error('SQW_FILE_IO:invalid_argument',...
        'The second argument of copy_contents funtion has to be a faccess class or stucute, containing fields positions');
end

flds = fieldnames(this_pos);
n_fields = numel(flds);
is_missing = false(1,n_fields);
for i=1:n_fields
    fld = flds{i};
    if isfield(other_pos,fld)
        obj.(fld) = other_pos.(fld);
    else
        is_missing(i) = true;
    end
end
missing_fields = flds(is_missing);
%
if input_is_class
    if  other_obj.file_id_>0
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
