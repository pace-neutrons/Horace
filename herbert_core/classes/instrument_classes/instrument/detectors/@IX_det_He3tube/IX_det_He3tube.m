classdef IX_det_He3tube < IX_det_abstractType
    % IX_det_He3tube Defines array of cylindrical 3He detectors
    % Defines cylindrical 3He gas tube properties on which efficiency,
    % depth of absorption etc depend, namely diameter, wall thickness
    % partial pressure of 3He.
    %
    % The class does not define the position or orientation, which is done
    % elsewhere.


    % Original author: T.G.Perring
    %
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        dia_    = 0;    % Outer diameter of tube (m) (column vector)
        height_ = 0     % Height (m) (column vector)
        wall_   = 0;    % Wall thickness (m) (column vector)
        atms_   = 0;    % 3He partial pressure (atmospheres) (column vector)
        mandatory_field_set_ = false(1,4);
    end

    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m) (column vector)
        height      % height (m) (column vector)
        wall        % Wall thickness (m) (column vector)
        atms        % 3He partial pressure (atmospheres) (column vector)

        % Other dependent properties:
        inner_rad   % Inner radius of tube(m)
        
        % Other dependent properties required by abstract template
        ndet        % Number of detectors
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_det_He3tube(varargin)
            % Constructor for cylindrical 3He detector
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

            if nargin>0
                % Define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                pos_params = obj.saveableFields();
                
                % Set positional parameters and key-value pairs and check their
                % consistency using public setters interface. Run
                % check_combo_arg after all settings have been done.
                [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                    pos_params, true, varargin{:});
                if ~isempty(remains)
                    error('HERBERT:IX_det_He3tube:invalid_argument', ...
                        ['Unrecognised extra parameters provided as input to ',...
                        'IX_det_He3tube constructor: %s'], disp2str(remains));
                end
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
            obj.mandatory_field_set_(1) = true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function obj=set.height(obj,val)
            if any(val(:)<0)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Detector element height(s) must be greater or equal to zero')
            end
            obj.height_ = val(:);
            obj.mandatory_field_set_(2) = true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        %
        function obj=set.wall(obj,val)
            if any(val(:)<0)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Wall thickness(es) must be greater or equal to zero')
            end
            obj.wall_=val(:);
            obj.mandatory_field_set_(3) = true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function obj=set.atms(obj,val)
            if any(val(:)<0)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Partial pressure(s) of 3He must be greater or equal to zero')
            end
            obj.atms_ = val(:);
            obj.mandatory_field_set_(4) = true;
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
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing pdf table if
            % requested.

            flds = obj.saveableFields();
            if ~all(obj.mandatory_field_set_)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    ['Must give all mandatory inputs namely: %s\n',...
                    'Properties: %s have not been set'], ...
                    disp2str(flds),...
                    disp2str(flds(~obj.mandatory_field_set_)));

            end
            obj = obj.expand_internal_propeties_to_max_length(flds);
            % Check the consistency of tube diameter and
            % wall thickness
            if  ~all(obj.dia_>=2*obj.wall_)
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    ['Tube diameter(s) must be greater or equal to twice ',...
                    'the wall thickness(es)'])
            end
        end
        function flds = saveableFields(~)
            % Return cellarray of properties defining the class
            %
            flds = {'dia','height','wall','atms'};
        end

        function ver = classVersion(~)
            ver = 2;
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

    %----------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available any more
            obj = IX_det_He3tube();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
end
