function obj = set_as_tmp_obj(obj,filename)
% method sets filebacked sqw object to be temporary object i.e.
% the underlying file, provided as input is getting deleted
% when object goes out of scope.
%
% WARNING: if an sqw object built from an existing sqw file is set
%          to be a tmp object, the original file will be automatically
%          deleted when this object goes out of scope.
% USE WITH CAUTION!!!
if ~obj.is_filebacked
    return;
end
if nargin == 1
    filename = obj.pix.full_filename;
end
obj = set_as_tmp_obj_(obj,filename);

