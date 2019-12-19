classdef MessagesCppMPI_tester < MessagesCppMPI
    % Class to test protected methods of MessagesCppMPI class
    
    properties

    end
    
    methods
        function obj = MessagesCppMPI_tester(varargin)
            obj = obj@MessagesCppMPI(varargin{:});
        end
        
        function [obj,labNum,nLabs]=get_lab_index(obj)
            [obj,labNum,nLabs] = obj.read_cpp_comm_pull_info();
        end
    end
end

