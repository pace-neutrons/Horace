classdef CurveProjBase <aProjectionBase
    % Class defines common properties and method used by cuvelinear
    % projections. Currently (01/04/2024) spherical and cylindrical
    % to make spherical/cylindrical cuts.
    %
    properties(Dependent)
        ez;  % [1x3] unit vector specifying crystallographic direction of
        % spherical coordinates Z-axis within the reciprocal lattice.
        % Z-axis of spherical coordinate system is the axis where the
        % polar angle is is counted from. In MATLAB convention polar anlge
        % is  pi/2-elevation angle.
        % In Horace/Mantid convention this angle is named theta = pi/2-elevation.
        % Default direction is [1,0,0]

        ex; %[1x3] lattice vector together with z-axis defining the crystal
        % rotation plane. The r_x vector, which lies in this plane and
        % orthogonal to e_z axis defines the axis, where phi angle is
        % calculated from. Matlab names this angle azimuth and it is phi
        % angle in Horace/Mantid convention.
        %
        % If z-axis of spherical coordinate system is directed along the beam
        % ez,ex vectors of spherical projection coincide with u,v vectors
        % used during sqw file generation
        %
        type;  % units of the projection. Default is add -- 
        %      inverse Angstrom, degree, degree.
        %  possible options: arr where two letters r describe radian
        %  e.g. adr is  allowed combinations of letters, indicating
        %  that the phi angle is calculated in radian and theta -- in
        %  degrees.
        %
    end
    properties(Dependent,Hidden)
        % old interface to spherical/cylindrical projections
    end
    properties(Access=protected)
        %
        ez_ = [1,0,0]
        ex_ = [0,1,0]
        %
        type_ = 'add' % A^{-1}, degree, degree
        %------------------------------------
        hor2matlab_transf_ = [...
            0, 1, 0, 0;... % The transformation from
            0, 0, 1, 0;... % Horace pixel coordinate system to the axes coordinates
            1, 0, 0, 0;... % to allow using MATLAB sph2cart/cart2sph functions.
            0, 0, 0, 1];

        pix_to_matlab_transf_ ; % the transformation used for conversion
        % from pix coordinate system to spherical coordinate system
        % if unit vectors are the default, it equal to hor2matlab_transf_.
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
            % ez  -- hkl direction of z-axis of the spherical/cylindrical
            %        coordinate system this projection defines. 
            %        The axis to calculate theta angle from or just z-axis 
            %        of cylindrical projefction.
            % ex  -- hkl direction of x-axis of the spherical/cylindrical
            %        coordinate system. The axis to calculate Phi angle from. 
            %        If ez directed along the beam, [ez,ex] defines Horace
            %        rotation plane.
            % type-- 3-letter symbol, defining the spherical/cylindrical
            %        coordinate system units (see type property)
            % alatt-- 3-vector of lattice parameters
            % angdeg- 3-vector of lattice angles
            % offset- 4-vector, defining hkldE value of centre of
            %         coordinates of the spherical/cylindrical coordinate
            %         system.
            % label - 4-element celarray, which defines axes lables
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
        function v = get.ez(obj)
            v=obj.ez_;
        end
        function obj = set.ez(obj,val)
            val = aProjectionBase.check_and_brush3vector(val);
            obj.ez_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function u = get.ex(obj)
            u = obj.ex_;
        end
        function obj = set.ex(obj,val)
            val = aProjectionBase.check_and_brush3vector(val);

            obj.ex_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function type = get.type(obj)
            type = obj.type_;
        end
        function obj = set.type(obj,val)
            obj = check_and_set_type_(obj,val);
        end
        %
        function ax_bl = get_proj_axes_block(obj,def_bin_ranges,req_bin_ranges)
            % Construct the axes block, corresponding to this projection class
            % Returns generic AxesBlockBase, built from the block ranges or the
            % binning ranges.
            %
            % Usually overloaded for specific projection and specific axes
            % block to return the particular AxesBlockBase specific for the
            % projection class.
            %
            % Inputs:
            % def_bin_ranges --
            %           cellarray of the binning ranges used as defaults
            %           if requested binning ranges are undefined or
            %           infinite. Usually it is the range of the existing
            %           axes block, transformed into the system
            %           coordinates, defined by cut projection using
            %           dnd.targ_range(targ_proj) method.
            % req_bin_ranges --
            %           cellarray of cut bin ranges, requested by user.
            %
            % Returns:
            % ax_bl -- initialized, i.e. containing defined ranges and
            %          numbers of  bins in each direction, AxesBlockBase
            %          corresponding to the projection
            ax_name = obj.axes_name;
            ax_class = feval(ax_name);
            ax_class.axes_units = obj.type;
            ax_bl = AxesBlockBase.build_from_input_binning(...
                ax_class,def_bin_ranges,req_bin_ranges);
            ax_bl = obj.copy_proj_defined_properties_to_axes(ax_bl);
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
        function axes_bl = copy_proj_defined_properties_to_axes(obj,axes_bl)
            % copy the properties, which are normally defined on projection
            % into the axes block provided as input
            axes_bl = copy_proj_defined_properties_to_axes@aProjectionBase(obj,axes_bl);
            axes_bl.axes_units = obj.type;
        end
    end
    methods(Access = protected)
        function obj = set_img_scales(obj,varargin)
            error('HORACE:CurveProjBase:invalid_argument', ...
                'You can not set image scales directly. Use projection type instead')
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    properties(Constant, Access=private)
        fields_to_save_ = {'ez','ex','type'}
    end
    methods
        % check interdependent projection arguments
        function obj = check_combo_arg (obj)
            % Check validity of interdependent fields
            %
            %   >> obj = check_combo_arg(w)
            %
            % Throws HORACE:sphere_proj:invalid_argument with the message
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
