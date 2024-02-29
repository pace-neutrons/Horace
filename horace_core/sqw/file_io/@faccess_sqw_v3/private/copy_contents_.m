function  [obj,missing_fields] = copy_contents_(obj,other_obj,keep_internals)
% Copied position information from one loader to another one
%
% keep_internals -- if true, do not overwrite service fields
%                   not related to the position information
%
obj = obj.fclose();
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
obj.contains_runid_in_header_ = other_obj.contains_runid_in_header_;
%
if other_obj.file_id_>0
    [file,acc] = fopen(other_obj.file_id_);
    if ismember(acc,{'rb+','wb+'}) % transfer write access to the new object
        obj = open_obj_file(obj,file,'rb+');
    else
        obj = open_obj_file(obj,file,'rb');
    end
else
    obj.full_filename = other_obj.full_filename;
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
obj.full_filename = file;
obj.file_id_ = sqw_fopen(file,mode);

if isempty(obj.file_closer_)
    obj.file_closer_ = fcloser(obj.file_id_);
end
