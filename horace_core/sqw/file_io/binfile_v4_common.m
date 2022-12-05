classdef binfile_v4_common < horace_binfile_interface
    % Class describes common binary operations avaliable on
    % binary sqw file version 4
    %

    methods

    end
    methods(Access=protected)
        function ver = get_file_version(~)
            % retrieve sqw-file version the particular loader works with
            ver = 4.0;
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
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
        %------------------------------------------------------------------
    end

end