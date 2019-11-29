function wout = read (wdummy, file)
% Read mslice/Tobyfit spe object from a file
% 
%   >> w=read(spe)          % prompts for file
%   >> w=read(spe,file)
%
% Need to give first argument as spe object to enforce the execution of this method.
% Can simply create a dummy object with a call to spe:
%    e.g. >> read(spe,'c:\temp\my_file.spe')

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.spe'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=spe(file_full);
