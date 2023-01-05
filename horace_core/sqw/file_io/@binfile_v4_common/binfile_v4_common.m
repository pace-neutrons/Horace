classdef binfile_v4_common < horace_binfile_interface
    % Class describes common binary operations avaliable on
    % binary sqw file version 4
    %
    properties(Access=protected)
        % Blocks allocation table
        bat_
    end
    properties(Dependent)
        % Block allocation table
        bat;
        % list of data blocks to read/write on hdd, defined by the class
        data_blocks_list;
    end
    properties(Dependent,Hidden)
        % old data type, not relevant any more. Always "b+" for dnd and "a" for
        % sqw
        data_type
    end    
    %======================================================================
    % GENERIC FACCESS METHODS
    methods
        function obj = binfile_v4_common(varargin)
            obj = obj@horace_binfile_interface();
            obj.bat_ = blockAllocationTable(obj.max_header_size_,obj.data_blocks_list);
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        function bt = get.bat(obj)
            bt = obj.bat_;
        end
        function obj=set.bat(obj,val)
            % BAT setter, to use by serialization only. It will be probably
            % invalid otherwise
            if ~isa(val,'blockAllocationTable')
                error('HORACE:binfile_v4_common:invalid_argument',...
                    'Attempt to set BlockAllocationTable value using class: %s', ...
                    class(val))
            end
            obj.bat_ = val;
        end
        function bll = get.data_blocks_list(obj)
            bll = get_data_blocks(obj);
        end
        %------------------------------------------------------------------
        function obj = put_all_blocks(obj,sqw_dnd_data,varargin)
            % Put all blocks containing in the input data object and defined
            % in BAT into Horace binary file
            %
            % The faccess object have to be initialized
            if exist('sqw_dnd_data','var')
                obj.sqw_holder_ = sqw_dnd_data;
                obj.bat_ = obj.bat_.init_obj_info(sqw_dnd_data);
            else
                sqw_dnd_data = obj.sqw_holder;
            end
            %
            obj=obj.put_app_header();

            obj.bat_.put_bat(obj.file_id_);
            bl = obj.bat.blocks_list;
            n_blocks = obj.bat_.n_blocks;
            for i=1:n_blocks
                bl{i} = bl{i}.put_sqw_block(obj.file_id_,sqw_dnd_data);
            end
            obj.bat.blocks_list = bl;

            obj.bat_.put_bat(obj.file_id_);
            %
        end
        %
        function [obj,obj_to_set] = get_all_blocks(obj,varargin)
            % retrieve sqw/dnd object from hdd and return its values in
            % the object provided as input.
            % Inputs:
            % obj             -- initialized instance of faccessor
            % Optional:
            % filename_or_obj
            % Either       -- name of the file to initialize faccessor
            %                 from if the object have not been initialized
            %                 before
            % OR           -- the object to modify with the data,
            %                 obtained using initialized faccessor
            % obj_to_set   -- if provided, previous parameter have to be
            %                 the file to read data from. Then this
            %                 parameter defines the object, to modify the
            %                 data using faccessor, initialized by file
            %                 above
            % if none of additinal parameters is specified, result is
            % returnded in sqw object
            % Output:
            % obj          -- initialized instance of faccessor.
            % obj_to_set   -- the object, modified by the contents,
            %                 obtained from the file. If other objects are
            %                 not specified as input, this object is sqw
            %                 object.
            %
            [obj,obj_to_set,is_serializable] = check_get_all_blocks_inputs_(obj,varargin{:});
            % This have happened during intialization:
            %obj.bat_ = obj.bat_.get_bat(obj.file_id_);
            fl = obj.bat.blocks_list;
            n_blocks = obj.bat_.n_blocks;
            for i=1:n_blocks
                [~,obj_to_set] = fl{i}.get_sqw_block(obj.file_id_,obj_to_set);
            end
            if is_serializable
                obj.do_check_combo_arg = true;
                obj = obj.check_combo_arg();
            end
            obj.sqw_holder_ = obj_to_set;
        end
        %------------------------------------------------------------------
        function [obj,set_obj] = get_sqw_block(obj,block_name_or_class,varargin)
            % retrieve particular sqw object data block asking for it by
            % its name or data_block class instance.
            % Inputs:
            % obj          -- instance of faccess class. Either initialized
            %                 or not. If not, the filename to get block
            %                 from have to be provided as third argument
            % block_name_or_class
            %              -- the name of the data_block in BAT or the
            %                 instance of data_block class, providing this
            %                 name.
            % Optional:
            % file_name    -- the name of the file to read necessary sqw
            %                 block from. The file will be opened in read
            %                 mode
            % Returns.
            % obj          -- initialized instance of faccess_xxx_v4 reader
            % set_obj      -- if initial object contains the instance of
            %                 sqw/dnd object, this object, modified with
            %                 the data, stored in the requested block.
            %                 If the obj.sqw_holder property is empty, the
            %                 retrieved instance of the requested data,
            %                 obtained using the block_name requested
            %
            if nargin>2 % otherwise have to assume that the object is initialized
                if nargin>3 || ~(ischar(varargin{1})||isstring(varargin{1}))
                    error('HORACE:binfile_v4_common:invalid_argument',...
                        'Third argument of get_sqw_block can be only filename. You have provided: %s', ...
                        disp2str(varargin))
                end
                obj = obj.init(varargin{1});
            end
            [obj,set_obj]  = get_sqw_block_(obj,block_name_or_class);
        end
        %
        function obj = put_sqw_block(obj,block_name_or_class,varargin)
            % store modified particular sqw sub-object data block within the
            % sqw object binary records on hdd
            % Inputs:
            % obj          -- instance of faccess class. Either initialized
            %                 or not. If not, the information for the initialization
            %                 have to be provided as subsequent arguments
            % block_name_or_class
            %              -- the registered data_block name or
            %                 instance-source of the data_block name to
            %                 use for storing the requested data on hdd
            %Optional:
            % 1) Either:
            % sqw_object   -- the instance of SQWDnDBase class to extract
            %                 modified subobject from
            % OR:
            % subobj       -- the subobject of sqw object to store using selected
            %                 data_block
            % 2) filename  -- if provided, the name of file to modify and
            %                 store the data block in. Any other
            %                 information (subblock to store) is not
            %                 acceptable in this situation
            %
            if nargin>2 % otherwise have to assume that the object is initialized
                if (isa(varargin{1},'SQWDnDBase')||is_sqw_struct(varargin{1}))
                    obj = obj.init(varargin{:});
                    obj  = put_sqw_block_(obj,block_name_or_class);
                    return;
                end
                obj  = put_sqw_block_(obj,block_name_or_class,varargin{1});
            else
                obj  = put_sqw_block_(obj,block_name_or_class);
            end
        end
        %
        function obj = compress_file(obj)
            % not yet implemented
            warning('HORACE:binfile_v4_common:not_implemented', ...
                'binary file compression have not been implemented yet')
        end
        %
        function dt = get.data_type(obj)
            dt = get_data_type(obj);
        end        
    end
    %======================================================================
    % DND access methods common for dnd and sqw objects
    methods
        %------------------------------------------------------------------
        function [dnd_dat,obj]  = get_dnd_data(obj,varargin)
            % return DND data class, containing n-d arrays, describing N-D image
            [dnd_dat,obj] = obj.get_dnd_block('bl_data_nd_data',varargin{:});
        end
        function [dnd_info,obj] = get_dnd_metadata(obj,varargin)
            % return dnd metadata class, containing general information,
            % describing dnd object
            [dnd_info,obj] =  obj.get_dnd_block('bl_data_metadata',varargin{:});
        end
        % retrieve any dnd object or dnd part of sqw object
        [dnd_obj,obj]  = get_dnd(obj,varargin);
        %------------------------------------------------------------------
        function obj = put_dnd_metadata(obj,varargin)
            % write information, describing dnd object
            obj = obj.put_dnd_block('bl_data_metadata',varargin{:});
        end

        function obj = put_dnd_data(obj,varargin)
            % write dnd image data, namely s, err and npix
            obj = obj.put_dnd_block('bl_data_nd_data',varargin{:});
        end
        % save sqw/dnd object stored in memory into binary sqw file as dnd object.
        % it always reduced data in memory into dnd object on hdd
        obj = put_dnd(obj,varargin);

    end
    %======================================================================
    methods(Access=protected)
        function ver = get_faccess_version(~)
            % Main part of get.faccess_ve
            % rsion accessor
            % retrieve sqw-file version the particular loader works with
            ver = 4.0;
        end
        obj=init_from_sqw_obj(obj,varargin);
        % init file accessors from sqw file on hdd
        obj=init_from_sqw_file(obj,varargin);

        % the main part of the copy constructor, copying the contents
        % of the one class into another including opening the
        % corresponding file with the same access rights
        [obj,missinig_fields] = copy_contents(obj,other_obj,keep_internals)
        %
        function   obj_type = get_format_for_object(~)
            % main part of the format_for_object getter, specifying for
            % what class saving the file format is intended
            obj_type = 'dnd';
        end
        function obj = do_class_dependent_updates(obj,~)
            % this function takes this file accessor and modify it with
            % data necessary to access file with new file accessor
            %
            % Currently this form does nothing as v4 is recent binary
            % file format
        end
        %------------------------------------------------------------------
        function [dnd_block,obj] = get_dnd_block(obj,block_name_or_instance,varargin)
            % Retrieve the binary data described by the data_block provided as input
            %
            % uses get_sqw_block and adds file initialization if info is
            % provided
            %
            % Differs from get_sqw_block as it may initialize input file if
            % the file is not initialized and appropriate data are
            % available
            [dnd_block,obj] = get_dnd_block_(obj,block_name_or_instance,varargin{:});
        end
        function obj = put_dnd_block(obj, block_name_or_instance,varargin)
            % store the data described by the block provided as input
            %
            % uses put_sqw_block and adds file initialization if info is
            % provided
            %
            obj = put_dnd_block_(obj, block_name_or_instance,varargin{:});
        end
        %
        function pos = get_npix_position(obj)
            % Main part of npix position getter
            if isempty(obj.bat_) || ~obj.bat_.initialized
                pos = [];
                return
            end
            bl = obj.bat_.get_data_block('bl_data_nd_data');
            pos = bl.npix_position;
        end
    end
    methods(Abstract,Access=protected)
        % return the list of (non-iniialized) data blocks, defined for
        % given file format
        bll = get_data_blocks(obj);
        % main part of data_type accessor
        dt = get_data_type(obj)        
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=private)
        % list of fileldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        fields_to_save_ = {'full_filename','num_dims_to_save','bat'};
    end

    methods
        function strc = to_bare_struct(obj,varargin)
            % Return default implementation from serializable as
            % binfile version overloads it to support expose of protected
            % or private properties
            strc  = to_bare_struct@serializable(obj,varargin{:});
        end
        function obj=from_bare_struct(obj,indata)
            % Return default definition from serializable as
            % binfile version overloads it to support expose of protected
            % or private properties
            obj  = from_bare_struct@serializable(obj,indata);
        end
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 1;
        end
        function flds = saveableFields(obj)
            flds = binfile_v4_common.fields_to_save_;
            if ~isempty(obj.sqw_holder)
                flds = [flds(:),'sqw_holder'];
            end
        end
        %------------------------------------------------------------------
    end

end