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
%   Note that if w is an array of sqw objects then file must be a cell
%   array of filenames of the same size.
%
% Output:

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get file name - prompting if necessary
if (nargin==1)
    file_internal = putfile('*.sqw');
    if (isempty(file_internal))
        error ('No file given')
    end
elseif (nargin==2)
    file_internal = file;
end


%Must ensure that if w is an array that filename is a cell array:
if numel(w)>1
    if ~iscell(file_internal) || numel(file_internal)~=numel(w)
        error('If sqw input is an array of objects, then filename must be a cell array of filenames of the same size');
    end
else
    file_internal={file_internal};
end
    
for i=1:numel(w)
    % Write data to file
    disp(['Writing to ',file_internal{i},'...'])
    if get(hdf_config,'use_hdf')
        error('sqw:save','saving in hdf is not supported')
    %    hfw=one_sqw(struct(w));
    %    [file_path,file_name]=fileparts(file_internal);
    %    hfw=set_file_name(hfw,file_path,file_name);
    %    write(hfw);
    else
        mess = put_sqw (file_internal{i},w(i).main_header,w(i).header,w(i).detpar,w(i).data);
        if ~isempty(mess); error(mess); end
    end
end
