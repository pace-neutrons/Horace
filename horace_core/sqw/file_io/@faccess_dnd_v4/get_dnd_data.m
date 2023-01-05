function[dnd_dat,obj]  = get_dnd_data(obj,varargin)
%GET_DND_DATA return n-d arrays, describing N-D image

[dnd_dat,obj] = get_dnd_block_(obj, ...
    faccess_dnd_v4.dnd_blocks_list_{2},varargin{:});