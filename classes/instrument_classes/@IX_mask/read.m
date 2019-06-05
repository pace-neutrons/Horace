function wout = read (wdummy, file)
% Read mask data from a file
% 
%   >> w=read(IX_mask)          % prompts for file
%   >> w=read(IX_mask,file)
%
% Need to give first argument as mask object to enforce the execution of this method.
% Can simply create a dummy object:
%    e.g. >> read(IX_mask,'c:\temp\my_file.msk')

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.msk'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=IX_mask(file_full);
