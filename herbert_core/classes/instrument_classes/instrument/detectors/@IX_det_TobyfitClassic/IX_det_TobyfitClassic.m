classdef IX_det_TobyfitClassic < IX_det_abstractType
    % Defines a detector type that reproduces the results of original Tobyfit.
    % The tube axes are assumed always to be perpendicular to the neutron path.
    % The distance variances and random points are returned as old Tobyfit.
    % Efficiency is returned as unity and distance averages as zero.
    %
    % Created solely to enable tests of Tobyfit against the original version.


    % Original author: T.G.Perring
    %

    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        dia_ = 0;       % Outer diameter of tube (m)
        height_ = 0     % Height (m)
        mandatory_field_set_ = false(1,2);
    end

    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m)
        height      % height (m)
        % Other dependent properties required by abstract template
        ndet        % Number of detectors
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
                % define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                pos_params = obj.saveableFields();
                % set positional parameters and key-value pairs and check their
                % consistency using public setters interface. Run
                % check_compo_arg after all settings have been done.
                [obj,remains] = set_positional_and_key_val_arguments(obj,pos_params,...
                    true,varargin{:});
                if ~isempty(remains)
                    error('HERBERT:IX_det_TobyfitClassic:invalid_argument', ...
                        'Unrecognised extra parameters provided as input to IX_det_TobyfitClassic constructor: %s',...
                        disp2str(remains));
                end
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
            obj.mandatory_field_set_(1) = true;
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
            obj.mandatory_field_set_(2) = true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.dia(obj)
            val = obj.dia_;
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
    methods
        % SERIALIZABLE INTERFACE
        %------------------------------------------------------------------
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing pdf table if
            % requested.

            flds = obj.saveableFields();
            if ~all(obj.mandatory_field_set_)
                error('HERBERT:IX_det_TobyfitClassic:invalid_argument',...
                    'Must give all mandatory inputs namely: %s\n. Properties: %s have not been set', ...
                    disp2str(flds),...
                    disp2str(flds(~obj.mandatory_field_set_)));

            end
            obj = obj.expand_internal_propeties_to_max_length(flds);
        end
        function flds = saveableFields(~)
            % Return cellarray of properties defining the class
            %
            flds = {'dia','height'};
        end

        function ver = classVersion(~)
            ver = 2;
        end
    end
    methods(Access=protected)
        %------------------------------------------------------------------
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
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available any more
            obj = IX_det_TobyfitClassic();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
    end

end

