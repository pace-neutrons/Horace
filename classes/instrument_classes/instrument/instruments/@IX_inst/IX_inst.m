classdef IX_inst
    % Defines the base instrument class
    
    properties (Access=private)
        name_ = '';             % Name of instrument (e.g. 'LET')
        source_ = IX_source;    % Source (name, or class of type IX_source)
    end
    
    properties (Dependent)
        name = '';          % Name of instrument (e.g. 'LET')
        source = IX_source; % Source (name, or class of type IX_source)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst (varargin)
            % Create instrument base information
            %
            %   >> obj = IX_inst (name)
            %   >> obj = IX_inst (name, source)
            %
            % Input:
            % ------
            %   name        Name of instrument (character string)
            %   source      Neutron source
            %               - name of the source e.g. 'ISIS'
            %               - object of class IX_source
            
            namelist = {'name', 'source'};
            [S, present] = parse_args_namelist (namelist, varargin{:});
            if present.name
                obj.name_ = S.name;
            end
            if present.source
                obj.source_ = S.source;
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
            
        function obj=set.source_(obj,val)
            if isa(val,'IX_source') && isscalar(val)
                obj.source_ = val;
            elseif is_string(val)
                obj.source_ = IX_source('-name',val);
            else
                error('The source name must be a character string or an IX_source object')
            end
        end
            
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.name(obj,val)
            obj.name_ = val;
        end
        
        function obj=set.source(obj,val)
            obj.source_ = val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val = obj.name_;
        end
        
        function val=get.source(obj)
            val = obj.source_;
        end
        
        %------------------------------------------------------------------
    end
    
end
