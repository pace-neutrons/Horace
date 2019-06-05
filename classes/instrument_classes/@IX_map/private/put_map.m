function [ok,mess,filename,filepath]=put_map(data,file)
% Writes ASCII .map file
%   >> [ok,mess,filename,filepath]=put_map(data,file)
%
% The format of the file is described in get_parObject.
%
% Input:
% ------
%   data            Map object
%   file            File name
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem

% T.G.Perring   20 September 2013


% Check file OK to write to
[file_tmp,ok,mess]=translate_write(strtrim(file));
if ok
    [path,name,ext]=fileparts(file_tmp);
    filename=[name,ext];
    filepath=[path,filesep];
else
    filename=''; filepath='';
    return
end

% Write ascii file
try
    nw=numel(data.ns);
    ns=data.ns;
    nend=cumsum(data.ns);
    nbeg=nend-data.ns+1;
    s=data.s;
    if ~isempty(data.wkno)
        wkno=data.wkno;
    else
        wkno=1:nw;
    end
    fid=fopen(file_tmp,'wt');
    fprintf(fid,'%d \n',nw);
    for i=1:nw
        fprintf(fid,'%d \n',wkno(i));
        fprintf(fid,'%d \n',ns(i));
        if ns(i)>1
            str=iarray_to_str(s(nbeg(i):nend(i)));
            for j=1:numel(str)
                fprintf(fid,'%s \n', str{j});
            end
        elseif ns(i)==1
            fprintf(fid,'%d \n',s(nbeg(i)));
        end
    end
    fclose(fid);
    ok=true;
    mess='';
    
catch
    if exist('fid','var') && fid>0 && ~isempty(fopen(fid)) % close file, if open
        fclose(fid);
    end
    ok=false;
    mess=['Error writing .map file data to ',file_tmp]';
    filename='';
    filepath='';
end
