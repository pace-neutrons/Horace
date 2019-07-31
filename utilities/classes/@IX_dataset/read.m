function wout = read(file)
% Read object or array of objects of class type from binary file. Inverse of save.
%
%   >> w = IX_dataset.read()       % prompts for file
%   >> w = IX_dataset.read(file)   % read from named file

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
if numel(fname)==1 && isa(tmp.(fname{1}),'IX_dataset')
    wout=tmp.(fname{1});
else
    error('Content of file %s is not an object of class IX_dataset',file_full);
end
