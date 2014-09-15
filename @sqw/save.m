function save (w, file, fmt)
% Save a sqw object or array of sqw objects to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%   >> save (w, file, fmt)   % give file and explicit file format
%
% Input:
% ------
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%   fmt     File format. By default, the latest format
%           To save in older formats: '-v3' (version 3) or '-v1' (version 1)
%   
%   Note that if w is an array of sqw objects then file must be a cell
%   array of filenames of the same size.
%
% Output:

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get file name - prompting if necessary
if nargin==1 
    file_internal = putfile('*.sqw');
    if (isempty(file_internal))
        error ('No file given')
    end
else
    [file_internal,mess]=putfile_horace(file);
    if ~isempty(mess)
        error(mess)
    end
end
if ~iscellstr(file_internal)
    file_internal=cellstr(file_internal);
end
if numel(file_internal)~=numel(w)
    error('Number of data objects in array does not match number of file names')
end

horace_info_level=get(hor_config,'horace_info_level');
for i=1:numel(w)
    % Write data to file
    if horace_info_level>-1
        disp(['Writing to ',file_internal{i},'...'])
    end
    if nargin<=2
        [ok,mess] = put_sqw (file_internal{i},w(i));
    else
        [ok,mess] = put_sqw (file_internal{i},w(i),'file_format',fmt);
    end
    if ~isempty(mess); error(mess); end

end
