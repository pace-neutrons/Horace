function  [obj,file_exist] = set_filename_to_write(obj,varargin)
% set filename to save sqw data and open file for write/append
% operations
%
% Usage
% >> obj = obj.set_filename_to_write(); % reopen existing file for
%          write/append operations
% >> obj = obj.set_filename_to_write(new_filename);
%   Open new sqw file to perform write/append operations

file_exist = false;

if nargout < 1
    error('DND_BINFILE_COMMON:invalid_argument',...
        'set_filename_to_write has to return its value in ouptput DND_BINFILE_COMMON object')
end

if nargin>1
    new_filename = varargin{1};
    if ~ischar(new_filename)
        error('DND_FILE_INTERFACE:invalid_argument',...
            'set_filename_to_write: new filename to save needs to be a string')
    end
    if exist(new_filename,'file')
        file_exist = true;
    end
else
    if isempty(obj.filename)
        error('DND_FILE_INTERFACE:invalid_argument',...
            'set_filename_to_write: trying to reopen file to write but its filename has not been set up')
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
if file_exist
    perm = 'rb+';
else
    perm = 'wb+';
    obj.sqw_type_= false;
    obj.num_dim_ = 'undefined';    
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
    error('DND_BINFILE_COMMON:io_error',...
        ' Can not open file %s to write data',[fp,fn])
end
obj.file_closer_ = onCleanup(@()obj.fclose());
%-------------------------------------------------------------------------

if file_exist
    header = dnd_file_interface.get_file_header(obj.file_id_,perm);
    if ~strcmp(header.name,'horace')
        error('DND_BINFILE_COMMON:invalid_argument',...
            'set_filename_to_write: trying to write to existing file %s but it is not a horace file',...
            new_filename);
    end
    if strncmp(obj.num_dim_,'un',2)
        obj.num_dim_  = double(header.num_dim);
    else
        if obj.num_dim ~= header.num_dim
            error('DND_BINFILE_COMMON:invalid_argument',...
                ['set_filename_to_write: trying to set existing file %s for modifications,\n'...
                ' but the number of existing dimensions in the file %d \n'...
                ' is different from number of dimensions %d defined by the access object'],...
                new_filename,header.num_dim,obj.num_dim)
        end
    end
    obj.sqw_type_= header.sqw_type;
    
    fseek(obj.file_id_,0,'eof');
    obj.real_eof_pos_ = ftell(obj.file_id_);
end

