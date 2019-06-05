function wout = read (wdummy, file)
% Read mapping data from a file
% 
%   >> w=read(IX_map)          % prompts for file
%   >> w=read(IX_map,file)
%
% Need to give first argument as mapping object to enforce the execution of this method.
% Can simply create a dummy object:
%    e.g. >> read(IX_map,'c:\temp\my_file.par')

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.map'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=IX_map(file_full);
