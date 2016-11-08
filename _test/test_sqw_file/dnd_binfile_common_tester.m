classdef dnd_binfile_common_tester < dnd_binfile_common
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
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
        
    end
end

