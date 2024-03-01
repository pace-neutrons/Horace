function  [obj,missing_fields] = copy_contents_(obj,other_obj,keep_internals)
% Copy constructor with possibility to set up the data positions directly.
%
% Due to constrains of Matlab Object Model (or some misunderstanding),
% exactly the same routine  has to be present in binfile_v2_common\private
% folder.
%
%
%
this_pos = obj.get_pos_info();
if isa(other_obj,'horace_binfile_interface')
    other_pos = other_obj.get_pos_info();
    input_is_class = true;
elseif isstruct(other_obj) % we assume that there is structure, containing the positions
    keep_internals = true;
    input_is_class = false;
    other_pos = other_obj;
else
    error('SQW_FILE_IO:invalid_argument',...
        'The second argument of copy_contents function has to be a faccess class or structure, containing fields positions');
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
% open object's file with appropriate access rights.
[fp,fn,fe] = fileparts(file);
obj.filename_ = [fn,fe];
obj.filepath_ = [fp,filesep];
obj.file_id_ = sqw_fopen(file,mode);

if isempty(obj.file_closer_)
    obj.file_closer_ = fcloser(obj.file_id_ );
end

