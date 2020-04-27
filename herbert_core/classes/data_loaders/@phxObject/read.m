function wout = read (wdummy, file)
% Read mslice/Tobyfit par data from a file
% 
%   >> w=read(phxObject)          % prompts for file
%   >> w=read(phxObject,file)
%
% Need to give first argument as phx data object to enforce the execution of this method.
% Can simply create a dummy object with a call to phxObject:
%    e.g. >> read(phxObject,'c:\temp\my_file.phx')

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.phx'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=phxObject(file_full);
