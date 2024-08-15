classdef a_loader_tester< a_loader
    %
    %

    methods(Static)
        % static methods
        function [is,fh] = can_load(file_name)
            error('A_LOADER:abstract_method_called','')
        end
        function [ndet,en]=get_data_info(file_name)
            error('A_LOADER:abstract_method_called','')
        end
        function descr=get_file_description()
            error('A_LOADER:abstract_method_called','')
        end
        function fext=get_file_extension()
            fext = {'.altf'};
            %error('A_LOADER:abstract_method_called','')
        end
    end
    methods
        % dynamic methods
        function [varargout]=load_data(this,varargin)
            error('A_LOADER:abstract_method_called','');
        end

        function this=init(this,data_file_name,varargin)
            error('A_LOADER:abstract_method_called','');
        end
        function this=set_data_info(this,data_file_name,varargin)
            error('A_LOADER:abstract_method_called','');
        end

        function this=a_loader_tester(varargin)
            % test constructor
            this=this@a_loader(varargin{:});
        end

        function this=set_defined_fields(this,fields)
            this.loader_define_ = fields;
        end
    end
    methods(Access=protected)
        function obj = set_info_fields(obj,fh,field_names)
            error('A_LOADER:abstract_method_called','')
        end
        function flds = get_data_info_fields(obj)
            error('A_LOADER:abstract_method_called','')
        end
    end
end
