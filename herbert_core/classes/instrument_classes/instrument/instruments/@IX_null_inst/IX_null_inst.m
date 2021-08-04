classdef IX_null_inst < IX_inst
    % An instrument constructed from a struct with no fields
    % As the new Experiment class has an array of IX_inst, we need
    % something derived from IX_inst to hold the case where the file from
    % which the sqw is created has these empty struct instruments.
    % This class will provide a conversion to an empty struct.
    
    properties
        % none in addition to the base IX_inst
    end
    
    methods
        function obj = IX_null_inst()
            % constructs a vanilla instance based on IX_inst
            obj = obj@IX_inst();
        end
        
        function str = null_struct(~)
            %makes the null struct for storage in a file
            str = struct();;
        end
    end
end

