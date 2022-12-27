function [dnd_info,obj] = get_dnd_metadata(obj,varargin)
%GET_DND_METADATA return general information, describing dnd data

[dnd_info,obj] =  get_dnd_block_(obj, ...
    faccess_dnd_v4.dnd_blocks_list_{1},varargin{:});
