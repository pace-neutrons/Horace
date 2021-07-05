classdef ClusterWrapperTester < ClusterWrapper
    % As Cluster Wrapper is an abstract class,
    % This class is used for testing ClusterWrapper specific methods
    
    
    methods
        function obj = ClusterWrapperTester(n_workers,mess_exchange_framework,log_level)
            if nargin<3
                log_level = -1;
            end
            
            obj = obj@ClusterWrapper(n_workers,mess_exchange_framework,log_level);
        end
        
        function  ok = is_job_initiated(~)
            error('HERBERT:ClusterWrapper:not_implemented',...
                'This method is not implemented on ClusterWrapper level so should not be tested')
        end
    end
    methods(Access=protected)
        function [ok,failed,paused,mess] = get_state_from_job_control(~)
            % get the state of running job by requesting reply from the job
            % control mechanism.
            %
            % Cluster wrapper does not test this method, but the method is
            % invoked when some other ClusterWrapper methods are tested.
            % Always return running state
            
            ok = true;
            failed = false;
            paused = false;
            mess = 'running';
        end
    end
end

