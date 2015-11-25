function [Sout, mess] = sqwfile_close (S,opt)
% Close an sqw file or set of files for reading or writing
%
%   >> [S, mess] = sqwfile_close (S)
%
% Input:
% ------
%   S       sqwfile structure or array of sqwfile structures with the
%          information read from the contents of an existing file.
%   opt     If opt=='delete' then the file is deleted after closing.
%
% Output:
% -------
%   Sout    Output sqwfile structure. If succesfully closed, then
%          the fid is set to -1, but all other data are left untouched
%           If there was an error (i.e. mess is not empty) then
%          the Sout==S, except Sout.fid=-1 if the file was closed.
%   mess    Error message; if any problems closing then mess
%          contains error message; ='' if all OK


% Original author: T.G.Perring
%
% $Revision: 882 $ ($Date: 2014-07-20 10:12:36 +0100 (Sun, 20 Jul 2014) $)


mess='';
deletefile=false;

% Check option
if nargin==2
    if is_string(opt) && strcmp(opt,'delete')
        deletefile=true;
    else
        mess='Invalid option to sqwfile_close - the option was ignored';
    end
end

% Loop over input
Sout=S;
for i=1:numel(S)
    [Sout(i),messtmp]=sqwfile_close_single(S(i),deletefile);
    if ~isempty(messtmp)
        if isempty(mess)
            mess=messtmp;
        else
            mess=[mess,'; ',messtmp];
        end
    end
end


%------------------------------------------------------------------------------
function [Sout,mess]=sqwfile_close_single(S,deletefile)
% Close a single file

Sout=S;
mess='';
fid=S.fid;
if fid>=3
    fname=fopen(fid);
    if ~isempty(fname)
        % Close file
        status=fclose(fid);
        if status~=0
            mess=['Unable to close sqwfile ',fname];
            return
        end
        Sout.fid=-1;
        % Delete file if requested
        if deletefile
            try
                delete(fname)
            catch
                mess=['Unable to delete sqwfile ',fname];
            end
        end
    else
        mess='Input sqwfile structure does not correspond to an open file';
    end
else
    mess='Invalid file identifier';
end
