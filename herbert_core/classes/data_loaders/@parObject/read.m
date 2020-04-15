function wout = read (wdummy, file)
% Read mslice/Tobyfit par data from a file
% 
%   >> w=read(parObject)          % prompts for file
%   >> w=read(parObject,file)
%
% Need to give first argument as par data object to enforce the execution of this method.
% Can simply create a dummy object with a call to parObject:
%    e.g. >> read(parObject,'c:\temp\my_file.par')

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.par'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=parObject(file_full);
