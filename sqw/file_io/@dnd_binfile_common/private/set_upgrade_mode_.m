function  obj = set_upgrade_mode_(obj,mode)
% Set up or initiate the upgrade mode, i.e. calculate constant blocks map
% and prepare the file info for upgrade or disable such mode
%
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%

mode = logical(mode);
if mode
    if ischar(obj.num_dim_) || ischar(obj.dnd_dimensions_)
        error('SQW_FILE_IO:runtime_error',...
            'DND_BINFILE_COMMON::set.upgrade_mode: update mode requested for un-initialized object')
    end
    % set up info for upgrade mode and the mode itself
    pos_map = obj.get_pos_info();
    obj.upgrade_map_ = const_blocks_map(pos_map);
else
    obj.upgrade_map_ = [];
end

