classdef MessagesCppMPI_3wkrs_tester < MessagesCppMPI
    % Class to test protected methods of MessagesCppMPI class
    
    properties
        
    end
    
    methods
        function obj = MessagesCppMPI_3wkrs_tester()
            obj = obj@MessagesCppMPI('test_mode');
            % make tester look like 3 workers
            obj.numLabs_ = uint64(3);
        end
        function  obj = init_framework(obj,framework_info)
            if isstruct(framework_info)
                framework_info.test_mode = true;
            end
            obj = init_framework@MessagesCppMPI(obj,framework_info);
            obj.numLabs_ = uint64(3);
        end
        
        function [labNum,nLabs]=get_lab_index(obj)
            [labNum,nLabs] = obj.read_cpp_comm_pull_info();
            obj.numLabs_ = uint64(3);
        end
        function [receive_now,mess_names,n_steps] = check_whats_coming_tester(obj,task_ids,mess_name,mess_array,n_steps)
            [receive_now,mess_names,n_steps] = obj.check_whats_coming(task_ids,mess_name,mess_array,n_steps);
        end
        
    end
end

