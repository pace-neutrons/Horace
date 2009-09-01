function save (w, file)
% Save a sqw object to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%
% Output:

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)


% Get file name - prompting if necessary
if (nargin==1)
    file_internal = putfile('*.sqw');
    if (isempty(file_internal))
        error ('No file given')
    end
elseif (nargin==2)
    file_internal = file;
end

% Write data to file
disp(['Writing to ',file_internal,'...'])
mess = put_sqw (file_internal,w.main_header,w.header,w.detpar,w.data);
if ~isempty(mess); error(mess); end
