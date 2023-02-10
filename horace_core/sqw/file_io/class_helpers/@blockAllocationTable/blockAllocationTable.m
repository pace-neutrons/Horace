classdef blockAllocationTable < serializable
    % blockAllocationTable class (BAT) is responsible for maintaining coherent
    % location of binary blocks on HDD, identification of free spaces to
    % store updated blocks and storing/restoring information about block
    % sizes and block location on HDD
    %
    properties(Dependent)
        % true, if BAT keeps information about block positions of some
        % object. false otherwise
        initialized;
        %
        n_blocks      % Number of blocks the BAT table contains
        blocks_list;  % list of all data blocks (data_block classes),
        %               this BAT manages
        %
        position;     % position of the block allocation table within the
        %             % binary file
        bat_bin_size; % the size (number of bytes) the table occupies on HDD
        %
        % the position of the first data block located after block
        % allocation table placed on disk
        blocks_start_position;
        % The list of the names of the blocks, controlled by
        % BlockAllocaionTable
        block_names;
        % the positions of the free spaces blocks between binary blocks,
        % described BAT and free spaces sizes
        free_spaces_and_size;
        % position of the end of file (size of all blocks stored on the
        % disk expressed in bytes). Actually plus 1, so you may start
        % writing there
        end_of_file_pos
    end
    properties(Dependent,Hidden)
        % returns serialized representation of the blockAllocationTable,
        % suitable for storing it into file or recovering from this file
        ba_table;
    end
    properties(Access=protected)
        position_=0;
        % the size of empty BAT. recalculated as block list is assigned to
        % block_list property.
        bat_bin_size_ = 4;
        % if the BAT is initialized with particular object or its image on
        % hdd
        initialized_ = false;
        %
        blocks_list_ = {};
        block_names_ = {};
        % location and sizes of free spaces within binary data, described by BAT
        free_space_pos_and_size_ =zeros(2,0);
        end_of_file_pos_ = 0;
    end
    %======================================================================
    % Constructor and public accessors/mutators
    methods
        function obj = blockAllocationTable(varargin)
            %Construct an instance of blockAllocationTable class
            if nargin == 0
                return;
            end
            obj = obj.init(varargin{:});
        end
        function obj = init(obj,location,block_list)
            % Initialize empty instance of blockAllocatioTable class with
            % the block table to use for processing future objects parts
            % location in file
            %
            % Inputs:
            % location -- the position of the
            obj.position     = location;
            obj.blocks_list  = block_list;
        end
        %------------------------------------------------------------------
        function size = get.bat_bin_size(obj)
            size = obj.bat_bin_size_;
        end
        function nb = get.n_blocks(obj)
            nb = numel(obj.blocks_list_);
        end
        function is = get.initialized(obj)
            is = obj.initialized_;
        end
        %
        function pos = get.position(obj)
            pos = obj.position_;
        end
        function obj = set.position(obj,val)
            % WARNING: !!!!
            % if BAT position changes after block positions are
            % calculated, they get recalculated at change (here)
            %
            % This is wrong if data are already on disk or BAT position
            % is not placed in front of other blocks.
            %
            obj = set_bat_position_(obj,val);
        end
        %
        function list = get.blocks_list(obj)
            list = obj.blocks_list_;
        end
        function obj = set.blocks_list(obj,val)
            % initialize BAT by assigning to it list of data blocks
            obj = set_block_list_(obj,val);
        end
        function obj = set_changed_block(obj,bl_instance,bl_index)
            % set data block without recalculating bat. Used when
            % data_block child contains additional information, not stored
            % in BAT.
            bl_name = bl_instance.block_name;
            bl_ind_present = find(ismember(obj.block_names_,bl_name));
            if isempty(bl_ind_present)
                error('HORACE:blockAllocationTable:invalid_argument', ...
                    'Block with name %s is not registered in BAT',bl_name );                
            end
            bl_present = obj.blocks_list_{bl_ind_present};
            if bl_ind_present ~= bl_index || bl_present.position ~= bl_instance.position ||...
                bl_present.size ~= bl_instance.size
                error('HORACE:blockAllocationTable:invalid_argument', ...                
                    'The block %s have changed its size or postion. This is not allowed without recalculating BAT', ...
                    bl_name);
            end
            obj.blocks_list_{bl_index} = bl_instance;
        end
        %------------------------------------------------------------------
        function list = get.block_names(obj)
            list = obj.block_names_;
        end
        function pos = get.blocks_start_position(obj)
            % the data blocks start after BAT position
            % BAT size includes 4 bytes describing BAT binary block size,
            % + BAT binary representation itself, which include sum of
            % record sizes + 4 first bytes defining number of recors
            pos = uint64(obj.position + 4 + obj.bat_bin_size);
        end
        function fsp = get.free_spaces_and_size(obj)
            fsp = obj.free_space_pos_and_size_;
        end
        function pos = get.end_of_file_pos(obj)
            pos = uint64(obj.end_of_file_pos_);
        end
    end
    %======================================================================
    % Main BAT operations:
    methods
        function [data_bl_instance,bl_index] = get_data_block(obj,block_name_or_instance)
            % get one data_block which is part of block allocation table.
            % Inputs:
            % block_name_or_instance -- the name of the block in the BAT or
            %                           the instance of the block, which
            %                           defines the name
            % Returns:
            % data_bl_instance      -- initialized instance of the data
            %                          block, containing information about
            %                          particular part of BAT
            % bl_index              -- the position of the block in the BAT
            %                          list
            [data_bl_instance,bl_index] = get_data_block_(obj,block_name_or_instance);
        end
        function obj = set_data_block(obj,block_instance)
            % set data block with defined position and size in the free
            % space defined by current block allocation table.
            %
            % Input:
            % block_instance: The instance of data_block already present in
            %                BAT, with new position and size defined in the
            %                block_instance
            %
            % Returns:
            % modified BAT, containing new block at the position specified
            % in input and free spaces list modified according to the
            % changes, caused by placing the block in the specified
            % position.
            %
            % Throws if the input block location overlaps with locations of
            % any existing blocks
            %
            obj = set_data_block_(obj,block_instance);
        end
        function [obj,new_pos,compress_bat] = find_block_place(obj, ...
                data_block_or_name,block_size)
            % find place to put data block provided as input within the
            % block positions, described by BAT.
            %
            % The block have to be already registered wit the BAT.
            %
            % Inputs:
            % data_block_or_name
            %            -- data_block class instance or name of the block
            %               to find its place in the BAT list
            % block_size -- if block name is provided, the size of block to
            %               place in BAT. if class is provided, ignored and
            %               overwrtitten by the data_block.size() value
            %Returns:
            % obj        -- the BAT modified to accomodate new block
            %               position
            % new_pos    -- position to place block on hdd not to overlap
            %               with other blocks
            % compress_bat
            %           -- if true, indicates that the blocks are placed on
            %           hdd too loosely, so one needs to move then all
            %           together to save space
            if isa(data_block_or_name,'data_block')
                if ~exist('block_size','var')
                    block_size = data_block_or_name.size;
                end
            elseif ischar(data_block_or_name)||isstring(data_block_or_name)
                if ~exist('block_size','var')
                    error('HORACE:blockAllocationTable:invalid_argument', ...
                        'If block name provided as input of the method, block size have to be provided. It has been not')
                end
            else
                error('HORACE:blockAllocationTable:invalid_argument', ...
                    'Method accepts either data_block class instance or the name of the block in BAT. The class of the parameter is %s', ...
                    class(data_block_or_name));
            end
            [obj,new_pos,compress_bat] = find_block_place_(obj, ...
                data_block_or_name,block_size);
        end
        %
        function obj = init_obj_info(obj,obj_to_analyze,varargin)
            % Initialize block allocation table for the sqw/type object,
            % provided as input.
            % Inputs:
            % obj_to_analyze -- the object to split into sub-blocks and
            %                   create BAT for. The object has to be
            %                   compatible with the data_block-s list,
            %                   provided at the construction of the BAT.
            % Optional:
            %
            % '-nocache'   --  if absent, cache serialized
            %                   binary representation of obj_to_analyze
            %                   while calculating sizes of its blocks.
            %                   if false, the binary representation will be
            %                   recalculated when the object will be
            %                   written on hdd, and the method will just
            %                   calculate sizes and future locations
            %                   of the blocks.
            % '-insertion'   -- if present, calculate sizes of blocks only
            %                   if they have not been calculated before,
            %                   and insert these blocks in free BAT space
            %                   assuming that other blocks have already
            %                   been allocated.
            % '-test_mode'   -- do not validate the size of the sub-objects
            %                   of the initial object agains the size of
            %                   these objects preallocated earlier. Should
            %                   be used in tests only.
            %  Used for upgrade of the old sqw files into new file format
            %  leaving pixels array in their place
            %
            % Result:
            % The blocks defined in this BlockAllocationTable calculate
            % their sizes and their positions are calculated assuming that
            % they will be placed one after another without gaps, or, if
            % '-insertion' is specified, calculate places of undefined
            % blocks of BAT, assuming that blocks, which are already
            % defined are staying at their initial position.
            %
            [ok,mess,nocache,insertion,test_mode] = parse_char_options(varargin, ...
                {'-nocache','-insertion','-test_mode'});
            if ~ok
                error('HORACE:blockAllocationTable:invalid_argument', mess);
            end
            obj = init_obj_info_(obj,obj_to_analyze,nocache,insertion,test_mode);
        end
        function pos = get_block_pos(obj,block_name_or_class)
            % return the position of block defined by current BAT
            % Inputs:
            % obj -- the instance of block_allocation table initialized by
            %        an object
            % block_name_or_class
            %     -- name of the data block to find the position or an
            %        instance of the block with specified property names
            %        The block position is taken from BAT, any
            %        defined on class is ignored.
            % Returns:
            % pos  -- the position of the block in binary file, retrieved
            %         from this BAT.
            % Throws:
            % HORACE:blockAllocationTable:runtime_error if the table have
            %       not been initialized
            pos = get_block_pos_(obj,block_name_or_class);
        end
        %
        function bindata = get.ba_table(obj)
            % generate BAT binary representation to store Block
            % Allocation Table in file
            bindata = get_ba_table_bindata(obj);
        end
        function obj = set.ba_table(obj,bindata)
            % restore Block Allocation Table from its binary representation
            obj = set_ba_table_from_bindata_(obj,bindata);
        end
        %------------------------------------------------------------------
        % store/restore BAT on its place in file
        function obj = put_bat(obj,fid,position)
            % store block allocation table at specified location in the
            % binary file.
            if ~exist('position','var')
                position = obj.position;
            end
            obj = store_bat_(obj,fid,position);
        end
        function obj = get_bat(obj,fid,position)
            % get block allocation table stored at specified location in the
            % binary file.
            if ~exist('position','var')
                position = obj.position;
            end
            obj = restore_bat_(obj,fid,position);
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
            flds = {'position','ba_table'};
        end
        %------------------------------------------------------------------
    end

end