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
        function [bls,map] = get_cblock_sizes(obj,varargin)
            [bls,map] = obj.calc_cblock_sizes(varargin{:});
        end
        
        
    end
end

