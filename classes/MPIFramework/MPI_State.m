classdef MPI_State<handle
    % Helper class, to identify status of Matlab job, namely if current
    % matlab session is independent session or is deployed by Herbert MPI
    % framework, and to help deploy methods, which would depend on such
    % status
    %
    % Implemented as classical singleton.
    
    properties(Dependent)
        % report if the matlab session is deployed
        is_deployed
        % logger function to deploy to log activities
        logger
        % method helps to identify that the framework is tested and to
        % disable some framework capability, which should be used in this
        % situation
        is_tested
    end
    properties(Access=protected)
        is_deployed_=false;
        logger_func_ = [];
        is_tested_ = false;
    end
    properties(Constant, Access=protected)
        field_names_ = {'is_deployed','is_tested','logger_func'}
    end
    %----------------------------------------------------------------------
    methods(Access=private)
        function obj=MPI_State()
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = instance()
            persistent obj_state;
            if isempty(obj_state)
                obj_state = MPI_State();
            end
            obj=obj_state;
        end
    end
    %----------------------------------------------------------------------
    methods
        %------------------------------------------------------
        function is = get.is_deployed(obj)
            is = obj.is_deployed_;
        end
        function is = get.is_tested(obj)
            is = obj.is_tested_;
        end
        function flog = get.logger(obj)
            flog = obj.logger_func_;
        end
        %------------------------------------------------------
        function set.is_deployed(obj,val)
            obj.is_deployed_=val;
        end
        function set.is_tested(obj,val)
            obj.is_tested_=val;
        end
        function set.logger(obj,fun)
            if ~isa(fun, 'function_handle')
                error('MPI_STATE:invalid_argument',...
                    ' value assigned to lgger function has to be a function handle')
            end
            obj.logger_func_=fun;
        end
        function setattr(obj,varargin)
            par=varargin(1:2:nargin-1);
            val=varargin(2:2:nargin-1);
            if ~any(ismember(par,obj.field_names_))
                error('MPI_STATE:invalid_argument',' Field %s is not the class attribute',par{:});
            else
                if iscell(par)
                    for i=1:numel(par)
                        obj.([par{i},'_'])=val{i};
                    end
                else
                    obj.([par,'_'])=val;
                end
            end
        end
    end
    
    
end

