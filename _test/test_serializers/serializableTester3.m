classdef serializableTester3 < serializable
    % Class used to test serializable
    % Based on IX_det_He3tube, but only a single detector here.
    % Designed to exercise old version recovery and convert_old_struct

    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        dia_    = 0.1;   % Outer diameter of tube (m)
        height_ = 0.3     % Height (m) (column vector)
        wall_   = 0.01;    % Wall thickness (m)
        atms_   = 1;       % 3He partial pressure (atmospheres)
    end

    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m)
        height      % height (m) (column vector)
        wall        % Wall thickness (m)
        atms        % 3He partial pressure (atmospheres)

        % Other dependent properties:
        inner_rad   % Inner radius of tube(m)
        ndet        % Number of detectors
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=serializableTester3(varargin)
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
                % Turn off interdependency checking
                obj.do_check_combo_arg_ = false;

                obj.dia = varargin{1};
                obj.height = varargin{2};
                obj.wall = varargin{3};
                obj.atms = varargin{4};

                % Turn on interdependency checking
                obj = obj.check_combo_arg();
                obj.do_check_combo_arg_ = false;
            else
                % Set up default values for properties
                ver = serializableTester3.version_holder();
                if ver==2
                    dia    = 0.25;
                    height = 0.025;
                    wall   = 0.0025;
                    atms   = 2.5;
                elseif ver==1
                    dia    = 0.15;
                    height = 0.015;
                    wall   = 0.0015;
                    atms   = 1.5;
                elseif isnan(ver)
                    dia    = 0.05;
                    height = 0.005;
                    wall   = 0.0005;
                    atms   = 0.5;
                else
                    error('Unrecognised version number for tests')
                end
                obj.dia = dia;
                obj.height = height;
                obj.wall = wall;
                obj.atms = atms;
            end
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.dia(obj,val)
            if val<0
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Tube diameter(s) must be greater or equal to zero')
            end
            obj.dia_=val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj=set.height(obj,val)
            if val<0
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Detector element height(s) must be greater or equal to zero')
            end
            obj.height_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        
        function obj=set.wall(obj,val)
            if val<0
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Wall thickness(es) must be greater or equal to zero')
            end
            obj.wall_=val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj=set.atms(obj,val)
            if val<0
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Partial pressure(s) of 3He must be greater or equal to zero')
            end
            obj.atms_ = val;
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
        function ver = classVersion(~)
            % Return the class version number.
            % The version can be set by a static method - non-standard use
            ver = serializableTester3.version_holder();
        end

        function flds = saveableFields(obj)
            % Return cellarray of public properties defining the class
            % Fields variable depending on version to use this class as an old
            % version tester - non-standard use
            ver = obj.classVersion();
            if ver==2
                flds = {'dia','height','wall','atms'};
            elseif ver==1
                flds = {'dia','height','atms'};
            elseif isnan(ver)
                flds = {'dia','height'};
            end
        end

        function obj = check_combo_arg(obj)
            % Check validity of interdependent properties, updating them where necessary
            if  obj.dia_<2*obj.wall_
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Tube diameter(s) must be greater or equal to twice the wall thickness(es)')
            end
        end

        function S_updated = convert_old_struct(~, S, ver)
            % Restore object from an old structure
            S_updated = S;
            if ver==1
                S_updated.wall = 1e-6;  % not the same as ver 1 constructor value
            elseif isnan(ver)
                S_updated.wall = 1e-7;  % not the same as ver NaN constructor value
                S_updated.atms = 27;    % not the same as ver NaN constructor value
            else
                error('HERBERT:IX_det_He3tube:invalid_argument',...
                    'Unrecognised class version')
            end
        end
    end

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj (S)
            % Boilerplate loadobj method, calling the generic loadobj method of
            % the serializable class
            obj = serializableTester3 ();
            obj = loadobj@serializable (S,obj);
        end
    end

    %======================================================================
    % Controlling version number
    %======================================================================
    methods(Static)
        function ver = version_holder (ver_in)
            % This method allows the class version to be changed for the
            % purpose of testing the serialization of different versions
            %
            % Fetch current set version:
            %   ver = serializableTester3.version_holder()
            %
            % Set version:
            %   serializableTester3.version_holder(val);

            persistent version_store
            
            % Version 2: 
            %   'dia','height','wall','atms'
            %
            % Version 1:
            %   'dia','height','atms'
            %
            % Unserialized: (set ver==NaN)
            %   'dia', 'height'
            
            latest_version = 2;

            if isempty(version_store)
                version_store = latest_version;  % set to current version number
            end
            if nargin>0
                version_store = ver_in;
            end
            ver = version_store;
        end
    end
    
    %======================================================================
end
