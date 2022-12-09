classdef binfile_v4_common < horace_binfile_interface
    % Class describes common binary operations avaliable on
    % binary sqw file version 4
    %


    methods
        function nd = get.num_dims_to_save(obj)
            nd = obj.num_dim_;
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
        fields_to_save_ = {'full_filename','num_dims_to_save'};
    end

    methods
        function strc = to_bare_struct(obj,varargin)
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