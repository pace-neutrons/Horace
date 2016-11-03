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
% $Revision: 1312 $ ($Date: 2016-11-02 16:28:29 +0000 (Wed, 02 Nov 2016) $)
%

file_exist = false;

if nargout < 1
    error('SQW_FILE_IO:invalid_argument',...
        'DND_BINFILE_COMMON:set_file_to_write has to return its value in output object')
end

if nargin>1
    new_filename = varargin{1};
    if ~ischar(new_filename)
        error('SQW_FILE_IO:invalid_argument',...
            'DND_BINFILE_COMMON:set_file_to_write: new filename to save needs to be a string')
    end
    if exist(new_filename,'file')
        file_exist = true;
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
if file_exist
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
    header = dnd_file_interface.get_file_header(obj.file_id_,perm);
    if ~strcmp(header.name,'horace')
        error('SQW_FILE_IO:invalid_argument',...
            'DND_BINFILE_COMMON:set_file_to_write: trying to write to existing file %s but it is not a horace file',...
            new_filename);
    end
    if strncmp(obj.num_dim_,'un',2)
        obj.num_dim_  = double(header.num_dim);
    else
        if obj.num_dim ~= header.num_dim
            error('SQW_FILE_IO:invalid_argument',...
                ['DND_BINFILE_COMMON:set_file_to_write: trying to set existing file %s for modifications,\n'...
                ' but the number of existing dimensions in the file %d \n'...
                ' is different from number of dimensions %d defined by the access object'],...
                new_filename,header.num_dim,obj.num_dim)
        end
    end
    obj.sqw_type_= header.sqw_type;
    
    fseek(obj.file_id_,0,'eof');
    obj.real_eof_pos_ = ftell(obj.file_id_);
end

