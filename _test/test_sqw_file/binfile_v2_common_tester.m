classdef binfile_v2_common_tester < binfile_v2_common
    %   Detailed explanation goes here

    properties
        file_version_to_process = 2;
    end

    methods
        function obj = binfile_v2_common_tester(varargin)
            obj = obj@binfile_v2_common();
            if nargin>0
                obj  = obj.init(varargin{:});
            end
        end
        function obj=set_datatype(obj,val)
            % test-helper function used to set some data type
            % should be used in testing only as normally it is calculated
            % from a file structure
            obj.data_type_ = val;
        end

        function [obj,header_pos]=set_header_size(obj,app_header)
            % auxiliary function to calculate various locations of the
            % application header, which defines sqw data format
            % and starting position (data_position) of meaningful sqw data.
            %
            % Used for debugging as default data_position value never changes
            % for any modern sqw file formats
            %
            format = obj.app_header_form_;
            if isempty(obj.sqw_serializer_)
                obj.sqw_serializer_ = sqw_serializer();
            end
            % header_pos
            [header_pos,pos] = obj.sqw_serializer_.calculate_positions(format,app_header,0);
            obj.data_pos_  = pos;
        end

        function mode = get_faccess_mode(obj)
            if obj.file_id_ < 1
                mode = '';
                return;
            end
            [fn,mode] = fopen(obj.file_id_);
            if isempty(fn)
                mode = 'error';
            end
        end
    end
    methods(Access=protected)
        function ver = get_faccess_version(obj)
            ver = obj.file_version_to_process;
        end
        function is_sqw = get_sqw_type(~)
            is_sqw = false;
        end
    end
end

