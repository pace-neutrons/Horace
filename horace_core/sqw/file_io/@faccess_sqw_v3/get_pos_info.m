function   pos_info = get_pos_info(obj)
% Return structure, containing position of every data field in the
% file (when object is initialized) plus some auxiliary information
% used to fully describe this file.
%
% Located in SQW_v3 due to a Matlab bug in inheritance chain
%
%

fields2save = obj.saveableFields();
pos_info  = struct();
for i=1:numel(fields2save)
    fld = fields2save{i};
    pos_info.(fld) = obj.(fld);
end


