function   app_header = build_app_header(obj,obj_to_save)
% Build Horace sqw-file header to write to hdd. The header contains
% information about the type of sqw object and sqw-file format version.
%
% This allows clients to distinguish Horace binary format from other binary
% files, identify various Horace sqw file binary format version and select
% the loader, suitable for load each particular binary format version.
%
% Inputs:
% obj    -- the instance of sqw_file_interface object containing SQWDnDBase
%           object to save
% Optional:
% obj_to_save
%        -- If provided, the instance of SQWDnDBase object to save in the
%           file, described by the header. If not, the data necessary for
%           the header are taken from faccessor
%
%           If incorrect SQWDnDBase object instance is defined, the method will
%           throw 'HORACE:sqw_file_interface:invalid_argument' exception.
%

if exist('obj_to_save','var') && ~isempty(obj_to_save)
    if isa(obj_to_save,'sqw')
        sqw_type = true;
        ndim = obj_to_save.data.NUM_DIMS;
    else
        if ~(isa(obj_to_save,'DnDBase') || is_sqw_struct(obj_to_save))
            error('HORACE:horace_binfile_interface:invalid_argument',...
                'Unsupported class "%s" to save in sqw binary format.', ...
                class(obj_to_save))
        end  
        ndim = obj_to_save.dimensions();
        sqw_type = false;
    end
else
    sqw_type = obj.sqw_type;
    ndim = obj.num_dim;
end
%
if ischar(ndim)
    error('HORACE:horace_binfile_interface:invalid_argument',...
        'Trying to build_app_header but no object to build header from is provided and faccessor itself is not defined')
end

format = obj.app_header_form_;
app_header = format;
app_header.version  = obj.faccess_version;
app_header.sqw_type = sqw_type;
app_header.num_dim =  ndim ;



