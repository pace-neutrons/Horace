function  [obj,file_exist,old_ldr] = set_file_to_update(obj,filename,varargin)
% Set filename to save sqw data and open file for write/append/update
% operations. Only common update/read/write code is defined here.
% Children should reuse it and add code to extract information necessary
% for updating file format.
%
% Usage:
% >> obj = obj.set_file_to_update();
% or
% >> obj = obj.set_file_to_update(new_filename);
%
% Inputs:
%  obj     --  the file defined in full_filename property used as input
%
% Optional:
% filename -- the file provided in filename is used as input for
%             full_filename operations.
% nargout  -- if provided, defines number of output arguments, requested by
%             calling function. Used for correct usage error control.
%
% Outputs:
% obj        -- the loader object initialized properly to handle update
%               or write operations
% file_exist -- true if file to open already exist
% old_ldr    -- if file exists and is written in old file format, the
%               loader, used to load the file. Empty if file_exist is false
%
if ~exist('filename','var')
    filename = '';
end
nout = nargout;
if ~isempty(varargin) && isnumeric(varargin{1})
    nout = varargin{1};
end
obj.data_in_file_ = false;
file_exist = false;

if nout < 1
    error('HORACE:horace_binfile_interface:invalid_argument',...
        'set_file_to_update has to return its value in output object')
end

log_level = config_store.instance().get_value('hor_config','log_level');

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
            old_ldr = sqw_formats_factory.instance().get_loader(new_filename,'-update');
            obj.data_in_file_ = true;
        catch ME % data_in_file == false anyway
            file_exist = false;
            if log_level > 1
                fprintf(2,'*** WARNING: Existing file:  %s will be fully overwritten.\n', ...
                    new_filename);
            end
        end
    end
else % reopening existing file with old name. Not used by new file format (after 01/01/2023)
    % still may be used by previous file formatters
    if isempty(obj.filename)
        error('HORACE:horace_binfile_interface:invalid_argument',...
            'Trying to reopen loader %s-defined file for writing but loader"s filename is empty', ...
            class(obj))
    end
    new_filename  = obj.full_filename;
    if obj.file_id_ > 0
        file_exist = true;
        [old_filename,access_rights] = fopen(obj.file_id_);
        if strcmp(new_filename,old_filename)
            if ismember(access_rights,{'+wb','rb+'}) % nothing to do;
                old_ldr = obj;
                obj.data_in_file_ = true;
                return;
            else
                obj = obj.fclose();
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
    obj.data_in_file_ = true;
    if ischar(obj.num_dim) % existing reader is not defined. Lets return loader,
        obj.file_closer_ = [];
        clear obj;
        obj = old_ldr.reopen_to_write(); %already selected as best for this file by loaders factory
        return
    end
    perm = 'rb+';
else
    perm = 'wb+';
    obj.data_in_file_ = false;
end
%-------------------------------------------------------------------------
obj.full_filename = new_filename;

if isempty(old_ldr)
    old_ldr = obj;
end
obj = obj.fclose();
obj.file_id_ = sqw_fopen(obj.full_filename,perm);

if obj.file_id_ <=0
    error('HORACE:horace_binfile_interface:io_error',...
        'Can not open file %s to write data',obj.full_filename)
end
if isempty(obj.file_closer_)
    obj.file_closer_ = onCleanup(@()fclose(obj));
end
%-------------------------------------------------------------------------
