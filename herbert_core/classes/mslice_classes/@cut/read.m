function wout = read (wdummy, file)
% Read mslice/Tobyfit cut object from a file
% 
%   >> w=read(cut)          % prompts for file
%   >> w=read(cut,file)
%
% Need to give first argument as cut object to enforce the execution of this method.
% Can simply create a dummy object with a call to cut:
%    e.g. >> read(cut,'c:\temp\my_file.cut')

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.cut'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=cut(file_full);
