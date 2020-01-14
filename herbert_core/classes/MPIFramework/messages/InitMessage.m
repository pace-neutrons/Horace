classdef InitMessage < aMessage
    % Helper class desfines a message, used to transfer initial
    % information to a single task of a distributed job.
    %
    %
    % $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
    %
    %
    properties(Dependent)
        %
        n_first_step
        n_steps
        
        common_data
        loop_data
        % if the task needs to return results
        return_results
    end
    properties(Access = protected)
    end
    
    
    methods
        function obj = InitMessage(common_data,loop_data,return_results,n_first_step)
            % Construct the intialization message
            %
            % Inputs:
            % common_data -- the structure, contaning data common to any
            %                loop iteration
            % loop_data   -- either cellarray of data, with each cell
            %                specific to a single loop iteration or
            %                number of iteration (n_steps) to perform over
            %                common data
            % return_results --if task needs to return its results
            %              if true, task will return its results
            %              if false or empty, no results expected to be
            %              returned
            % n_first_step -- the number of the first step in the loop to
            %                 do n_steps, if absent or loop data provided as
            %                 a cellarray it assumed to be 1
            %
            obj = obj@aMessage('init');
            obj.is_blocking_ = true;
            if ~exist('common_data','var')
                common_data = [];
                loop_data = 1;
            end
            if ~exist('return_results','var')
                return_results = false;
            end
            obj.payload = struct('common_data',common_data,...
                'loopData',[],'n_first_step',1,'n_steps',0,...
                'return_results',return_results );
            if ~exist('n_first_step','var')
                n_first_step = 1;
            end
            if iscell(loop_data)
                obj.payload.loopData = loop_data;
                obj.payload.n_steps   = numel(loop_data);
                obj.payload.n_first_step  = 1;
            elseif isstruct(loop_data)
                fn = fieldnames(loop_data);
                obj.payload.loopData = loop_data;
                % would not work correctly if the first field was string
                obj.payload.n_steps   = numel(loop_data.(fn{1}));
                obj.payload.n_first_step  = 1;
            else
                obj.payload.n_steps  = loop_data;
                obj.payload.n_first_step  = n_first_step;
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
            yesno  = obj.payload.return_results;
        end
        function nfs = get.n_first_step(obj)
            nfs = obj.payload.n_first_step;
        end
        
        
    end
end


