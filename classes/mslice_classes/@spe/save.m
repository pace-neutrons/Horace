function save (w, file)
% Save a spe object to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
%   w       spe object (single object only, not an array)
%   file    [optional] File for output. if none given, then prompted for a file

% Original author: T.G.Perring


% Get file name - prompting if necessary
% --------------------------------------
if ~exist('file','var'), file='*.spe'; end
[file_full,ok,mess]=putfilecheck(file);
if ~ok, error(mess), end

% Write data to file
% ------------------
disp(['Writing spe to ',file_full,'...'])
[ok,mess] = put_spe (w,file_full);
if ~ok; error(mess); end
