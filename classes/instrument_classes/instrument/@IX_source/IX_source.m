classdef IX_source
    % Neutron source information
    % Basic information about the source, such as name, target_name and
    % operating frequency
    
    properties (Access=private)
        name_ = '';         % Name of the source e.g. 'ISIS'
        target_name_ = '';  % Name of target e.g. 'TS1'
        frequency_ = 0;     % Operating frequency (Hz)
    end
    
    properties (Dependent)
        name            % Name of the source e.g. 'ISIS'
        target_name     % Name of target e.g. 'TS1'
        frequency       % Operating frequency (Hz)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_source (varargin)
            % Create source object e.g. ISIS target station 1
            %
            %   obj = IX_source (name)
            %   obj = IX_source (name, target_name)
            %   obj = IX_source (name, target_name, frequency)
            %
            % You can specify one or more name-value pairs, where property
            % names must be preceded by a hyphen, but can be abbreviated:
            %
            %   obj = IX_source (..., name, value1, name2, value2,...)
            %
            % Can mix both positional and named values e.g.
            %   >> obj = IX_source ('ISIS','-freq',50)
            %
            % Any positional arguments are replaced by 
            
            namelist = {'name','target_name','frequency'};
            [S, present] = parse_args_namelist (namelist, varargin{:});
            if present.name
                obj.name_ = S.name;
            end
            if present.target_name
                obj.target_name_ = S.target_name;
            end
            if present.frequency
                obj.frequency_ = S.frequency;
            end
        end

        %------------------------------------------------------------------
        % Set methods for independent properties
        %
        % Devolve any checks on interdependencies to the constructor (where
        % we refer only to the independent properties) and in the set 
        % functions for the dependent properties.
        %
        % There is a synchronisation that must be maintained as the checks
        % in both places must be identical.
        
        function obj=set.name_(obj,val)
            if ~is_string(val)
                error('The source name must be a character string')
            end
            obj.name_ = val;
        end
        
        function obj=set.target_name_(obj,val)
            if ~is_string(val)
                error('The target name must be a character string')
            end
            obj.target_name_ = val;
        end
            
        function obj=set.frequency_(obj,val)
            if ~isnumeric(val) || ~isscalar(val) || val<0
                error('The target frequency must be a non-negative number')
            end
            obj.frequency_ = val;
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.name(obj,val)
            obj.name_ = val;
        end
        
        function obj=set.target_name(obj,val)
            obj.target_name_ = val;
        end
        
        function obj=set.frequency(obj,val)
            obj.frequency_ = val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val = obj.name_;
        end
        
        function val=get.target_name(obj)
            val = obj.target_name_;
        end
        
        function val=get.frequency(obj)
            val = obj.frequency_;
        end
        
        %------------------------------------------------------------------
    end
end

