function [Sout, mess] = sqwfile_close (S)
% Close an sqw file for reading or writing
%
%   >> [S, mess] = sqwfile_open (S)
%
% Input:
% ------
%   S       sqwfile structure with the information read from the
%          contents of an existing file
%
% Output:
% -------
%   Sout    Output sqwfile structure. If succesfully close, then
%          the fid and filename are set to -1 and '', but all other data
%          are left untouched
%   mess    Error message; if any problems closing then mess
%          contains error message; ='' if all OK

fid=S.fid;
if fid>=3 && ~isempty(fopen(fid))
    Sout=S;
    Sout.fid=-1;
    Sout.filename='';
    status=fclose(fid);
    if status~=0
        Sout=sqwfile();
        mess=['Unable to close sqwfile ',fopen(fid)];
    end
else
    Sout=sqwfile();
    mess='Input sqwfile structure does not correspond to an open file';
end
