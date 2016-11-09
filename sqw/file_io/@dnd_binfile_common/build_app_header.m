function   app_header = build_app_header(obj,obj_to_save)
% Build Horace sqw-file header to write to hdd. The header contains
% information on type of sqw object and sqw-file subversion
% and allows clients to distinguish horace binary format from other binary
% files and various Horace subformats from each other
%
%
% $Revision$ ($Date$)
%

if ~exist('obj_to_save','var')
    obj_to_save = obj.sqw_holder_;
end
%
if isempty(obj_to_save)
    error('SQW_FILE_IO:invalid_argument',...
        ' build_app_header no object to build header for is provided')
end

format = obj.app_header_form_;
app_header = format;
app_header.version  = obj.file_ver_;
%
if isa(obj_to_save,'sqw')
    app_header.sqw_type = true;
    dim  = size(obj_to_save.data.s);
    if numel(dim) == 2
        if dim(1) == 1
            dim = dim(2);
        elseif dim(2) == 1
            dim = dim(1);
        end
    end
    ndim = numel(dim);
else
    type    = class(obj_to_save);
    classes = {'d0d','d1d','d2d','d3d','d4d'};
    ind = ismember(classes,type);
    if ~any(ind)
        error('SQW_FILE_IO:invalid_argument',...
            ' build_app_header -- unsupported class to save %s',type)
    end
    app_header.sqw_type = false;
    ndim = find(ind)-1;
end
app_header.ndim = ndim;

