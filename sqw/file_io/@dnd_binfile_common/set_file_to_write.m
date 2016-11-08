function  [obj,file_exist] = set_file_to_write(obj,varargin)
% set filename to save sqw data and open file for write/append
% operations
%
% Usage
% >> obj = obj.set_file_to_write(); % reopen existing file for
%          write/append operations
% >> obj = obj.set_file_to_write(new_filename);
%
% Open new or existing sqw file to perform write/append operations
%
% $Revision$ ($Date$)
%

file_exist = false;

if nargout < 1
    error('SQW_FILE_IO:invalid_argument',...
        'DND_BINFILE_COMMON:set_file_to_write has to return its value in output object')
end

log_level = get(hor_config,'log_level');

old_ldr = [];
if nargin>1
    new_filename = varargin{1};
    if ~ischar(new_filename)
        error('SQW_FILE_IO:invalid_argument',...
            'DND_BINFILE_COMMON:set_file_to_write: new filename to save needs to be a string')
    end
    if exist(new_filename,'file')
        file_exist = true;
        try
            old_ldr = sqw_formats_factory.instance().get_loader(new_filename);
        catch
            file_exist = false;
            if log_level > 0
                sprintf('*** Existing file:  %s will be overwritten.',new_filename);
            end
            
        end
        
    end
else
    if isempty(obj.filename)
        error('SQW_FILE_IO:invalid_argument',...
            'DND_BINFILE_COMMON:set_file_to_write: trying to reopen existing file for writing but its filename is empty')
    end
    new_filename  = fullfile(obj.filepath,obj.filename);
    if obj.file_id_ > 0
        file_exist = true;
        [old_filename,access_rights] = fopen(obj.file_id_);
        if strcmp(new_filename,old_filename)
            if access_rights == '+wb' % nothing to do;
                return;
            else
                obj.file_closer_ = [];
                if obj.file_id_ > 0
                    fclose(obj.file_id_); % this should never happen unless subtle MATLAB bug
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
if file_exist
    if ischar(obj.num_dim) % existing reader is not defined. Lets return loader,
        obj = old_ldr.reopen_to_write(); %already selected as best for this file by loaders factory
        return
    end
    perm = 'rb+';
else
    perm = 'wb+';
end
%-------------------------------------------------------------------------
[fp,fn,fext] = fileparts(new_filename);
fn = [fn,fext];
fp = [fp,filesep];
obj.filename_ = fn;
obj.filepath_ = fp;
%
obj.file_id_ = fopen([fp,fn],perm);
%
if obj.file_id_ <=0
    error('SQW_FILE_IO:io_error',...
        'DND_BINFILE_COMMON:set_file_to_write: Can not open file %s to write data',[fp,fn])
end
obj.file_closer_ = onCleanup(@()obj.fclose());
%-------------------------------------------------------------------------

if file_exist
    if isempty(old_ldr) && log_level > 0
        sprintf('*** Existing file:  %s will be overwritten.',new_filename);
        return
    end
    can_upgrade = sqw_formats_factory.instance().check_compartibility(old_ldr,obj);
    if ~can_upgrade
        if log_level > 0;  sprintf('*** Existing file:  %s will be overwritten.',new_filename);end
        return
    end
    [ok,upgrade_map] = check_upgrade(obj,old_ldr,log_level);
    if ~ok
        obj.upgrade_map_ = [];
        if log_level > 0; sprintf('*** Existing file:  %s will be overwritten.',new_filename); end
    else
        obj.upgrade_map_ = upgrade_map;
        if log_level>0;   sprintf('*** Existing file:  %s will be upgraded with new object data',new_filename);  end
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

[ok,mess] = upgrade_map_obj.check_equal_size(this_map);
if log_level>0
    sprintf('*** %s',mess);
end

