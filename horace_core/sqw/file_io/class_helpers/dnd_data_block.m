classdef dnd_data_block < data_block
    %DND_DATA_BLOCK describes the binary data, corresponding
    % for storing restoring on HDD DnD object data block in the binary
    % format.
    %
    % The special form of data_block binary data format is caused by need
    % to access dnd_data_block from third party (non-Matlab) applications
    %
    properties(Dependent)
        sig_position;
        err_position;
        npix_position;
    end
    properties(Access=protected)
        %
        dimensions_=[];
        data_size_=0;
    end
    methods
        function obj = dnd_data_block(varargin)
            %DND_DATA_BLOCK constructor
            obj = obj@data_block(varargin{:});
            obj.sqw_prop_name = 'data';
            obj.level2_prop_name = 'nd_data';
        end
        %
        function pos = get.sig_position(obj)
            pos = obj.position_+4+obj.dimensions_*4;
        end
        function pos = get.err_position(obj)
            pos = obj.sig_position+8*prod(obj.data_size_);
        end
        function pos = get.npix_position(obj)
            pos = obj.sig_position+2*8*prod(obj.data_size_);
        end


        function obj = cache_and_calc_obj_size(obj,sqw_obj)
            % Overloaded: -- caclculate size of the serialized object and
            % put the serialized object into data cache for subsequent put
            % operation(s)
            subobj = obj.get_subobj(sqw_obj);
            obj.dimensions_ = subobj.dimensions();
            obj.data_size_  = subobj.data_size();

            % num_dim,+ size(arrays)*4+3 data arrays 2-single precision,
            % 4--uint64 each of prop(subobj.data_size) elements
            obj.size_ = 4+obj.dimensions_*4+(3*8)*prod(obj.data_size_);
            obj.serialized_obj_cache_ = subobj;
        end
        function [obj,sqw_obj_to_set] = get_data_block(obj,fid,sqw_obj_to_set)
            % Read sub-block binary information from sqw object on HDD and
            % set this subobject to the proper field of the input sqw
            % object.
            dnd_data_obj = obj.get_bindata_from_file(fid);
            sqw_obj_to_set = obj.set_subobj(sqw_obj_to_set,dnd_data_obj);
        end
        % Protected?
        %-----------------------------------------------------------------
        function obj = put_bindata_in_file(obj,fid,obj_data)
            % Overloaded: -- store data containing in dnd_data class
            % into binary file
            % Inputs:
            % fid      -- opened file handle
            % obj_data -- full instance of dnd_data class
            %
            % Returns:
            % obj      -- unchanged
            % Eroror: HORACE:data_block:io_error is thrhown in case of
            %         problem with writing data fields
            obj.move_to_position(fid)
            head_data = uint32([obj_data.dimensions,obj_data.data_size]);
            fwrite(fid,head_data,'uint32');
            obj.check_write_error(fid,'header');
            %
            fwrite(fid,double(obj_data.sig(:)),'double');
            obj.check_write_error(fid,'signal');
            %
            fwrite(fid,double(obj_data.err(:)),'double');
            obj.check_write_error(fid,'error');
            %
            fwrite(fid,uint64(obj_data.npix(:)),'uint64');
            obj.check_write_error(fid,'npixel');
        end
        function dnd_data_obj = get_bindata_from_file(obj,fid)
            % read array of bytes from opened binary file
            %
            % Inputs:
            % fid      -- opened file handle
            %
            % Returns:
            % dnd_data_obj
            %          -- instance of dnd_data read from file.
            %
            % Eroror: HORACE:data_block:io_error is thrhown in case of
            %         problem with redading data fields
            obj.move_to_position(fid);
            %
            n_dims = fread(fid,1,'uint32');
            data_size = fread(fid,n_dims,'uint32');
            obj.check_read_error(fid,'header');
            %
            n_elements = prod(data_size);
            sig = fread(fid,n_elements,'double');
            obj.check_read_error(fid,'signal');
            %
            err = fread(fid,n_elements,'double');
            obj.check_read_error(fid,'error');
            %
            npix = fread(fid,n_elements,'uint64');
            obj.check_read_error(fid,'npixel');
            %
            dnd_data_obj = dnd_data(reshape(sig,data_size'), ...
                reshape(err,data_size'),reshape(npix,data_size'));
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 1;
        end
        function flds = saveableFields(~)
            flds = {'position','size'};
        end
        %------------------------------------------------------------------
    end

end