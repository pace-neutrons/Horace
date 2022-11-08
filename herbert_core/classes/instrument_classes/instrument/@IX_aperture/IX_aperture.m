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
        mandatory_field_set_ = false(1,3);
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
            %   >> aperture = IX_aperture (distance, width, height,name)
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
            % argument name (including abbreviations) e.g.:
            %
            %   ap = IX_aperture (distance, width, height,'name','in-pile')


            % Original author: T.G.Perring


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_aperture.loadobj(varargin{1});
            elseif nargin>0
                pos_params = obj.saveableFields();
                if ischar(varargin{1})&&~strncmp(varargin{1},'-',1)&&~ismember(varargin{1},pos_params)
                    argi = varargin(2:end);
                    obj.name = varargin{1};
                else
                    argi = varargin;
                end
                [obj,remains] = set_positional_and_key_val_arguments(obj,...
                    pos_params,true,argi{:});
                if ~isempty(remains)
                    error('HERBERT:IX_aperture:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_aperture constructor: %s',...
                        disp2str(remains));
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
                obj.mandatory_field_set_(1)=true;
            else
                error('HERBERT:IX_apperture:invalid_argument',...
                    'Distance must be a numeric scalar')
            end
        end

        function obj=set.width(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
                obj.mandatory_field_set_(2)=true;
            else
                error('HERBERT:IX_apperture:invalid_argument',...
                    'Aperture width must be a numeric scalar greater than or equal to zero')
            end
        end

        function obj=set.height(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
                obj.mandatory_field_set_(3)=true;
            else
                error('HERBERT:IX_apperture:invalid_argument',...
                    'Aperture height must be a numeric scalar greater than or equal to zero')
            end
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
        %
        % calculate covariance
        C = covariance (self);
        % Generate random points in an aperture
        X = rand (self, varargin)
    end
    methods(Access=protected)
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
            inputs = convert_old_struct_(obj,inputs);
            % optimization here is possible to not to use the public
            % interface. But is it necessary? its the question
            obj = from_old_struct@serializable(obj,inputs);

        end
    end


    %======================================================================
    methods
        function flds = saveableFields(~,mandatory)
            % Return cellarray of independent properties of the class
            %
            if exist('mandatory','var')
                mandatory = true;
            else
                mandatory = false;
            end
            flds = {'distance','width','height','name'};
            if mandatory
                flds = flds(1:3);
            end
        end
        function ver  = classVersion(~)
            % return current class version as it is stored on hdd
            ver = 2;
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing dependent variables
            %  if requested.


            if ~all(obj.mandatory_field_set_)
                mandatory_field_names = obj.saveableFields('mandatory');
                error('HERBERT:IX_aperture:invalid_argument', ...
                    'Must give all mandatory properties namely: %s\n. Properties: %s have not been set', ...
                    disp2str(mandatory_field_names),...
                    disp2str(mandatory_field_names(~obj.mandatory_field_set_)));
            end

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
