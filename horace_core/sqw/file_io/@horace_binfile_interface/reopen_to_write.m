function [obj,permissions] = reopen_to_write(obj,filename)
% reopen already opened file in read-write mode (rb+) or
% specify new filename to write and open it in write mode (wb+).
%
% Usage:
%>>[obj,permissions] = obj.reopen_to_write();
% or
%>>[obj,permissions] = obj.reopen_to_write(filename);
%
% Where first form reopens/opens file with filename which already set up in
% the object (e.g. object has been initialized to read data)
% and the second form sets up new filename and opens it in write mode
%
% If file with filename exist, it will be overwritten
% Returns:
% obj         -- faccessor initiated for performing write operations
% permissions --
%
if ~exist('filename','var')
    filename = '';
else
    if isnumeric(filename)
        [fname,permissions] = fopen(filename);
        if isempty(fname)
            error('HORACE:horace_binfile_interface:invalid_argument',...
                'Wrong (probably closed) file handle specified as input')

        end
        if ~ismember(permissions,{'wb+','rb+'})
            error('HORACE:horace_binfile_interface:invalid_argument',...
                'Get input file handle with incorrect file access for file %s',fname);
        end
        obj=fclose_file(obj);
        obj.full_file_name = fname;
        return;
    else
        if ~istext(filename)
            error('HORACE:horace_binfile_interface:invalid_argument',...
                'Wrong type (%s) variable "filename" specified as input',...
                class(filename))

        end
    end
end

if isempty(obj.full_filename)
    error('HORACE:horace_binfile_interface:runtime_error',...
        'Can not reopen file: The filename is not defined either as input or as faccessor property')
end

if obj.file_id_ > 0 && isempty(filename)
    [filename,permissions] = fopen(obj.file_id_);
    if ismember(permissions,{'wb+','rb+'}) % nothing to do, already correct mode
        obj.full_filename = filename;
        return;
    end
end


obj = fclose_file(obj);
if ~isempty(filename)
    obj.full_filename = filename;
end

fname = obj.full_filename;
if exist(fname,'file') == 2
    permissions = 'rb+';
    obj.data_in_file_ = true;
else
    permissions = 'wb+';
    obj.data_in_file_ = false;
end
obj.file_id_ = sqw_fopen(fname,permissions);
if isempty(obj.file_closer_)
    obj.file_closer_  = fcloser(obj.file_id_);
end


function obj=fclose_file(obj)
if obj.file_id_>0
    obj.file_closer_.delete();
end
