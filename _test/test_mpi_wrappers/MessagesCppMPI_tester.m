classdef MessagesCppMPI_tester < MessagesCppMPI
    % Class to test protected methods of MessagesCppMPI class
    
    properties
    end
    
    methods
        function obj = MessagesCppMPI_tester(varargin)
            if nargin == 0
                cs = 'test_mode';
            else
                cs = varargin{1};
            end
            obj = obj@MessagesCppMPI(cs);
            obj.time_to_fail_ = 10;
        end
        function  obj = init_framework(obj,framework_info)
            if isstruct(framework_info)
                framework_info.test_mode = true;
            end
            obj = init_framework@MessagesCppMPI(obj,framework_info);
        end
        
        
        function [labNum,nLabs]=get_lab_index(obj)
            [labNum,nLabs] = obj.read_cpp_comm_pull_info();
        end
    end
end

