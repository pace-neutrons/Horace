classdef IX_null_sample < IX_samp
    %IX_NULL_SAMPLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % none beyond IX_sample
    end
    
    methods
        function obj = IX_null_sample()
            
            %obj = obj@IX_sample([1.0 1.0 1.0],[90 90 90]);
        end
        
        function str = null_struct(~)
            str = struct();
        end
    end
end

