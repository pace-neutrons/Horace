function wout = read (wdummy,file)
% Read object or array of objects of class type from binary file. Inverse of save.
%
%   >> w = read (IX_axis)          % prompts for file
%   >> w = read (IX_axis, file)    % read from named file

% Method independent of class type

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.mat'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
tmp=load(file_full,'-mat');    % enforce interpretation as matlab binary format
fname=fieldnames(tmp);
if numel(fname)==1 && strcmp(class(tmp.(fname{1})),class(wdummy))
    wout=tmp.(fname{1});
else
    error(['Content not an object of class ',class(wdummy),' in file ',file_full])
end
