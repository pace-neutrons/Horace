classdef par_config_no_worker_4test<parallel_config
    % Test class to verify parallel_config for case where herbert is not
    % configured for parallel extensions
    %
    % 
    properties

    end
    
    methods
        function obj = par_config_no_worker_4test()
            obj = obj@parallel_config();
            obj.worker_ = 'non_existing_worker';
       end
    end
end

