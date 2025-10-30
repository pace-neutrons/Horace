classdef sqw_binfile_common_tester < sqw_binfile_common
    %   Class used for testing sqw_binfile_common class which may be an
    %   abstract class, so it defines the missing methods to test the
    %   methods which are defined

    properties
        is_mangled;
        file_version = 3;
    end
    properties(Access=protected)
        sqw_binfile_accessor_ = [];
    end

    methods
        % initialize the loader, to be ready to read or write the data
        function obj = init(obj,accessor)
            if nargin<2 || ~(isa(accessor,'sqw_binfile_common') || isa(accessor,'faccess_sqw_v4_1'))
                error('HORACE:sqw_binfile_common_tester:invalid_argument', ...
                    'init can be called only with a version of an file accessor')
            end
            obj.sqw_binfile_accessor_ = accessor;
        end
        function obj = set_data_type(obj,val)
            obj.data_type_ = val;
        end
        function is = get.is_mangled(obj)
            is = false;
            if isempty(obj.sqw_binfile_accessor_ )
                return;
            end
            if isa(obj.sqw_binfile_accessor_,'sqw_binfile_common')
                is = obj.sqw_binfile_accessor_.contains_runid_in_header_;
            else
                is  = false;
            end
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
        function new_obj = upgrade_file_format(~)
            error('HORACE:sqw_binfile_common_tester:not_implemented', ...
                'generic file format upgrade is not implemented')
        end
    end
    methods(Access=protected)
        function ver = get_faccess_version(obj)
            ver = obj.file_version;
        end
    end

end

