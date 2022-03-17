classdef IX_inst < serializable
    % Defines the base instrument class. This superclass must be
    % inherited by all instrument classes to unsure that they are
    % discoverable as instruments using isa(my_obj,'IX_inst')
    
    properties (Access=protected)
        name_ = '';             % Name of instrument (e.g. 'LET')
        source_ = IX_source;    % Source (name, or class of type IX_source)
        
    end
    
    properties (Dependent)
        name ;          % Name of instrument (e.g. 'LET')
        source; % Source (name, or class of type IX_source)
    end
    
    methods(Static)
        function isaval = cell_is_class(ca)
            try
                isaval = cellfun(@IX_inst.xxx, ca);
                if all(isaval), isaval = 1; else, isaval = 0; end
            catch
                error('HERBERT:IX_inst:cell_is_class', ...
                      'input could not be converted from cell to logical');
            end
        end
        function rv = xxx(obj)
            rv = isa(obj,'IX_inst');
        end
    end
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst (varargin)
            % Create instrument base information
            %
            %   >> instrument = IX_inst (name)
            %   >> instrument = IX_inst (name, source)
            %
            %   name        Name of instrument (character string)
            %   source      Neutron source
            %               - name of the source e.g. 'ISIS'
            %               - object of class IX_source
            
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name', 'source'};
                [S, present] = parse_args_namelist (namelist, varargin{:});
                if present.name
                    obj.name_ = S.name;
                end
                if present.source
                    obj.source_ = S.source;
                end
            end
        end
        
        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 0; % dummy value for abstract base class
        end
        
        function flds = indepFields(~)
            flds = {'name','source'};
        end
        
        % other methods
        %------------------
        function iseq = eq(obj1, obj2)
            iseq = all(arrayfun(@(x,y)strcmp(x.name, y.name),obj1,obj2));
            if iseq
                iseq = all(arrayfun(@(x,y)eq(x.source,y.source),obj1,obj2));
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
            elseif isempty(val)
                obj.source_ = IX_source();
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
    


    %======================================================================
    % Custom loadobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            %{
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
            %}
            obj = IX_inst();
            obj = loadobj@serializable(S,obj);

        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end
