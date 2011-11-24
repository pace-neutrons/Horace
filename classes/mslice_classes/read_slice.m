function wout = read_slice (file)
% Read mslice/Tobyfit slice object from a file
% 
%   >> w=read_slice          % prompts for file
%   >> w=read_slice(file)

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.slc'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=slice(file_full);
