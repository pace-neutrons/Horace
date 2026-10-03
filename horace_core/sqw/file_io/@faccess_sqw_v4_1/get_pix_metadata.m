function [metadata,obj] = get_pix_metadata(obj,varargin)
% get full pixel metadata class
%
%
sqh = obj.sqw_holder;
obj.sqw_holder_ = [];
[obj,metadata] = obj.get_sqw_block('bl_pix_metadata',varargin{:});
if ~isempty(sqh)
    sqh.pix.metadata = metadata;
    obj.sqw_holder_ = sqh;
end
