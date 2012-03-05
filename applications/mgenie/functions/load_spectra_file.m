function sp = load_spectra_file (file)
% Reads s full format spectra.dat file into a structure
%
% Syntax
%   >> sp = load_spectra_file           % prompts for file
%   >> sp = load_spectra_file (file)    % read from named file
%
%   sp.det      detector numbers, in the order they were read form the file
%   sp.spec     corresponding spectrum numbers
%

% T.G.Perring  3 August 2010

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.dat'; end
[file_internal,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Open file
% ---------
fid=fopen(file_internal,'rt');
if fid<0
    error(['Cannot open spectra file ',file_internal])
end

% Read data from file
% ---------------------
% Have a try...catch block so that wherever the failure takes place, the file can always be closed and the error thrown
try
    tline = fgets(fid);
    if ischar(tline) && numel(tline)>=4 && strcmpi(tline(1:4),'ndet')
        tline = fgets(fid);
        tline = fgets(fid);
        a = fscanf(fid,'%g %g',[2,inf]);
    else
        error('Check format of spectra.dat file')
    end
    fclose (fid);
catch
    fclose(fid);
    rethrow(lasterror)
end

sp.det=a(1,:);
sp.spec=a(2,:);

disp (['Data read from ' file_internal])
