function wout = read (wdummy, file)
% Read mslice/Tobyfit slice object from a file
% 
%   >> w=read(slice)          % prompts for file
%   >> w=read(slice,file)
%
% Need to give first argument as slice object to enforce the execution of this method.
% Can simply create a dummy object with a call to slice:
%    e.g. >> read(slice,'c:\temp\my_file.slc')

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.slc'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=slice(file_full);
