classdef binfile_v4_common < dnd_file_interface
    % Class describes common binary operations avaliable on
    % binary sqw file version 4
    %

    methods
        function app_header = build_app_header(obj,varargin)
            % Build header, which allows to distinguish Horace from other
            % applications and adds some information about stored sqw/dnd
            % object.

            app_header = build_app_header@dnd_dile_interface(obj,varargin{:});
            app_header.creation_date = datestr(datetime("now"), main_header_cl.dt_format);
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