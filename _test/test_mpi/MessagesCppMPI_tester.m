classdef MessagesCppMPI_tester < MessagesCppMPI
    % Class to test protected methods of MessagesCppMPI class
    
    properties

    end
    
    methods
        function obj = MessagesCppMPI_tester(varargin)
            obj = obj@MessagesCppMPI(varargin{:});
        end
        
        function [obj,labNum,nLabs]=lab_index_test(obj)
            [obj,labNum,nLabs] = obj.lab_index_tester();
        end
    end
end

