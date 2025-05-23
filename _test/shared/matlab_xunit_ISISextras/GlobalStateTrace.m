classdef GlobalStateTrace < handle
    %GlobalStateChecker  Singleton class used to trance code for
    % changes in global state and report these changes on request
    %
    % set up tracing by doing:
    %
    % >>ts = GlobalStateTrace.instance();
    % >>ts.trace_enabled = true;
    %
    % before starting to run tests to identify places where test
    % constructor change configuration. Test then prints logs if the global
    % Horace configuration (hor_config, parallel_config or hpc_config) or
    % warning state is changed at unit test construction. 
    % 
    % The calls to the class instance can also be added to other code 
    % to trace for changes in global configuration.
    %
    % Set break-point in this object's "trace" function where changed
    % configuration is stored for future usage:
    % (obj.state_holder_ = current_state;)
    % to investigate details of change using MATLAB debugger
    %
    properties(Dependent)
        % if the tracing should be enabled
        trace_enabled;
        % variable which contains a structure with current global state
        % values
        state_holder;
    end
    properties(Access=protected)
        state_holder_ = [];
        trace_enabled_ = false;
    end
    methods
        function is = get.trace_enabled(obj)
            is = obj.trace_enabled_;
        end
        function state = get.state_holder(obj)
            state = obj.state_holder_;
        end
        %
        function set.trace_enabled(obj,val)
            % Enable/disable tracing for the code
            new_state  = logical(val);
            obj.trace_enabled_ = new_state;
        end
        function difr = trace(obj)
            % Trace changes in global configuration and return difference
            % in configuration if global configuration changed.
            if ~obj.trace_enabled
                difr = [];
                return;
            end
            current_state = struct();
            current_state.warning_state = warning;

            hc = hor_config;
            current_state.hor_state = hc.get_data_to_store;
            pc = parallel_config;
            current_state.parallel_state = pc.get_data_to_store;
            hpc = hpc_config;
            current_state.hpc_state = hpc.get_data_to_store;
            if isempty(obj.state_holder_)
                obj.state_holder_ = current_state;
            end
            difr = compare_states(obj.state_holder_,current_state);
            if ~isempty(difr)
                % store changed state to keep track of next change
                obj.state_holder_ = current_state;
            end
        end
    end
    methods(Static)
        function obj = reset()
            % reset tracing to beginning
            obj = GlobalStateTrace.instance('clear');
        end
        function obj = instance(varargin)
            % clear instance of the tracer if
            persistent obj_state;
            if nargin>0 && ischar(varargin{1})
                obj_state = [];
            end
            if isempty(obj_state)
                obj_state = GlobalStateTrace();
            end
            obj=obj_state;
        end
    end
    methods(Access=private)
        function obj = GlobalStateTrace()
            % private construcntor which stets state to defaults.
        end
    end
end

function difr = compare_states(original,other_one)
% compare contents of two structures with the same fields
difr = struct([]);
if numel(original) ~= numel(other_one)
    %n_base = min(numel(original),numel(other_one));
    difr = struct('new_minus_old_elements',numel(other_one)-numel(original), ...
        'old_array',original,'new_array',other_one);
    return;
end
if isstruct(original)
    if numel(original)>1
        for j=1:numel(original)
            difr = compare_states(original(j),other_one(j));
            if ~isempty(difr)
                difr.elementN=j;
                return;
            end
        end
    else
        fn = fieldnames(original);
        for i=1:numel(fn)
            difr1 = compare_states(original.(fn{i}),other_one.(fn{i}));
            if ~isempty(difr1)
                difr = struct('field',fn{i}, ...
                    'difference',difr1);
                return;
            end
        end
    end
end
if ~isequal(original,other_one)
    difr = struct('old_element',original, ...
        'new_element',other_one);
end
end
