function set_use_mex_(obj,use)
% private function to enable or disable mex mode for accessing hdf pixel
% information
% 
%
if isempty(obj.filename_)
    error('HDF_PIX_GROUP:invalid_argument',...
        'You need to initialize hdf_pix_group first to be able to change the operation mode');
end

use = logical(use);
if use
    if (exist(hdf_mex_reader,'file') == 3)
        ver = hdf_mex_reader();
        if isempty(ver)
            error('HDF_PIX_GROUP:runtime_error',...
                'Attempt to enable hdf mex access mode but the mex file to do  this is broken');
        end
    else
        error('HDF_PIX_GROUP:runtime_error',...
            'Attempt to enable hdf mex access mode but the mex file to do this does not exist');
    end
end
if obj.use_mex_to_read && ~use
    obj.mex_read_handler_ = hdf_mex_reader('close',obj.mex_read_handler_);
    obj.use_mex_to_read = false;
    init_(obj.filename_,obj.max_num_pixels,obj.chunk_size,'-use_matlab_to_read');
elseif ~obj.use_mex_to_read && use
    obj.mex_read_handler_ = hdf_mex_reader('init',obj.filename_,obj.nexus_group_name_);
    obj.use_mex_to_read_ = true;
end

