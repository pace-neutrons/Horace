function line = fget_line (fid)
% Read a line from ascii file, skipping those which are empty or whose first character is '!' or '%'
%
%   >> line=fget_line(fid)
%
%   fid     File identifier of an open ascii file
%   line    Character string stripped of leading and trailing white space, and of any trailing comment,
%          the start of which is indicated by '!' or '%'
%           =-1 if end of file reached
%
% If error reading from file, then will close the file before failing


% Read data from file
% ---------------------
line='';
while ~isnumeric(line)
    try
        line = fgetl(fid);
        if ischar(line)
            line=strtrim(line);
            if ~(isempty(line) || strcmp(line(1:1),'!') || strcmp(line(1:1),'%'))
                icomm=min([strfind(line,'!'),strfind(line,'%')]);  % start of comment, if any
                if ~isempty(icomm)
                    line=strtrim(line(1:icomm-1));
                end
                return
            end
        end
    catch
        fclose(fid);
        rethrow(lasterror)
    end
end
