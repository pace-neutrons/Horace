classdef binfile_v4_common < horace_binfile_interface
    % Class describes common binary operations available on
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
        % old data type, not relevant any more. Left for compatibility.
        % Always "b+" for dnd and "a" for sqw objects.
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
            % return list of data blocks defined in BAT.
            bll = get_data_blocks(obj);
        end
        %------------------------------------------------------------------
        function obj = put_all_blocks(obj,varargin)
            % Put all blocks containing in the input data object and defined
            % in BAT into Horace binary file
            %
            % Inputs:
            % obj   -- initialized for writing instance of faccess object
            % Optional:
            %  sqw_dnd_data   -- instance of sqw or dnd object to write
            % 'ignore_blocks' -- key followed by cellarray of names or
            %                    single name to ignore and do not write to
            %                    the disk at this stage.
            % NOTE:
            % If faccess is initialized for a new file and the intermediate
            % block is ignored, it will fail. TODO: ? should it be fixed?
            %
            % The faccess object have to be initialized
            if numel(varargin)>0 && (isa(varargin{1},'SQWDnDBase') || is_sqw_struct(varargin{1}))
                sqw_dnd_data = varargin{1};
                obj.sqw_holder_ = sqw_dnd_data;
                obj.bat_ = obj.bat_.init_obj_info(sqw_dnd_data);
                argi = varargin{2:end};
            else
                sqw_dnd_data = obj.sqw_holder;
                argi = varargin;
            end
            [ignored_blocks_list,~] = extract_ignored_blocks_arg_(argi{:});
            %
            obj=obj.put_app_header();

            bl = obj.bat.blocks_list;
            n_blocks = obj.bat_.n_blocks;
            for i=1:n_blocks
                if ismember(bl{i}.block_name,ignored_blocks_list)
                    continue;
                end
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
            % obj             -- initialized instance of f-accessor
            % Optional:
            % filename_or_obj
            % Either       -- name of the file to initialize f-accessor
            %                 from if the object have not been initialized
            %                 before
            % OR           -- the object to modify with the data,
            %                 obtained using initialized f-accessor
            % obj_to_set   -- if provided, previous parameter have to be
            %                 the file to read data from. Then this
            %                 parameter defines the object, to modify the
            %                 data using f-accessor, initialized by file
            %                 above
            % 'ignore_blocks'     ! the keyword which identifies that some
            %                     ! blocks should not be loaded
            % list of block names ! following the the first keyword the
            %                     ! list of block names to ignore and do
            %                       not read from hdd at this stage.
            %
            % if none of additional parameters is specified, result is
            % returned in newly created sqw object if f-accessor is an sqw
            % accessor or dnd object if the accessor is dnd accessor
            % Output:
            % obj          -- initialized instance of f-accessor.
            % obj_to_set   -- the object, modified by the contents,
            %                 obtained from the file. If other objects are
            %                 not specified as input, this object is sqw
            %                 object.
            %
            [obj,obj_to_set,is_serializable,ignore_block_list] = ...
                check_get_all_blocks_inputs_(obj,varargin{:});
            % This have happened during f-accessor initialization:
            %obj.bat_ = obj.bat_.get_bat(obj.file_id_);
            fl = obj.bat.blocks_list;
            n_blocks = obj.bat_.n_blocks;
            for i=1:n_blocks
                if ismember(fl{i}.block_name,ignore_block_list)
                    continue;
                end
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
            %                 modified sub-object from
            % OR:
            % subobj       -- the sub-object of sqw object to store using selected
            %                 data_block
            % 2) filename  -- if provided, the name of file to modify and
            %                 store the data block in. Any other
            %                 information (sub-block to store) is not
            %                 acceptable in this situation
            % '-noinit'    -- do not initialize file accessor, even if it
            %                 is possible
            %
            if nargin>2 % otherwise have to assume that the object is initialized
                [ok,mess,no_initialization,argi] = parse_char_options(varargin,{'-noinit'});
                if ~ok
                    error('HORACE:binfile_v4_common:invalid_argument',mess)
                end
                if ~no_initialization && ~isempty(argi) && (isa(argi{1},'SQWDnDBase')||is_sqw_struct(argi{1}))
                    obj = obj.init(argi{:});
                    obj  = put_sqw_block_(obj,block_name_or_class);
                    return;
                end
                obj  = put_sqw_block_(obj,block_name_or_class,argi{:});
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
        function obj = put_new_blocks_values(obj,obj_to_write,varargin)
            % method takes initialized faccessor and replaces blocks
            % stored in file with new block values obtained from sqw or dnd
            % object provided as input.
            %
            % Inputs:
            % obj   -- initialized instance of file-accessor attached to
            %          existing sqw file containing sqw/dnd data.
            % obj_to_write
            %       -- sqw or dnd object with contents that replaces
            %          previous contents on disk.
            % Optional:
            % 'exclude' -- option followed by list of block names which
            %              should remain unchanged in file.
            %  block_list
            %          -- cellarray of valid block names following 'exclude'
            %             keyword, describing blocks which contents in file
            %             should remains unchanged.
            %             If this keyword/list are missing the method
            %             replaces all data in file except pixel data,
            %             which are locked by default.
            %
            % 'update' -- option followed by list of block names which
            %             should be replaced in file. This option is opposite
            %             to 'exclude' option.
            %  block_list
            %          -- cellarray of valid block names following 'update'
            %             keyword, describing blocks which contents in file
            %             should be replaced.
            %             Similarly to 'exclude' if this option is missed,
            %             all blocks except pixels are replaced in file
            %             excluding pixel data. If this option is present,
            %             only blocks from the list provided here are updated.
            %
            % '-ignore_locks'
            %         --  if present, put new data even into blocks
            %             already locked in place.
            % '-nocache'
            %         --  if present tells the algorithm not to cache serialized
            %             contents of the blocks while calculating block sizes.
            %             This means that objects roughly speaking would be serialized
            %             twice -- first time when their size is estimated, and second
            %             time  -- before writing data on disk. These are more expensive
            %             calculations but memory is saved, as when cache is used, the
            %             serialized data for all blocks to be stored are placed in
            %             memory together and saved later.
            [ok,mess,ignore_locks,nocache,argi] = parse_char_options( ...
                varargin,{'-ignore_locks','-nocache'});
            if ~ok
                error('HORACE:file_io:invalid_argument',mess);
            end
            obj = put_new_blocks_values_(obj,obj_to_write, ...
                ~ignore_locks,nocache,argi{:});
        end
    end
    %======================================================================
    % DND access methods common for dnd and sqw objects
    methods
        function  obj = put_app_header(obj,varargin)
            % store application header which distinguish and describes
            % the sqw binary file.
            %
            % Overloaded for file format 4 to store BAT immediately after
            % Horace sqw file header
            obj = put_app_header@horace_binfile_interface(obj,varargin{:});
            obj.bat_.put_bat(obj.file_id_);

        end
        %------------------------------------------------------------------
        function [dnd_dat,obj]  = get_dnd_data(obj,varargin)
            % return DND data class, containing n-d arrays, describing N-D image
            [dnd_dat,obj] = obj.get_block_data('bl_data_nd_data',varargin{:});
        end
        function [dnd_info,obj] = get_dnd_metadata(obj,varargin)
            % return dnd metadata class, containing general information,
            % describing dnd object
            [dnd_info,obj] =  obj.get_block_data('bl_data_metadata',varargin{:});
        end
        % retrieve any dnd object or dnd part of sqw object
        [dnd_obj,obj]  = get_dnd(obj,varargin);
        %

        %------------------------------------------------------------------
        % save sqw/dnd object stored in memory into binary sqw file as dnd object.
        % it always reduced data in memory into dnd object on hdd
        obj = put_dnd(obj,varargin);
        %
        obj = put_dnd_data(obj,dnd_obh);
        obj = put_dnd_metadata(obj,varargin)
        obj = put_senpix_block(obj,img_struct,pos);
        obj = get_npix_block(obj,bin_start,bin_end);
        %
        function  [data,obj] =  get_data(obj,varargin)
            % equivalent to get_dnd('-noclass). Should it also return pix
            % if warning on sqw object? No this at the moment
            argi = parse_get_data_inputs_(varargin{:});
            [data,obj] = obj.get_dnd(argi{:});
        end
        % OLD DND INTERFACE
        %------------------------------------------------------------------
        function [data_str,obj] = get_se_npix(obj,varargin)
            % get only dnd image data, namely s, err and npix
            data_dnd = obj.get_dnd_data(varargin{:});
            data_str = struct('s',data_dnd.sig,'e',data_dnd.err, ...
                'npix',double(data_dnd.npix));
        end

        function img_db_range = get_img_db_range(obj,varargin)
            % get [2x4] array of min/max ranges of the image where pixels
            % are rebinned into
            ds = obj.get_dnd_metadata();
            img_db_range  = ds.axes.img_range;
        end

        function hd = head(obj,varargin)
            % the function returns standard head information about sqw/dnd file
            [ok,mess,full] = parse_char_options(varargin,'-full');
            if ~ok
                error('HORACE:binfile_v4_common:invalid_argument',mess);
            end
            if full
                data = obj.get_dnd('-verbatim');
            else
                data = obj.get_dnd_metadata();
            end
            flds = DnDBase.head_form(full);
            hd = struct();
            for i=1:numel(flds)
                fld = flds{i};
                hd.(fld) = data.(fld);
            end
        end

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

        % get access for creation date of dnd object stored on hdd or
        % attached to file loader
        cd = get_creation_date(obj)
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
        %------------------------------------------------------------------
        function [dnd_block,obj] = get_block_data(obj,block_name_or_instance,varargin)
            % Retrieve the binary data described by the data_block provided as input
            %
            % uses get_sqw_block and adds file initialization if info is
            % provided
            %
            % Differs from get_sqw_block as it may initialize input file if
            % the file is not initialized and appropriate data are
            % available
            [dnd_block,obj] = get_block_data_(obj,block_name_or_instance,varargin{:});
        end
        function obj = put_block_data(obj, block_name_or_instance,varargin)
            % store the data described by the block provided as input
            %
            % uses put_sqw_block and adds file initialization if initialization
            % info is provided.
            %
            % See more information about the routine within the private
            % procedure invoked below.
            %
            obj = put_block_data_(obj, block_name_or_instance,varargin{:});
        end
        %
        function pos = get_npix_position(obj)
            % Main part of npix_position getter
            % Returns location of the start of the pixel data block.
            %
            % Calculated in bytes from beginning of the file
            if isempty(obj.bat_) || ~obj.bat_.initialized
                pos = [];
                return
            end
            [bl,bl_indx] = obj.bat_.get_data_block('bl_data_nd_data');
            if ~bl.dnd_info_defined
                bl = bl.read_dnd_info(obj.file_id_);
                %obj.bat_ = obj.bat_.set_changed_block(bl,bl_indx);
            end
            pos = bl.npix_position;
        end
    end
    methods(Abstract,Access=protected)
        % return the list of data blocks, defined for
        % given file format regardless of their initialization.
        bll = get_data_blocks(obj);
        % main part of data_type accessor. Simply overloaded for sqw and
        % dnd object(s) to return 'a' or 'b+'
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