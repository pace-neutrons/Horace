function   app_header = build_app_header(obj,obj_to_save)
% Build Horace sqw-file header to write to hdd. The header contains
% information on type of sqw object and sqw-file subversion
% and allows clients to distinguish Horace binary format from other binary
% files and various Horace subformats from each other
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
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
    [~,ndim] = calc_proper_ndim_(obj_to_save.data);
elseif  is_sqw_struct(obj_to_save)
    if isempty(obj_to_save.main_header)
        app_header.sqw_type = false;
    else
        app_header.sqw_type = true;
    end
    [~,ndim] = calc_proper_ndim_(obj_to_save.data);
else
    type    = class(obj_to_save);
    classes = {'d0d','d1d','d2d','d3d','d4d','data_sqw_dnd'};
    ind = ismember(classes,type);
    if ~any(ind)
        error('SQW_FILE_IO:invalid_argument',...
            ' build_app_header -- unsupported class to save in sqw format: "%s"',type)
    end
    app_header.sqw_type = false;
    ndim = find(ind)-1;
    if ndim == 5
        [~,ndim] = calc_proper_ndim_(obj_to_save);
    end
end
app_header.ndim = ndim;

