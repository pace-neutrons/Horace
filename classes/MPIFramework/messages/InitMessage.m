classdef InitMessage < aMessage
    % Helper class desfines a message, used to transfer initial
    % information to a single task of a remote job.
    %
    %
    % $Revision: 713 $ ($Date: 2018-02-23 16:52:46 +0000 (Fri, 23 Feb 2018) $)
    %
    %
    
    properties(Dependent)
        %
        n_steps
        common_data
        loop_data
        % if the task needs to return results
        return_results
    end
    properties(Access = protected)
        return_results_ = false;
    end
    
    methods
        function obj = InitMessage(common_data,loop_data,return_results)
            % Construct the intialization message
            % Inputs:
            %common_data -- the structure, contaning data common to any
            %               loop iteration
            % loop_data  -- either cellarray of data, with each cell
            %               specific to a single loop iteration or
            %               number of iteration to perform over common data
            %
            % return_results --if task needs to return its results
            %              if true, task will return its results
            %              if false or absent, no results expected to be
            %              returned
            %
            obj = obj@aMessage('init');
            obj.payload = struct('common_data',common_data,...
                'loopData',[],'n_steps',0);
            if numel(loop_data) > 1
                obj.payload.loop_data = loop_data;
                obj.payload.n_steps   = numel(loop_data);
            else
                obj.payload.n_steps  = loop_data;
            end
            if exist('return_results','var')
                obj.return_results_  = return_results;
            else
                obj.return_results_  = false;
            end
            
        end
        
        function n_steps = get.n_steps(obj)
            n_steps =obj.payload.n_steps;
        end
        function cd = get.common_data(obj)
            cd = obj.payload.common_data;
        end
        function cd = get.loop_data(obj)
            cd = obj.payload.loopData;
        end
        function yesno = get.return_results(obj)
            yesno  = obj.return_results_;
        end
        
    end
end

