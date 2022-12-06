function obj = reopen_to_write(obj,filename)
% reopen already opened file in read-write mode (rb+) or
% specify new filename to write and open it in the write mode (wb+).
%
% Usage:
%>>obj= obj.reopen_to_write();
% or
%>>obj= obj.reopen_to_write(filename);
% Where first form reopens/opens file with filename which already set up in
% the object (e.g. object has been initialized to read data)
% and the second form sets up new filename and opens it in write mode
%
% If file with filename exist, it will be overwritten
%
if ~exist('filename','var')
    filename = '';
else
    if isnumeric(filename)
        [fname,acc] = fopen(filename);
        if isempty(fname)
            error('HORACE:dnd_binfile_common:invalid_argument',...
                'Wrong (probably closed) file handle specified as input')

        end
        if ~ismember(acc,{'wb+','rb+'})
            error('HORACE:dnd_binfile_common:invalid_argument',...
                'Get input file handle with incorrect file access for file %s',fname);
        end
        obj=fclose_file(obj);
        obj.full_file_name = fname;
        obj.file_closer_ = onCleanup(@()obj.fclose());
        return;
    else
        if ~(ischar(filename)|| isstring(filename))
            error('HORACE:dnd_binfile_common:invalid_argument',...
                'Wrong type (%s) variable "filename" specified as input',...
                class(filename))

        end
    end
end

if isempty(obj.filename) && isempty(filename)
    error('HORACE:horace_binfile_interface:runtime_error',...
        'Can not reopen file: The filename is not defined either as input or as faccessor property')
end

if obj.file_id_ > 0 && isempty(filename)
    [~,acc] = fopen(obj.file_id_);
    if ismember(acc,{'wb+','rb+'}) % nothing to do, already correct mode
        return;
    end
end


obj = fclose_file(obj);
if ~isempty(filename)
    obj.full_filename = filename;
end

fname = obj.full_filename;
if exist(fname,'file') == 2
    fid = fopen(fname,'rb+');
else
    fid = fopen(fname,'wb+');
end
%
if fid<1
    error('HORACE:dnd_binfile_common:runtime_error',...
        'Error reopening file %s in write access mode',...
        fname)
end
obj.file_id_      = fid;
obj.file_closer_  = onCleanup(@()obj.fclose());



function obj=fclose_file(obj)
if obj.file_id_>0
    clear obj.file_closer_; % This should close file
    % everything else -- to ensure Matlab/jave memory allocation strategy
    % does not mess thing out
    obj = obj.fclose();
    obj.file_closer_ = [];
end
