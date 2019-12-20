classdef MessagesCppMPI_tester < MessagesCppMPI
    % Class to test protected methods of MessagesCppMPI class
    
    properties

    end
    
    methods
        function obj = MessagesCppMPI_tester()
            obj = obj@MessagesCppMPI('test_mode');
        end
        
        function [labNum,nLabs]=get_lab_index(obj)
            [labNum,nLabs] = obj.read_cpp_comm_pull_info();
        end
    end
end

