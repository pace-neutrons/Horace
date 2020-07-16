classdef test_worker_fail_mode< TestCase
    %
    properties
        % this will be tested
        worker_h = 'worker_v2';
        skip_test = false;
    end
    methods
        %
        function obj=test_worker_fail_mode(name)
            if ~exist('name','var')
                name = 'test_worker_fail_mode';
            end
            % testing this on file-based framework only
            obj = obj@TestCase(name);
            if isempty(which(obj.worker_h))
                warning(' Can not test worker fail mode');
                obj.skip_test = true;
            end
        end
        %
        function test_invalid_input(obj)
            if obj.skip_test
                return;
            end
        end
        
    end
    
end
