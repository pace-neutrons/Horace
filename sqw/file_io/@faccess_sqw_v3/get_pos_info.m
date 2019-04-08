function   pos_info = get_pos_info(obj)
% Return structure, containing position of every data field in the
% file (when object is initialized) plus some auxiliary information
% used to fully describe this file.
%
% Located in SQW_v3 due to a Matlab bug in inheritance chain
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
%

fields2save = obj.fields_to_save();
pos_info  = struct();
for i=1:numel(fields2save)
    fld = fields2save{i};
    pos_info.(fld) = obj.(fld);
end

