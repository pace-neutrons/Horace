classdef IX_det_slab < IX_det_abstractType
    % IX_det_slab    Array of cuboidal detectors
    % Defines the size and absorption of an array of cuboidal detectors.
    %
    % The class does not define the position or orientation, which is done
    % elsewhere.

    % Original author: T.G.Perring
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % may require checks against the other properties
        depth_  = 0;    % Detector element thicknesses (m) (column vector)
        width_  = 0;    % Detector element widths (m) (column vector)
        height_ = 0;    % Detector element heights (m) (column vector)
        atten_  = 0;    % Attenuation length (to 1/e) at 2200 m/s (m) (column vector)
    end

    properties (Dependent)
        % Mirrors of private properties; these define object state:
        depth       % Detector element thicknesses (m) (column vector)
        width       % Detector element widths (m) (column vector)
        height      % Detector element heights (m) (column vector)
        atten       % Attenuation length (to 1/e) at 2200 m/s (m) (column vector)

        % Other dependent properties required by abstract template:
        ndet        % Number of detectors (get access only) (scalar)s        
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_det_slab (varargin)
            % Constructor for cuboidal detector
            %
            %   >> obj = IX_det_slab (depth, width, height, atten)
            %
            % The origin of the detector coordinate frame the the centre of the detector
            % and has x perpendicular to the detector face but into the detector. The
            % fron face of the detector is therefore at negative x.
            %
            % Input:
            % ------
            % All arguments can be scalar or arrays; all arrays must have the
            % same number of elements
            %
            %   depth       Depth of detector elements (m) (x axis)
            %   width       Width of detector elements (m) (y axis)
            %   height      Height of detector elements (m) (z axis)
            %   atten       Attenuation distance at 2200 m/s (m)

            if nargin>0
                % Define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                property_names = {'depth', 'width', 'height', 'atten'};
                mandatory = [true, true, true, true];

                % Set positional parameters and key-value pairs and check their
                % consistency using public setters interface. Run
                % check_combo_arg after all settings have been done.
                % All is done within set_positional_and_key_val_arguments
                options = struct('key_dash', true, 'mandatory_props', mandatory);
                [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                    property_names, options, varargin{:});
                
                if ~isempty(remains)
                    error('HERBERT:IX_det_slab:invalid_argument', ...
                        ['Unrecognised extra parameters provided as input to ',...
                        'IX_det_slab constructor:\n %s'], disp2str(remains));
                end
            end
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj = set.depth(obj, val)
            if any(val(:) < 0)
                error('HERBERT:IX_det_slab:invalid_argument', ...
                    'Detector element depth(s) must be greater or equal to zero')
            end
            obj.depth_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj = set.width(obj, val)
            if any(val(:) < 0)
                error('HERBERT:IX_det_slab:invalid_argument', ...
                    'Detector element width(s) must be greater or equal to zero')
            end
            obj.width_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj = set.height(obj, val)
            if any(val(:) < 0)
                error('HERBERT:IX_det_slab:invalid_argument', ...
                    'Detector element height(s) must be greater or equal to zero')
            end
            obj.height_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj = set.atten(obj, val)
            if any(val(:) < 0)
                error('HERBERT:IX_det_slab:invalid_argument', ...
                    'Detector element attenuation length(s) must be greater or equal to zero')
            end
            obj.atten_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.depth(obj)
            val = obj.depth_;
        end

        function val = get.width(obj)
            val = obj.width_;
        end

        function val = get.height(obj)
            val = obj.height_;
        end

        function val = get.atten(obj)
            val = obj.atten_;
        end

        function val = get.ndet(obj)
            val = numel(obj.depth_);
        end
        %------------------------------------------------------------------

    end
    
    %======================================================================
    % SERIALIZABLE INTERFACE
    %======================================================================

    methods
        function ver = classVersion(~)
            ver = 2;
        end
        
        function flds = saveableFields(~)
            % Return cellarray of properties defining the class
            flds = {'depth', 'width', 'height', 'atten'};
        end

        function obj = check_combo_arg(obj)
            % Verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check.
            %
            % Recompute any cached arguments.
            %
            % Throw an error if the properties are inconsistent and return
            % without problem it they are not.

            flds = obj.saveableFields();
            
            % Inherited method from IX_det_abstractType
            obj = obj.expand_internal_properties_to_max_length (flds);            
        end
        
    end
    
    %----------------------------------------------------------------------
    methods(Access=protected)
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

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Boilerplate loadobj method, calling the generic loadobj method of
            % the serializable class
            obj = IX_det_slab();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
    
end
