function  [obj,file_exist] = set_file_to_update(obj,filename)
% Set filename to save sqw data and open file for write/append/update
% operations
%
% Usage
% >> obj = obj.set_file_to_update(); % reopen existing file for
%          write/update operations and initialize appropriate update information
%
% >> obj = obj.set_file_to_update(new_filename);
%
% Open new or existing sqw file to perform write/append operations
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%
if ~exist('filename','var')
    filename = '';
end

file_exist = false;

if nargout < 1
    error('SQW_FILE_IO:invalid_argument',...
        'set_file_to_update has to return its value in output object')
end

log_level = config_store.instance().get_value('herbert_config','log_level');

old_ldr = [];
if nargin>1
    new_filename = filename;
    if ~ischar(new_filename)
        error('SQW_FILE_IO:invalid_argument',...
            'set_file_to_update: new filename to save needs to be a string')
    end
    if exist(new_filename,'file')
        file_exist = true;
        try
            old_ldr = sqw_formats_factory.instance().get_loader(new_filename);
        catch
            file_exist = false;
            if log_level > 1
                fprintf('*** Existing file:  %s will be overwritten.\n',new_filename);
            end
            
        end
        
    end
else
    if isempty(obj.filename)
        error('SQW_FILE_IO:invalid_argument',...
            'set_file_to_update: trying to reopen existing file for writing but its filename is empty')
    end
    new_filename  = fullfile(obj.filepath,obj.filename);
    if obj.file_id_ > 0
        file_exist = true;
        [old_filename,access_rights] = fopen(obj.file_id_);
        if strcmp(new_filename,old_filename)
            if ismember(access_rights,{'+wb','rb+'}) % nothing to do;
                return;
            else
                clear obj.file_closer_;
                if obj.file_id_ > 0  % this should never happen unless subtle MATLAB bug
                    fclose(obj.file_id_);
                    obj.file_id_ = -1;
                end
            end
        end
    else
        if exist(new_filename,'file')
            file_exist = true;
        end
    end
end
%
upgrading_this = false;
if file_exist
    if ischar(obj.num_dim) % existing reader is not defined. Lets return loader,
        obj = old_ldr.reopen_to_write(); %already selected as best for this file by loaders factory
        return
    else
        upgrading_this = true;
    end
    perm = 'rb+';
else
    perm = 'wb+';
end
%-------------------------------------------------------------------------
[fp,fn,fext] = fileparts(new_filename);
if isempty(fp)
    fp = '.';
end

fn = [fn,fext];
fp = [fp,filesep];
obj.filename_ = fn;
obj.filepath_ = fp;
%
obj.file_id_ = fopen([fp,fn],perm);
%
if obj.file_id_ <=0
    error('SQW_FILE_IO:io_error',...
        'set_file_to_update: Can not open file %s to write data',[fp,fn])
end
obj.file_closer_ = onCleanup(@()obj.fclose());
%-------------------------------------------------------------------------

if file_exist
    if upgrading_this
        this_pos = obj.get_pos_info();
        upgrade_map = const_blocks_map(this_pos);
        obj.upgrade_map_ = upgrade_map;
        if log_level>1;   fprintf('*** Existing file:  %s can be upgraded with new object data.\n',new_filename);  end
        return;
    end
    
    if isempty(old_ldr) && log_level > 1
        fprintf('*** Existing file:  %s will be overwritten.\n',new_filename);
        return
    end
    can_upgrade = sqw_formats_factory.instance().check_compatibility(old_ldr,obj);
    if ~can_upgrade
        if log_level > 1;  fprintf('*** Existing file:  %s will be overwritten.\n',new_filename);end
        return
    end
    [ok,upgrade_map] = check_upgrade(obj,old_ldr,log_level);
    if ~ok
        obj.upgrade_map_ = [];
        if log_level > 1; fprintf('*** Existing file:  %s will be overwritten.\n',new_filename); end
    else
        old_ldr = old_ldr.fclose(); % close old loader input file to avoid copying file permissions
        obj = obj.copy_contents(old_ldr,true);
        obj.upgrade_map_ = upgrade_map;
        if log_level>1;   fprintf('*** Existing file:  %s can be upgraded with new object data.\n',new_filename);  end
    end
    
else
    obj.upgrade_map_ = [];
end

function [ok,upgrade_map_obj] = check_upgrade(obj,old_ldr,log_level)
%
this_pos = obj.get_pos_info();
this_map = const_blocks_map(this_pos);



other_pos       = old_ldr.get_pos_info();
upgrade_map_obj = const_blocks_map(other_pos);

[ok,mess] = upgrade_map_obj.check_equal_sizes(this_map);
if ~ok && log_level>1
    fprintf('*** %s\n',mess);
end


