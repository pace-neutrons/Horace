classdef parallel_config_tester<parallel_config
    %Class used to test parallel configuration
    %
    methods
        function obj = parallel_config_tester()
            obj=obj@parallel_config();
            config_store.instance.set_saveable(parallel_config,false);                        
        end
        function obj=set_worker(obj,worker_name)            
            obj.worker_ = worker_name;
            config_store.instance().store_config('parallel_config',...
                'worker',worker_name);
            
        end
    end
end

