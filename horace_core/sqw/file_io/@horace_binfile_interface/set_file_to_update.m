function  [obj,file_exist,old_ldr] = set_file_to_update(obj,filename,varargin)
% Set filename to save sqw data and open file for write/append/update
% operations
%
% Usage
% >> obj = obj.set_file_to_update(); % reopen existing file for
%          write/update operations
%
% >> obj = obj.set_file_to_update(new_filename);
%
% Open new or existing sqw file to perform write/append operations
%
% Ouptputs:
% obj        -- the loader object initialized properly to handle update
%               or write operations
% file_exist -- true if file to open already exist
% old_ldr    -- if file exists and is written in old file format, the
%               loader, used to load the file. empty if file_exist is false
%
if ~exist('filename','var')
    filename = '';
end
nout = nargout;
if ~isempty(varargin) && isnumeric(varargin{1})
    nout = varargin{1};
end

file_exist = false;

if nout < 1
    error('HORACE:horace_binfile_interface:invalid_argument',...
        'set_file_to_update has to return its value in output object')
end

log_level = config_store.instance().get_value('herbert_config','log_level');

old_ldr = [];
if nargin>1
    new_filename = filename;
    if ~ischar(new_filename)
        error('HORACE:horace_binfile_interface:invalid_argument',...
            'new filename to save needs to be a string')
    end
    if exist(new_filename,'file')
        file_exist = true;
        try
            old_ldr = sqw_formats_factory.instance().get_loader(new_filename,'-upgrade');
        catch ME
            file_exist = false;
            if log_level > 1
                fprintf('*** Existing file:  %s will be overwritten.\n',new_filename);
            end
        end
    end
else % reopening existing file with old name
    if isempty(obj.filename)
        error('HORACE:horace_binfile_interface:invalid_argument',...
            'Trying to reopen existing file for writing but its filename is empty')
    end
    new_filename  = obj.full_filename;
    if obj.file_id_ > 0
        file_exist = true;
        [old_filename,access_rights] = fopen(obj.file_id_);
        if strcmp(new_filename,old_filename)
            if ismember(access_rights,{'+wb','rb+'}) % nothing to do;
                old_ldr = obj;
                return;
            else
                clear obj.file_closer_;
                obj = obj.fclose(); % this should not be necessary, unless Matlab delays clearing the memory above
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
        old_ldr = obj;
        return
    end
    perm = 'rb+';
else
    perm = 'wb+';
end
%-------------------------------------------------------------------------
obj.full_filename = new_filename;

if isempty(old_ldr)
    old_ldr = obj;
end
%
obj.file_id_ = fopen(obj.full_filename,perm);

if obj.file_id_ <=0
    error('HORACE:horace_binfile_interface:io_error',...
        'Can not open file %s to write data',obj.full_filename)
end
obj.file_closer_ = onCleanup(@()obj.fclose());
%-------------------------------------------------------------------------
