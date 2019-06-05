function [ok,mess,filename,filepath]=put_mask(data,file)
% Writes ASCII .msk file
%   >> [ok,mess,filename,filepath]=put_map(data,file)
%
% The format of the file is described in get_parObject.
%
% Input:
% ------
%   data            Mask object
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
    str=iarray_to_str(data.msk);
    fid=fopen(file_tmp,'wt');
    for j=1:numel(str)
        fprintf(fid,'%s \n', str{j});
    end
    fclose(fid);
    ok=true;
    mess='';
    
catch
    if exist('fid','var') && fid>0 && ~isempty(fopen(fid)) % close file, if open
        fclose(fid);
    end
    ok=false;
    mess=['Error writing .msk file data to ',file_tmp]';
    filename='';
    filepath='';
end
