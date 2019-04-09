function obj = reopen_to_write(obj,filename)
% reopen already opened file in read-write mode (rb+) or
% specify new filename to write and open it in write mode.
%
% Usage:
%>>obj= obj.reopen_to_write();
% or
%>>obj= obj.reopen_to_write(filename);
% Where first form reopens/opens file with filename which already set up in
% the object (e.g. object has been initialized to read data) 
% and the second form sets up new filename and opens it in write mode
%
% 
% If file with filename exist, it will be overwritten
%
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
%
%
if ~exist('filename','var')
    filename = '';
else
    if isnumeric(filename)
        [fname,acc] = fopen(filename);
        if isempty(fname)
            error('SQW_FILE_IO:invalid_argument',...
                'reopen_to_write: wrong file handle specified as input')
            
        end
        if ~ismember(acc,{'wb+','rb+'})
            error('SQW_FILE_IO:invalid_argument',...
                'reopen_to_write: get input file handle with incorrect file access for file %s',fname);
        end
        obj=fclose_file(obj);
        obj.file_id_ = fname;
        [fp,fn,fext] = fileparts(fname);
        obj.filename_ = [fn,fext];
        obj.filepath_ = [fp,filesep];
        obj.file_closer_ = onCleanup(@()obj.fclose());
        return;
    else
        if ~ischar(filename)
            error('SQW_FILE_IO:invalid_argument',...
                'reopen_to_write: wrong type variable "filename" specified as input')
            
        end
    end
end

if isempty(obj.filename) && isempty(filename)
    error('SQW_FILE_IO:runtime_error',...
        'reopen_to_write: can not reopen file if filename is not defined')
end

if obj.file_id_ > 0 && isempty(filename)
    [~,acc] = fopen(obj.file_id_);
    if ismember(acc,{'wb+','rb+'}) % nothing to do, already correct mode
        return;
    end
end


obj = fclose_file(obj);
if ~isempty(filename)
    [fp,fn,fext] = fileparts(filename);
    obj.filename_ = [fn,fext];
    obj.filepath_ = [fp,filesep];
end

fname = fullfile(obj.filepath,obj.filename);
if exist(fname,'file') == 2
    fid = fopen(fname,'rb+');
else
    fid = fopen(fname,'wb+');
end
%
if fid<1
    error('SQW_FILE_IO:runtime_error',...
        'DND_BINFILE_COMMON::reopen_to_write: error reopening file %s in write access mode',...
        fname)
end
obj.file_id_ = fid;
obj.file_closer_ = onCleanup(@()obj.fclose());


function obj=fclose_file(obj)
if obj.file_id_>0
    clear obj.file_closer_; % This should close file
    fn = fopen(obj.file_id_);
    if ~isempty(fn)
        obj = obj.fclose();
    end
end


