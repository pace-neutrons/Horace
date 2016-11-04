function    obj = put_sqw(obj,varargin)
% Save dnd data into new binary file or fully overwrite an existing file
%
% store header, which describes file as dnd file
%

obj.put_app_header();

% write dnd image methadata
obj.put_dnd_methadata(varargin{:});
% write dnd image data
obj.put_dnd_data(varargin{:});
%
