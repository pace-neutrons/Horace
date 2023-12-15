function obj = put_new_blocks_values_(obj,obj_to_write,varargin)
% method takes initlized faccessor and replaces blocks
% stored in file with new block values obtained from sqw or dnd
% object provided.
% Inputs:
% obj   -- initialized instance of file-accessor.
% obj_to_write
%       -- sqw or dnd object which contents should be replaced
%          on disk.
% Optional:
% 'exclude' -- option followed by list of block names which
%              should remain unchanged.
% block_list
%          -- cellarray of valid block names following 'exclude'
%             keyword which contents should remains unchanged
%             on disk.
