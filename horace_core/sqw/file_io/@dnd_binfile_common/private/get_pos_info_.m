function   pos_info = get_pos_info_(obj)
% return structure, containing position of every data field in the 
% file (when object is initialized) plus some auxiliary information
% used to fully describe this file
%

fields2save = obj.fields_to_save();
pos_info  = struct();
for i=1:numel(fields2save)
    fld = fields2save{i};
    pos_info.(fld) = obj.(fld);
end


