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
    %
    methods
        function obj = binfile_v4_common(varargin)
            obj = obj@horace_binfile_interface();
            obj.bat_ = blockAllocationTable(obj.max_header_size_,obj.data_blocks_list);
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        function nd = get.num_dims_to_save(obj)
            nd = obj.num_dim_;
        end
        function bt = get.bat(obj)
            bt = obj.bat_;
        end
        function obj=set.bat(obj,val)
            % BAT setter, to use by serialization only. It will be probably
            % invalid otherwise
            if ~isa(val,'blockAllocatioTable')
                error('HORACE:binfile_v4_common:invalid_argument',...
                    'Attempt to set BlockAllocatioTable value using class: %s', ...
                    class(val))
            end
            obj.bat_ = val;
        end
        function bll = get.data_blocks_list(obj)
            bll = get_data_blocks(obj);
        end
        %------------------------------------------------------------------
        function obj = put_all_blocks(obj,sqw_dnd_data,varargin)
            % Put all blocks in the input data object in binary file
            if exist('sqw_dnd_data','var')
                obj.sqw_holder_ = sqw_dnd_data;
            else
                sqw_dnd_data = obj.sqw_holder;
            end
            %
            obj=obj.put_app_header();

            obj.bat_.put_bat(obj.file_id_);
            fl = obj.data_blocks_list;
            n_blocks = obj.bat_.n_blocks;
            for i=1:n_blocks
                fl{i} = fl{i}.put_sqw_block(obj.file_id_,sqw_dnd_data);
            end
            obj.bat_.put_bat(obj.file_id_);
            %
        end
        %
        function [obj,sqw_obj_to_set] = get_all_blocks(obj,filename,varargin)
            % retrieve sqw/dnd object from hdd and set it as 
            if exist('filename','var')
                obj = obj.init(filename);
            end
            if ~isempty(varargin)
                sqw_obj_to_set = varargin{1};
            else
                sqw_obj_to_set = sqw();
            end
            %
            %obj.bat_ = obj.bat_.get_bat(obj.file_id_);
            fl = obj.data_blocks_list;
            n_blocks = obj.bat_.n_blocks;
            for i=1:n_blocks
                [~,sqw_obj_to_set] = fl{i}.get_sqw_block(obj.file_id_,sqw_obj_to_set);
            end
        end
        %------------------------------------------------------------------
        function [obj,set_obj] = get_sqw_block(obj,block_name_or_class,varargin)
            % retrieve particular sqw object data block asking for it by 
            % its name or data_block class instance.
            % Inputs:
            % obj          -- instance of faccess class. Either initialized
            %                 or not. If not, the filename and (optionally)
            %                 have to be provided sqw object to 
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
    end
    %======================================================================
    methods(Access=protected)
        function ver = get_faccess_version(~)
            % Main part of get.faccess_version accessor
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
    end
    methods(Abstract,Access=protected)
        % return the list of (non-iniialized) data blocks, defined for
        % given file format
        bll = get_data_blocks(obj);
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Hidden=true)
        % accessor to number of dimensions, hidden for use with
        % serializable only
        num_dims_to_save;
    end

    properties(Constant,Access=private,Hidden=true)
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