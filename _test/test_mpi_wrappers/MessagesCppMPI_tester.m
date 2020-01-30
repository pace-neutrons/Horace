classdef MessagesCppMPI_tester < MessagesCppMPI
    % Class to test protected methods of MessagesCppMPI class
    
    properties
        
    end
    
    methods
        function obj = MessagesCppMPI_tester()
            obj = obj@MessagesCppMPI('test_mode');
            % make tester look like 10 workers
            obj.numLabs_ = uint64(10);
        end
        function  obj = init_framework(obj,framework_info)
            if isstruct(framework_info)
                framework_info.test_mode = true;
            end
            obj = init_framework@MessagesCppMPI(obj,framework_info);
            obj.numLabs_ = uint64(10);
        end
        
        
        function [labNum,nLabs]=get_lab_index(obj)
            [labNum,nLabs] = obj.read_cpp_comm_pull_info();
            obj.numLabs_ = uint64(10);
        end
    end
end

