classdef IX_source
    % Neutron source information
    % Basic information about the source, such as name, target_name and
    % operating frequency
    
    properties (Access=private)
        class_version_ = 1; % Class version number
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
            %   obj = IX_source (frequency)
            %   obj = IX_source (name,...)
            %   obj = IX_source (name, target_name,...)
            %
            % Optional:
            %   frequency       Source frequency
            %   name            Source name e.g. 'ISIS'
            %   target_name     Name of target e.g. 'TS2'
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the 
            % argument name (including abbrevioations) with a preceding hyphen e.g.
            %
            %   >> obj = IX_source ('ISIS','-freq',50)
            
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_source.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name','target_name','frequency'};
                [S, present] = parse_args_namelist...
                    ({namelist,{'char','char'}}, varargin{:});
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

    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStrucIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStrucIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
        end
    end
    
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
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end
