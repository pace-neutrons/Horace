function obj = put_block_data_(obj, block_name_or_instance,varargin)
%PUT_DND_BLOCK_  store the data described by the block provided as input
%
% Inputs:
% obj        -- initialized or not initialized instance of faccessor object
%               if object is not initialized, the input parameters should
%               provide all information for the initialization, i.e.
%               the name of the file to store data in and the input sqw
%               object to take data from
% block_name_or_instance
%            -- the name or instance of data_block of the sqw object to
%               save data for. The name must coincide with one of the
%               names returned by .name property of one of the data_block
%               classes registered with this faccessor BAT.
% Optional:
% sqw object or part of it (corresponding to the data_block) to write.
% May be  information for initialization of obj if it has not been yet
% initialized. Exact format and possible options needs further testing
%
if nargin>2
    check_file_defined_and_exist_(obj,'write',varargin{:});
    if ~obj.bat.initialized
        obj = obj.init(varargin{:});
    else
        old_obj = obj.sqw_holder;
        obj = obj.put_sqw_block(block_name_or_instance,varargin{1});
        obj.sqw_holder_ = old_obj;
        return;
    end
end
obj = obj.put_sqw_block(block_name_or_instance);