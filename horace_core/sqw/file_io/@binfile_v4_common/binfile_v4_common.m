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
        % list of data blocks, defined on the class
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
    end
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
            % Return default definition of the serializable
            strc  = to_bare_struct@serializable(obj,varargin{:});
        end
        function obj=from_bare_struct(obj,indata)
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