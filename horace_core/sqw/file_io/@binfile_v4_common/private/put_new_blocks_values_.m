function obj = put_new_blocks_values_(obj,obj_to_write,varargin)
% method takes initlized faccessor and replaces blocks
% stored in file with new block values obtained from sqw or dnd
% object provided as input.
%
% Inputs:
% obj   -- initialized instance of file-accessor attached to existing sqw 
%          file containing sqw/dnd data.
% obj_to_write
%       -- sqw or dnd object with contents that replaces previous contents 
%          on disk.
%
% Optional:
% 'exclude' -- option followed by list of block names which
%              should remain unchanged in file.
%  block_list
%          -- cellarray of valid block names following 'exclude'
%             keyword, describing blocks which contents in file should
%             remains unchanged.
%             If this keyword/list are missing the method replaces all data
%             on disk except pixel data, which are locked by default.
%
% 'include' -- option followed by list of block names which shoud be
%             replaced in file. This option is opposit to 'exclude' option.            
%  block_list
%          -- cellarray of valid block names following 'include'
%             keyword, describing blocks which contents in file should
%             be replaced.
%             Similarly to 'exclude' if this option is missed, all blocks
%             except pixels are replaced on disk excluding pixel data.
%             If this option is present, only blocks from the list provided
%             are updated.
%
% '-nocache'  if present tells the algorithm not to cache serialized
%             contents of the blocks while calculating block sizes. 
%             This means that objects roughly speaking would be serialized
%             twice -- first time when their size is estimated (a bit quicker,
%             as memory is not allocated) and second time  -- before writing
%             data on disk. These are more expensive calculations but memory
%             is saved, as when cache is used, the serialized data for all
%             blocks to be stored are placed in memory together and saved
%             later.

% 
if ~obj.bat_.initialized
    error('HORACE:file_io:runtime_error', ...
        'attempting to put data using non-initialized file-accessor')
end
[ok,mess,nocache,argi] = parse_char_options(varargin,{'-nocache'});
if ~ok
    error('HORACE:file_io:invalid_argument',mess);    
end
% ensure file is opened in write mode
obj = reopen_to_write(obj);

bl_names_to_change = parse_addifional_input(obj,argi{:});
BAT = obj.bat_;
n_blocks = BAT.n_blocks;
all_bl_names      = BAT.block_names;
% store current block state to return to it later 
block_locked = false(1,n_blocks);

% unlock the blocks we want to change
for i=1:n_blocks
    block_locked(i) =  BAT.block_list{i}.locked;
    if ismember(all_bl_names{i},bl_names_to_change)
       BAT.block_list{i}.locked = false;                
    else
       BAT.block_list{i}.locked = true;        
    end
end
% clear size and position information about the blocks which should be modified
BAT = BAT.clear_unlocked_blocks();
% 
% identify the modified blocks sizes and found their places in BAT
BAT = BAT.place_unlocked_blocks(obj_to_write,nocache);
%
for i=1:n_blocks
    BAT.block_list{i}.locked = block_locked(i);    
    if block_locked(i)
        continue;
    end
    block = BAT.block_list{i};
    % store block
    block.put_sqw_block(obj.file_id_);
    BAT.block_list{i} = block;
end
%
%
obj.bat_ = BAT;
obj.bat_.put_bat(obj.file_id_);


function excluded_bl_list = parse_addifional_input(obj,varargin)
% retrieve list of excluded and included blocks if provided and return the
% list of blocks requested to modify.

exclude_kw = cellfun(@(x)ischar(x)&&strncmp(x,'exclude',7),varargin);

if ~any(exclude_kw)
    excluded_bl_list = {};
    return;
end
kw_num = find(exclude_kw);
excluded_bl_list  = varargin{kw_num+1};


