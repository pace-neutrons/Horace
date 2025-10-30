function [pix_range,obj] = get_pix_range(obj,varargin)
% get [2x4] array of min/max ranges of the pixels contributing
% into an object. Empty for DND object
sqh = obj.sqw_holder;
obj.sqw_holder_ = [];
[obj,metadata] = obj.get_sqw_block('bl_pix_metadata',varargin{:});
pix_range = metadata.pix_range;    
if ~isempty(sqh)
    sqh.pix.metadata = metadata;
    obj.sqw_holder_ = sqh;
end
