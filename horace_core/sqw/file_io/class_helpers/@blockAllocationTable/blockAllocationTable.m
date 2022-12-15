classdef blockAllocationTable < serializable
    %blockAllocationTable  class responsible for maintaining coherent
    % location of binary blocks on HDD, identification of free spaces to
    % store updated blocks and storing/restoring information about block
    % sizes and block location on HDD
    %
    properties(Dependent)
        n_blocks      % Number of blocks the BAT table contains
        blocks_list;  % list of all data_blck blocks, this BAT manages
        %
        position; % position of the block allocation table within the
        %         % binary file
        bat_bin_size; % the size (number of bytes) the table occupies on HDD
        %
        % the position of the first data block located after block
        % allocation table placed on disk
        blocks_start_position;
        % The list of the names of the blocks, controlled by
        % BlockAllocaionTable
        block_names
    end
    properties(Dependent,Hidden)
        % returns serialized representation of the blockAllocationTable,
        % suitable for storing it into file or recovering from this file
        ba_table;
    end
    properties(Access=protected)
        position_=0;
        % the size of empty BAT. recalculated as BAT list is assigned to
        % BAT
        bat_bin_size_ = 4;
        % if the BAT is initialized with particular object
        block_list_location_initiated_ = false;
        %
        blocks_list_ = {};
        block_names_ = {};
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
            obj = set_block_list_(obj,val);
        end
        %------------------------------------------------------------------
        function list = get.block_names(obj)
            list = obj.block_names_;
        end
        function pos = get.blocks_start_position(obj)
            % the data blocks start after BAT, 4 bytes of BAT size
            % + BAT binary representation itself
            pos = uint64(obj.position + 4 + obj.bat_bin_size);
        end
    end
    %======================================================================
    % Main BAT operations:
    methods
        function obj = init_obj_info(obj,obj_to_analyze,nocache)
            % Initialize block allocation table for the object, provided as
            % input.
            % Inputs:
            % obj_to_analyze -- the object to split into sub-blocks and
            %                   create BAT for. The object has to be
            %                   compartible with the data_block-s list,
            %                   provided at construction of the BAT.
            % nocache        -- if true or absent, cache serizalized
            %                   binary representation of obj_to_analyze
            %                   while calculating sizes of its blocks.
            %                   if false, the binary representation will be
            %                   recalculated when the object will be
            %                   written on hdd, and method will just
            %                   calculate sizes and future locations
            %                   of the blocks.
            % Result:
            % The blocks defined in this BlockAllocationTable calculate
            % their sizes and their positions are calculated assuming that
            % they will be placed one after another without gaps.
            if nargin<3
                nocache = false;
            end
            obj = init_obj_info_(obj,obj_to_analyze,nocache);
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
        %
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