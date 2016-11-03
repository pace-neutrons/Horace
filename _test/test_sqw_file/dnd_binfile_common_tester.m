classdef dnd_binfile_common_tester < dnd_binfile_common
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % initialize the loader, to be ready to read or write the data
        function obj = init(obj,varargin)
            error('DND_BINFILE_COMMON_TESTER:not_implemented','init not implemented')
        end
        
        
        function obj=set_datatype(obj,val)
            % test-helper function used to set some data type
            % should be used in testing only as normally it is calculated
            % from a file structure
            obj.data_type_ = val;
        end
        
    end
    
end

