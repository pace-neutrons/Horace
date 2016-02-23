classdef LogMessage<aMessage
    % Class describes message, used to report job progress
    properties(Dependent)
        % current step within the loop which doing the job
        step
        % number of steps this job will make
        n_steps
        %approximate time spend to make one step of the job
        time_per_step
    end
    
    
    methods
        function obj = LogMessage(step,n_steps,step_time)
            obj = obj@aMessage('running');
            obj.payload=struct('step',step,'n_steps',n_steps,...
                'time',step_time);
        end
        %-----------------------------------------------------------------
        function st=get.step(obj)
            st = obj.payload.step;
        end
        function st=get.n_steps(obj)
            st = obj.payload.n_steps;
        end
        function st=get.time_per_step(obj)
            st = obj.payload.time;
        end
      
    end
    
end

