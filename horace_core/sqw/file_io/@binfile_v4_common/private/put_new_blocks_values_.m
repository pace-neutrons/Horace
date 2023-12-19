function obj = put_new_blocks_values_(obj,obj_to_write,keep_locked,nocache,varargin)
% method takes initlized faccessor and replaces blocks
% stored in file with new block values obtained from sqw or dnd
% object provided as input.
%
% Inputs:
% obj     -- initialized instance of file-accessor attached to existing sqw
%            file containing sqw/dnd data.
% obj_to_write
%         -- sqw or dnd object with contents that replaces previous contents
%            on disk.
% keep_locked
%         -- if true do not touch blocks already locked in place
% nocache -- if ture, tells the algorithm not to cache serialized
%            contents of the blocks while calculating block sizes.
%            This means that objects roughly speaking would be serialized
%            twice -- first time when their size is estimated (a bit quicker,
%            as memory is not allocated) and second time  -- before writing
%            data on disk. These are more expensive calculations but memory
%            is saved, as when cache is used, the serialized data for all
%            blocks to be stored are placed in memory together and saved
%            later.
%
% Optional:
% 'exclude' -- option followed by list of block names which
%              should remain unchanged in file.
%  block_list
%          -- cellarray of valid block names following 'exclude'
%             keyword, describing blocks which contents in file should
%             remains unchanged.
%
% 'include' -- option followed by list of block names which shoud be
%             replaced in file. This option is opposit to 'exclude' option.
%  block_list
%          -- cellarray of valid block names following 'include'
%             keyword, describing blocks which contents in file should
%             be replaced.
% NOTE:
% 'exclude' and 'include' keywords can not be specified together.
% if no 'exclued' and 'include' keywords are specified, all blocks except
% pixels (locked by default) and blocks locked in addition to them will be
% replaces in file
%

%
if ~obj.bat_.initialized
    error('HORACE:file_io:runtime_error', ...
        'attempting to put data using non-initialized file-accessor')
end
% ensure file is opened in write mode
obj = reopen_to_write(obj);

% identify the blocks to change
bl_names_to_change = parse_addifional_input(obj,varargin{:});
BAT           = obj.bat_;
n_blocks      = BAT.n_blocks;
all_bl_names  = BAT.block_names;
% store current block state to return to it later
was_locked = false(1,n_blocks);

% unlock the blocks we want to change
for i=1:n_blocks
    was_locked(i) =  BAT.blocks_list{i}.locked;
    if keep_locked && was_locked(i)
        continue;
    end
    if ismember(all_bl_names{i},bl_names_to_change) % is requested
        BAT.blocks_list{i}.locked  = false;
    else
        BAT.blocks_list{i}.locked  = true;
    end
end
% clear size and position information about the blocks which should be modified
BAT = BAT.clear_unlocked_blocks();
%
% identify the modified blocks sizes and found their places in BAT
BAT = BAT.place_undocked_blocks(obj_to_write,nocache);
%
for i=1:n_blocks
    locked  = BAT.blocks_list{i}.locked;
    BAT.blocks_list{i}.locked = was_locked(i);
    if locked
        continue;
    end
    block = BAT.blocks_list{i};
    % store block in defined place in file
    if nocache
        block = block.put_sqw_block(obj.file_id_,obj_to_write,true);
    else
        block = block.put_sqw_block(obj.file_id_);
    end
    BAT.blocks_list{i} = block;
end
%
%
obj.bat_ = BAT;
obj.bat_.put_bat(obj.file_id_);
%
%==========================================================================
function bl_names_to_change = parse_addifional_input(obj,varargin)
% retrieve list of block names to change given input lists of block
% names to exclude from changes or block names to include in changes.
[exclude_kw,include_kw] = cellfun(@find_keyword,varargin);
excluded_provided = any(exclude_kw);
included_provided = any(include_kw);
if excluded_provided  && included_provided
    error('HORACE:file_io:invalid_argument', ...
        '"excluded" and "included" keywords can not be specified together')
end

if ~excluded_provided  && ~included_provided
    % change all unlocked blocks
    [bl_name,locked] = cellfun(@extract_locked,obj.bat_.blocks_list,'UniformOutput',false);
    locked = [locked{:}];
    bl_names_to_change = bl_name(~locked);
    return;
end
existing_bl_names = obj.bat_.block_names();
if excluded_provided
    kw_num        = find(exclude_kw);
    list_provided = varargin{kw_num+1};
end
if included_provided
    kw_num        = find(include_kw);
    list_provided = varargin{kw_num+1};
end
if istext(list_provided)
    list_provided = {list_provided};
end
known_names = ismember(list_provided,existing_bl_names);
if ~all(known_names)
    unknown_names = list_provided(~known_names);
    error('HORACE:file_io:invalid_argument', ...
        ['The block name(s): "%s" are not familiar to faccessor %s\n', ...
        'Known block names are:\n %s'],...
        disp2str(unknown_names),class(obj),disp2str(existing_bl_names));
end
if  excluded_provided
    is_excluded = ismember(existing_bl_names,list_provided);
    bl_names_to_change = existing_bl_names(~is_excluded);
else
    bl_names_to_change = list_provided;
end

%
function [is_exclue,is_include] = find_keyword(val)
is_exclue = false;
is_include = false;
if ~istext(val)
    return;
end
is_exclue = strncmp(val,'exclude',7);
is_include = strncmp(val,'include',7);
%
function [bl_name,is_locked] = extract_locked(bl)
bl_name   = bl.block_name;
is_locked = bl.locked;