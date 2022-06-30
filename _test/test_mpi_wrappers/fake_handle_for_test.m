classdef fake_handle_for_test < handle
    % This class represents fake handle, used in tests 
    
    properties

    end
    
    methods
        function obj = fake_handle_for_test()
        end
        
        function destroy(obj)
            % fake destroy method
        end
    end
end

