function wout = read_phx (file)
% Read mslice .phx object from a file
% 
%   >> w=read_phx          % prompts for file
%   >> w=read_phx(file)

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.phx'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=phxObject(file_full);
