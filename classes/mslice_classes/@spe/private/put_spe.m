function [ok,mess,filename,filepath]=put_spe(data,file)
% Writes ASCII .spe file
%   >> [ok,mess,filename,filepath]=put_spe(data,file)
%
% The format is described in get_spe. Must make sure get_spe and put_spe are consistent.
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true
%   filename        Name of file excluding path; empty if problem
%   filepath        Path to file including terminating file separator; empty if problem

% T.G.Perring   15 August 2009

ok=true;
mess='';

null_data = -1.0e30;    % conventional NaN in spe files

% Remove blanks from beginning and end of filename
file_tmp=strtrim(file);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(file_tmp);
filename=[name,ext];
filepath=[path,filesep];

% Prepare data for Fortran routine
index=~isfinite(data.S)|data.S<=null_data|~isfinite(data.ERR);
if sum(index(:)>0)
    data.S(index)=null_data;
    data.ERR(index)=0;
end

% Write to file
try
    ierr=put_spe_mex(file_tmp,data.S,data.ERR,data.en);
    if round(ierr)~=0
        error(['Error writing spe data to ',file_tmp])
    end
catch
    try     % matlab write
        disp(['Matlab writing of .spe file : ' file_tmp]);
        [ok,mess]=put_spe_matlab(data,file_tmp);
        if ~ok
            error(mess)
        end
    catch
        ok=false;
        mess=['Error writing spe data to ',file_tmp]';
        filename='';
        filepath='';
    end
end
