classdef IX_det_TobyfitClassic < IX_det_abstractType
    % IX_det_TobyfitClassic    Reproduces results of original Tobyfit detectors
    % Defines a detector type that reproduces the random point sampling of the
    % original Tobyfit. The 3He tube axes are assumed always to be perpendicular
    % to the neutron path. The distance variances and random points are returned
    % as old Tobyfit. Efficiency is returned as unity and distance averages as
    % zero.
    %
    % Created solely to enable tests of Tobyfit against the original version.

    % Original author: T.G.Perring

    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % may require checks against the other properties
        dia_ = 0;       % Outer diameter of tube (m) (column vector)
        height_ = 0;    % Height (m) (column vector)
    end

    properties (Dependent)
        % Mirrors of private properties; these define object state:
        dia         % Outer diameter of tube (m) (column vector)
        height      % Height (m) (column vector)
        width       % alias of dia to provide uniform interface across detector types

        % Other dependent properties required by abstract template:
        ndet        % Number of detectors (get access only) (scalar)
    end


    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_det_TobyfitClassic(varargin)
            % Constructor for Tobyfit Classic detector object
            %
            %   >> obj = IX_det_TobyfitClassic (dia, height)
            %
            % Input:
            % ------
            % All arguments can be scalar or arrays; all arrays must have the
            % same number of elements
            %
            %   dia         Outer diameter(s) of tube (m)
            %   height      Height of element(s) (m)


            if nargin>0
                % Define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                property_names = {'dia','height'};
                mandatory = [true, true];

                % Set positional parameters and key-value pairs and check their
                % consistency using public setters interface. Run
                % check_combo_arg after all settings have been done.
                % All is done within set_positional_and_key_val_arguments
                options = struct('key_dash', true, 'mandatory_props', mandatory);
                [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                    property_names, options, varargin{:});

                if ~isempty(remains)
                    error('HERBERT:IX_det_TobyfitClassic:invalid_argument', ...
                        ['Unrecognised extra parameters provided as input to ',...
                        'IX_det_TobyfitClassic constructor:\n %s'], disp2str(remains));
                end
            else
                oldval = obj.do_check_combo_arg_;
                obj.do_check_combo_arg_ = false;
                obj.dia = obj.dia;
                obj.height = obj.height;
                obj.do_check_combo_arg_ = oldval;
            end
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.dia(obj,val)
            if any(val(:) < 0)
                error('HERBERT:IX_det_TobyfitClassic:invalid_argument', ...
                    'Tube diameter(s) must be greater or equal to zero')
            end
            obj.dia_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj=set.height(obj,val)
            if any(val(:) < 0)
                error('HERBERT:IX_det_TobyfitClassic:invalid_argument', ...
                    'Detector element height(s) must be greater or equal to zero')
            end
            obj.height_ = val(:);
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
            val = obj.dia_; % same as get.dia, provides common interface
        end

        function val = get.height(obj)
            val = obj.height_;
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
            % Returns the current class version number.
            ver = 2;
        end

        function flds = saveableFields(~)
            % Return the names of public properties which fully define the
            % object state.
            flds = {'dia','height'};
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
            obj = obj.clear_hash();
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

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Boilerplate loadobj method, calling the generic loadobj method of
            % the serializable class
            obj = IX_det_TobyfitClassic();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================

end
