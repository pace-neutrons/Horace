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
if ~obj.bat_.initialized
    error('HORACE:file_io:runtime_error', ...
        'attempting to put data using non-initialized file-accessor')
end
% ensure file is opened in write mode
obj = reopen_to_write(obj);

excluded_blocks = parse_addifional_input(varargin{:});
BAT = obj.bat_;
all_bl_names = BAT.block_names; 
if ~isempty(excluded_blocks)
    for i=1:BAT.n_blocks
        is_excluded = ismember(all_bl_names{i},excluded_blocks);
        if is_excluded
            BAT.block_list{i}.locked = true;
        end
    end
end


function excluded_bl_list = parse_addifional_input(varargin)
% retrieve list of excluded blocks if provided

exclude_kw = cellfun(@(x)ischar(x)&&strncmp(x,'exclude',7),varargin);

if ~any(exclude_kw)
    excluded_bl_list = {};
    return;
end
kw_num = find(exclude_kw);
excluded_bl_list  = varargin{kw_num+1};


