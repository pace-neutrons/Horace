function save (w, file)
% Save a slice object to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
%   w       slice object (single object only, not an array)
%   file    [optional] File for output. if none given, then prompted for a file

% Original author: T.G.Perring


% Get file name - prompting if necessary
% --------------------------------------
if ~exist('file','var'), file='*.slc'; end
[file_full,ok,mess]=putfilecheck(file);
if ~ok, error(mess), end

% Write data to file
% ------------------
if get(herbert_config,'log_level')>-1	
	disp(['Writing slice to ',file_full,'...'])
end
[ok,mess] = put_slice (w,file_full);
if ~ok; error(mess); end
