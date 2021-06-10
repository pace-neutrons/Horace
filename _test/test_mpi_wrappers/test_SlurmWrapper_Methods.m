classdef test_SlurmWrapper_Methods < TestCase
    properties
        stored_config ='defaults';
        stored_control;
    end
    methods
        
        function obj = test_SlurmWrapper_Methods(name)
            if ~exist('name', 'var')
                name = 'test_SlurmWrapper_Methods';
            end
            obj = obj@TestCase(name);
        end
        function test_parse_bashrc(~)
        end
  
    end
end
