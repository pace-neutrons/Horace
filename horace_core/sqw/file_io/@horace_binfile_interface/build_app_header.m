function   app_header = build_app_header(obj,obj_to_save)
% Build Horace sqw-file header to write to hdd. The header contains
% information on type of sqw object and sqw-file subversion
% and allows clients to distinguish Horace binary format from other binary
% files and various Horace subformats from each other
%
% Inputs:
% obj    -- the instance of sqw_file_interface object containing SQWDnDBase
%           object to save
% Optional:
% obj_to_save 
%        -- If provided, the instance of SQWDnDBase object to save as
%           future header. If not, the instance of the object will be taken
%           from sqw_holder. If no instance is defined, the method will
%           throw 'HORACE:sqw_file_interface:invalid_argument' exception.
%

if ~exist('obj_to_save','var')
    obj_to_save = obj.sqw_holder_;
end
%
if isempty(obj_to_save)
    error('HORACE:sqw_file_interface:invalid_argument',...
        'Trying to build_app_headed but no object to build header from is provided')
end

format = obj.app_header_form_;
app_header = format;
app_header.version  = obj.faccess_version;
%
if isa(obj_to_save,'sqw')
    app_header.sqw_type = true;
    ndim = obj_to_save.data.NUM_DIMS;
else
    if ~isa(obj_to_save,'DnDBase')
        error('HORACE:sqw_file_interface:invalid_argument',...
            'Build_app_header -- unsupported class to save in sqw format: "%s"', ...
            class(obj_to_save))
    end
    app_header.sqw_type = false;
    ndim = obj_to_save.NUM_DIMS;    
end
app_header.num_dim = ndim;
%



