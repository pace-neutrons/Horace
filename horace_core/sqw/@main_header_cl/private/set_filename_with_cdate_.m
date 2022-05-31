function obj = set_filename_with_cdate_(obj,val)
% take filename and file creation date as it would be
% stored in Horace binary file version 3.xxxx, separate it into parts
% and set parts as appropriate properties of the main_header class.
%
% If filename is mangled with file creation date, the file
% creation date becomes "known";


if ~(ischar(val) || isstring(val))
    error('HORACE:main_header:invalid_argument', ...
        'filename with creatrion data has to be a string Actually it is: %s',...
        class(val));
end
pos = strfind(val,'$');
if isempty(pos)
    obj.creation_date_defined_ = false;
    obj.filename_ = val;
else
    % this also makes file_creation date known within creation date
    % asignment
    obj.creation_date = val(pos+1:end);
    obj.filename_   = val(1:pos-1);
end
