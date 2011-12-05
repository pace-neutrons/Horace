function [data,ok,mess]=get_spe(filename)
% Load ASCII .spe file
%   >> [data,ok,mess]=get_spe(filename)
%
% data has following fields:
%   data.filename   Name of file excluding path
%   data.filepath   Path to file including terminating file separator
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries

% T.G.Perring   13/6/07
%
% DOES convert data <= -10^30 to NaN, contrary to mslice convention

ok=true;
mess='';

% Remove blanks from beginning and end of filename
file_tmp=strtrim(filename);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(file_tmp);
data.filename=[name,ext];
data.filepath=[path,filesep];


% Read spe file
try
    [data.S,data.ERR,data.en]=get_spe_mex(file_tmp);
catch       % try matlab algorithm
    try
        disp(['Matlab loading of .spe file : ' file_tmp]);
        [data.S,data.ERR,data.en]=get_spe_matlab(file_tmp);
    catch
        ok=false;
        mess='Unable to read spe file.';
        return
    end
end

% Put NaN for data <=10^30:
null_data = -1.0e30;    % conventional NaN in spe files
index=~isfinite(data.S)|data.S<=null_data|~isfinite(data.ERR);
if sum(index(:)>0)
    data.S(index)=NaN;
    data.ERR(index)=0;
end

[ne,ndet]=size(data.S);
disp(['Loaded spe data ( ' num2str(ndet) ' detector(s) and ' num2str(ne) ' energy bin(s)) from file : ']);
disp(file_tmp);
