classdef test_hpc_config< TestCase
    % Test basic functionality of configuration classes
    %
    methods
        function obj = test_hpc_config(name)
            if nargin == 0
                name = 'test_hpc_config';
            end
            obj = obj@TestCase(name);
        end

        function test_
    end
end
