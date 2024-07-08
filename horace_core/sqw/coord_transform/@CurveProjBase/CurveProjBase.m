classdef CurveProjBase <aProjectionBase
    % Class defines common properties and methods used by curvilinear
    % projections. Currently (01/04/2024) spherical and cylindrical
    % projections to make spherical/cylindrical cuts.
    %
    properties(Dependent)
        u;  % [1x3]lattice vector specifying crystallographic direction of
        % Z-axis  of spherical/cylindrical coordinate system within the
        % reciprocal lattice.
        % Z-axis of curvilinear coordinate system is the axis where the
        % polar angle is is counted from. In MATLAB convention polar angle
        % is  pi/2-elevation angle.
        % In Horace/Mantid convention this angle is named theta = pi/2-elevation.
        % Default direction is [1,0,0]

        v; %[1x3] lattice vector together with z-axis defining the crystal
        % rotation plane. The r_x vector, which lies in this plane and
        % orthogonal to e_z axis defines the axis, where phi angle is
        % calculated from. MATLAB names this angle azimuth and it is phi
        % angle in Horace/Mantid convention.
        %
        % If z-axis of spherical coordinate system is directed along the beam
        % u,v vectors of spherical projection coincide with u,v vectors
        % used during sqw file generation
        %
    end
    properties(Dependent,Hidden)
        % old interface to spherical/cylindrical projections
        ez; % equivalent to u
        ex; % equivalent to v
    end

    properties(Access=protected)
        %
        u_ = [1,0,0]
        v_ = [0,1,0]
        %------------------------------------
        hor2matlab_transf_ = [...
            0, 1, 0, 0;... % The transformation from
            0, 0, 1, 0;... % Horace pixel coordinate system to the axes coordinates
            1, 0, 0, 0;... % to allow using MATLAB sph2cart/cart2sph or pol2cart/cart2pol
            0, 0, 0, 1];   % functions.

        pix_to_matlab_transf_ ; % the transformation used for conversion
        % from pix coordinate system to spherical coordinate system
        % if direction vectors u,v have default values, it equal to hor2matlab_transf_.
        % If not, multiplied by rotation from default to the selected
        % coordinate system.
        %
        img_scales_cache_    % variable contains image scales calculated from type_
        curve_proj_types_    % types, available to use for specific projection
    end
    methods
        function obj = init(obj,varargin)
            % initialization routine taking any parameters non-default
            % constructor would take and initiating internal state of the
            % projection class.
            %
            % Optional list of positional parameters
            % u  -- hkl direction of z-axis of the spherical/cylindrical
            %        coordinate system this projection defines.
            %        The axis to calculate theta angle from or just z-axis
            %        of cylindrical projection.
            % v  -- hkl direction of x-axis of the spherical/cylindrical
            %        coordinate system. The axis to calculate Phi angle from.
            %        If u directed along the beam, [u,v] defines Horace
            %        rotation plane.
            % type-- 3-letter symbol, defining the spherical/cylindrical
            %        coordinate system units (see type property)
            % alatt-- 3-vector of lattice parameters
            % angdeg- 3-vector of lattice angles
            % offset- 4-vector, defining hkldE value of centre of
            %         coordinates of the spherical/cylindrical coordinate
            %         system.
            % label - 4-element cellarray, which defines axes labels
            % title - character string to title the plots of cuts, obtained
            %         using this projection.

            if nargin == 1
                obj = obj.check_combo_arg();
                return
            end
            nargi = numel(varargin);
            if nargi== 1 && (isstruct(varargin{1})||isa(varargin{1},'CurveProjBase'))
                if isstruct(varargin{1})
                    obj = serializable.loadobj(varargin{1});
                else
                    obj.do_check_combo_arg = false;
                    obj = obj.from_bare_struct(varargin{1});
                    obj.do_check_combo_arg = true;
                    obj = obj.check_combo_arg();
                end
            else
                opt =  [sphere_proj.fields_to_save_(:);aProjectionBase.init_params(:)];
                [obj,remains] = ...
                    set_positional_and_key_val_arguments(obj,...
                    opt,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:CurveProjBase:invalid_argument',...
                        'The parameters: "%s" provided as input to sphere_proj constructor initialization have not been recognized',...
                        disp2str(remains));
                end
            end
        end
        %
        function u = get.u(obj)
            u=obj.u_;
        end
        function obj = set.u(obj,val)
            obj = set_u(obj,val);
        end
        %
        function v = get.v(obj)
            v = obj.v_;
        end
        function obj = set.v(obj,val)
            obj = set_v(obj,val);
        end
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        %------------------------------------------------------------------
        function [rot_to_img,offset,img_scales,offset_present,obj]=...
                get_pix_img_transformation(obj,ndim,varargin)
            % Return the constants and parameters used for transformation
            % from Crystal Cartezian to spherical coordinate system and
            % back
            %
            % Inputs:
            % obj  -- initialized instance of the sphere_proj class
            % ndim -- number 3 or 4 -- depending on what kind of
            %         transformation (3D -- momentum only or
            %         4D -- momentum and energy) are requested
            % Output:
            % rot_to_img
            %      -- 3x3 or 4x4 rotation matrix, which orients spherical
            %         coordinate system and transforms momentum and energy
            %         in Crystal Cartesian coordinates into oriented
            %         spherical coordinate system where angular coordinates
            %         are calculated
            % offset
            %     -- the centre of spherical coordinate system in Crystal
            %        Cartesian coordinates.
            % img_scales
            %     -- depending on the projection type, the 3-vectors
            %        containing the scales used on image.
            %        currently only one scale (element 2) is used --
            %        Depending on type letter 2 (r or dconvert Phi angles in radians to Phi angles in
            %        degrees or vice versa.
            % offset_present
            %     -- boolean true if any offset is not equal to 0 and false
            %        if all offsets are zero
            %
            [rot_to_img,offset,img_scales,offset_present,obj] = ...
                get_pix_img_transformation_(obj,ndim,varargin{:});
        end
        %
    end

    methods(Access = protected)
        function    obj = check_and_set_type(obj,val)
            % set curvilinear projection type, changing the units of the
            % angular dimensions if necessary
            obj = check_and_set_type_(obj,val);
        end
        function obj = set_u(obj,val)
            % main setter for u-property
            val = aProjectionBase.check_and_brush3vector(val);
            obj.u_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj = set_v(obj,val)
            % main setter for v-property
            val = aProjectionBase.check_and_brush3vector(val);
            obj.v_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj = set_img_scales(obj,varargin)
            error('HORACE:CurveProjBase:invalid_argument', ...
                'You can not set image scales directly. Use projection type instead')
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    properties(Constant, Access=private)
        fields_to_save_ = {'u','v','type'}
    end
    methods(Access=protected)
        function [S,obj] = convert_old_struct (obj, S, ver)
            % modify old versions of the curvilinear projection
            if ver == 1
                S.u = S.ez;
                S.v = S.ex;
            end
        end
    end
    methods
        % Old ez,ex interface:
        function u = get.ez(obj)
            u=obj.u_;
        end
        function obj = set.ez(obj,val)
            obj = set_u(obj,val);
        end
        function v = get.ex(obj)
            v = obj.v_;
        end
        function obj = set.ex(obj,val)
            obj = set_v(obj,val);
        end
        %------------------------------------------------------------------
        % check interdependent projection arguments
        function obj = check_combo_arg (obj)
            % Check validity of interdependent fields
            %
            %   >> obj = check_combo_arg(w)
            %
            % Throws HORACE:CurveProjBase:invalid_argument with the message
            % suggesting the reason for failure if the inputs are incorrect
            % w.r.t. each other.
            %
            % Normalizes input vectors to unity and constructs the
            % transformation to new coordinate system when operation is
            % successful
            %
            obj = check_combo_arg_(obj);
            obj = check_combo_arg@aProjectionBase(obj);
        end
        %------------------------------------------------------------------
        function  flds = saveableFields(obj)
            flds = saveableFields@aProjectionBase(obj);
            flds = [flds(:);obj.fields_to_save_(:)];
        end
    end
end
