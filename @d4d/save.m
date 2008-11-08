function save (w, file)
% Save a sqw object to file
%
%   >> save_sqw (w)              % prompt for file
%   >> save_sqw (w, file)        % give file
%
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%
% Output:

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


extension='d4d';

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

% Get file name - prompting if necessary
if (nargin==1)
    file_internal = putfile(['*.',extension]);
    if (isempty(file_internal))
        error ('No file given')
    end
elseif (nargin==2)
    file_internal = file;
end

% Write data to file
save(sqw(w),file_internal)
