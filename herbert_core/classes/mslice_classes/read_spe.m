function wout = read_spe (file)
% Read mslice/Tobyfit spe object from a file
% 
%   >> w=read_spe          % prompts for file
%   >> w=read_spe(file)

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.spe'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=spe(file_full);
