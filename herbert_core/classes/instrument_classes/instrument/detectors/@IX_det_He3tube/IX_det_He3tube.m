classdef IX_det_He3tube < IX_det_abstractType
    % IX_det_He3tube Defines array of cylindrical 3He detectors
    % Defines cylindrical 3He gas tube properties on which efficiency,
    % depth of absorption etc depend, namely diameter, wall thickness
    % partial pressure of 3He.
    %
    % The class does not define the position or orientation, which is done
    % elsewhere.

    % Original author: T.G.Perring

    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        dia_    = 0;    % Outer diameter of tube (m) (column vector)
        height_ = 0     % Height (m) (column vector)
        wall_   = 0;    % Wall thickness (m) (column vector)
        atms_   = 0;    % 3He partial pressure (atmospheres) (column vector)
    end

    properties (Dependent)
        % Mirrors of private properties; these define object state:
        dia         % Outer diameter of tube (m) (column vector)
        height      % height (m) (column vector)
        wall        % Wall thickness (m) (column vector)
        atms        % 3He partial pressure (atmospheres) (column vector)
        width       % alias of dia for uniform interface

        % Other dependent properties:
        inner_rad   % Inner radius of tube (get access only) (m)
        
        % Other dependent properties required by abstract template:
        ndet        % Number of detectors (get access only) (scalar)
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_det_He3tube(varargin)
            % Constructor for a set of cylindrical 3He detector
            %
            %   >> obj = IX_det_He3tube (dia, height, wall, atms)
            %
            % Input:
            % ------
            % All arguments can be scalar or arrays; all arrays must have the
            % same number of elements
            %
            %   dia         Outer diameter(s) of tube (m)
            %   height      Height of element(s) (m)
            %   wall        Wall thickness(es) (m)
            %   atms        3He partial pressure(s) (atmospheres)
            %
            % If no arguments are given, then the default is a single detector
            % with zero dimensions and no gas pressure

            if nargin>0
                % Define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                property_names ={'dia', 'height', 'wall', 'atms'};
                mandatory = [true, true, true, true];
                
                % Set positional parameters and key-value pairs and check their
                % consistency using public setters interface. Run
                % check_combo_arg after all settings have been done.
                % All is done within set_positional_and_key_val_arguments
                options = struct('key_dash', true, 'mandatory_props', mandatory);
                [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                    property_names, options, varargin{:});
                
                if ~isempty(remains)
                    error('HERBERT:IX_det_He3tube:invalid_argument', ...
                        ['Unrecognised extra parameters provided as input to ',...
                        'IX_det_He3tube constructor:\n %s'], disp2str(remains));
                end
            else
                oldval = obj.do_check_combo_arg_;
                obj.do_check_combo_arg_ = false;
                obj.dia = obj.dia_;
                obj.height = obj.height_;
                obj.wall = obj.wall_;
                obj.atms = obj.atms_;
                obj.do_check_combo_arg_ = oldval;
            end
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.dia(obj,val)
            if any(val(:)<0)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Tube diameter(s) must be greater or equal to zero')
            end
            obj.dia_=val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj=set.height(obj,val)
            if any(val(:)<0)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Detector element height(s) must be greater or equal to zero')
            end
            obj.height_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj=set.wall(obj,val)
            if any(val(:)<0)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Wall thickness(es) must be greater or equal to zero')
            end
            obj.wall_=val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj=set.atms(obj,val)
            if any(val(:)<0)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Partial pressure(s) of 3He must be greater or equal to zero')
            end
            obj.atms_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.dia(obj)
            val = obj.dia_;
        end
        
        function val = get.width(obj)
            val = obj.dia_; % same as dia for uniform interface
        end

        function val = get.height(obj)
            val = obj.height_;
        end

        function val = get.wall(obj)
            val = obj.wall_;
        end

        function val = get.atms(obj)
            val = obj.atms_;
        end

        function val = get.inner_rad(obj)
            val = 0.5*(obj.dia_ - 2*obj.wall_);
        end

        function val = get.ndet(obj)
            val = numel(obj.dia_);
        end
        %------------------------------------------------------------------
    end
    
    %======================================================================
    % SERIALIZABLE INTERFACE
    %======================================================================

    methods
        function ver = classVersion(~)
            % Current version of class definition
            ver = 2;
        end
        
        function flds = saveableFields(~)
            % Return cellarray of properties defining the class
            flds = {'dia', 'height', 'wall', 'atms'};
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
            
            % Check the consistency of tube diameter and wall thickness
            if  ~all(obj.dia_>=2*obj.wall_)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    ['Tube diameter(s) must be greater or equal to twice ',...
                    'the wall thickness(es)'])
            end
        end
        
        end

    %----------------------------------------------------------------------
    methods(Access=protected)
        function [inputs,obj] = convert_old_struct(obj,inputs,ver)
            % Update structure created from earlier class versions to the current
            % version. Converts the bare structure for a scalar instance of an object.
            % Overload this method for customised conversion. Called within
            % from_old_struct on each element of S and each obj in array of objects
            % (in case of serializable array of objects)
            inputs = convert_old_struct_(obj,inputs);
        end
    end

    %----------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Boilerplate loadobj method, calling the generic loadobj method of
            % the serializable class
            obj = IX_det_He3tube();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
    
end
