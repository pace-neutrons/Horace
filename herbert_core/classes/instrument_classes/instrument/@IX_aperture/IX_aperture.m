classdef IX_aperture < serializable
    % Aperture class definition
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        name_ = '';
        distance_ = 0;
        width_ = 0;
        height_ = 0;
    end
    
    properties (Dependent)
        % Mirrors of private properties
        name
        distance
        width
        height
    end
    
    methods
        
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_aperture (varargin)
            % Create sample object
            %
            %   >> aperture = IX_aperture (distance, width, height)
            %   >> aperture = IX_aperture (name, distance, width, height)
            %
            % Required:
            %   distance        Distance from sample (-ve if upstream, +ve if downstream)
            %   width           Full width of aperture (m)
            %   height          Full height of aperture (m)
            %
            % Optional:
            %   name            Name of the aperture (e.g. 'in-pile')
            %
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the
            % argument name (including abbreviations) with a preceding hyphen e.g.
            %
            %   ap = IX_aperture (distance, width, height,'-name','in-pile')
            
            
            % Original author: T.G.Perring
            
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_aperture.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name','distance','width','height'};
                [S, present] = parse_args_namelist ({namelist,{'char'}}, varargin{:});
                
                if present.name
                    obj.name_ = S.name;
                end
                if present.distance && present.width && present.height
                    obj.distance_ = S.distance;
                    obj.width_ = S.width;
                    obj.height_ = S.height;
                else
                    error('HERBERT:IX_apperture:invalid_argument',...
                        'Must give distance, width and height')
                end
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.name(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                error('HERBERT:IX_apperture:invalid_argument',...
                    'Sample name must be a character string (or empty string)')
            end
            
            obj.name_=val;
        end
        
        function obj=set.distance(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
            else
                error('HERBERT:IX_apperture:invalid_argument',...
                    'Distance must be a numeric scalar')
            end
            
            obj.distance_=val;
        end
        
        function obj=set.width(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
            else
                error('HERBERT:IX_apperture:invalid_argument',...
                    'Aperture width must be a numeric scalar greater than or equal to zero')
            end
            
            obj.width_=val;
        end
        
        function obj=set.height(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
            else
                error('HERBERT:IX_apperture:invalid_argument',...
                    'Aperture height must be a numeric scalar greater than or equal to zero')
            end
            obj.height_=val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end
        
        function val=get.distance(obj)
            val=obj.distance_;
        end
        
        function val=get.width(obj)
            val=obj.width_;
        end
        
        function val=get.height(obj)
            val=obj.height_;
        end
        %------------------------------------------------------------------
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_struct
            % function, but when the old strucure substantially differs from
            % the moden structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            if isfield(inputs(1),'class_version_') && inputs(1).class_version_ == 1
                inputs = rmfield(inputs,'class_version_');
                old_fld_names = fieldnames(inputs);
                % use the fact that the old field names are the new field
                % names with _ attached at the end
                new_fld_names = cellfun(@(x)(x(1:end-1)),old_fld_names,...
                    'UniformOutput',false);
                cell_data = struct2cell(inputs);
                inputs = cell2struct(cell_data,new_fld_names);
            end
            % optimization here is possible to not to use the public
            % interface. But is it necessary? its the question
            obj = from_old_struct@serializable(obj,inputs);
        end
        
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
                % here we rely on agreement that private independent
                % porperties have the same names as public properties but
                % have added suffix '_' at the end
                names_store = cellfun(@(x)x(1:end-1),...
                    names_store,'UniformOutput',false);
            end
            names = names_store;
        end
    end
    
    methods
        function flds = indepFields(obj)
            % Return cellarray of independent properties of the class
            %
            flds = obj.propNamesIndep_;
        end
        function ver  = classVersion(~)
            % return current class version as it is stored on hdd
            ver = 2;
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)        
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = IX_aperture();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
    
end
