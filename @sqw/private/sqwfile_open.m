function [S, mess] = sqwfile_open (file, opt)
% Open an sqw file for reading or writing, checking valid file if not 'new'.
%
%   >> [S, mess] = sqwfile_open (file)
%   >> [S, mess] = sqwfile_open (file, 'new')
%   >> [S, mess] = sqwfile_open (file, 'old')
%   >> [S, mess] = sqwfile_open (file, 'readonly')
%
% Input:
% ------
%   file    Name of file to which to read or write data.
%           If the file already exists (i.e. will be opened for reading and
%          writing, or readonly) then it must be a valid sqw file. An error
%          will be thrown if it is not.
%
%           An sqw file means one of:
%           - file with data for an sqw or dnd object
%           - buffer data (i.e. npix and pix information only)
%           The formats can be non-sparse or sparse. For full details of the
%           format
%         
%
%   opt     [Optional] file creation status:
%               'old'       Open an existing file for reading and writing.
%                          Error if the file doesn't exist.
%               'new'       Open a file for reading and writing
%                          Discarding all contents if the file already exists
%               'readonly'  Open an existing file for reading only.
%
%           Default if not given:
%                           Open an existing file for reading and writing
%                          Create a new file if doesn't already exist
%
% Output:
% -------
%   S       sqwfile structure with the information read from the
%          contents of an existing file
%
%   mess    Message:
%               - if no problem, then mess=''
%               - if a problem, then contains error message


% Original author: T.G.Perring
%
% $Revision: 882 $ ($Date: 2014-07-20 10:12:36 +0100 (Sun, 20 Jul 2014) $)


% Parse optional argument
% -----------------------
if nargin==1
    permission='rb+';
    check_exists=false;
    
elseif ~isempty(opt) && is_string(opt)
    if strcmpi(opt,'new')
        permission='wb+';
        check_exists=false;
    elseif strcmpi(opt,'old')
        permission='rb+';
        check_exists=true;
    elseif strcmpi(opt,'readonly')
        permission='rb';
        check_exists=true;
    else
        mess='Unrecognised optional argument';
        S=sqwfile(); return
    end
    
else
    mess='Invalid optional argument';
    S=sqwfile(); return
end


% Check file and open
% -------------------
if ~isempty(file) && is_string(file) % assume file is a file name
    % Check file exists, if required
    if check_exists && ~exist(file,'file')
        mess=['File does not exist: ',strtrim(file)];
        S=sqwfile(); return
    end
    
    % Open the file
    fid=fopen(file,permission);
    if fid<0
        mess=['Unable to open file: ',strtrim(file)];
        S=sqwfile(); return
    end

    % Read the information block from the sqw file (call even if new file)
    [mess, S] = get_sqw_information (fid);
    
    % Close file if there was an error
    if ~isempty(mess)
        if ~isempty(fopen(fid)), fclose(fid); end
    end
    
else
    mess='File name must be a non-empty character string';
    S=sqwfile(); return
    
end
