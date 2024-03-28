classdef cylinder_proj<aProjectionBase
    % Class defines cylindical coordinate projection, used by cut_sqw
    % to make cylindical cuts.
    %
    % Default angular coordinates names and meanings are chosen as follows:
    % Q_tr    -- coordinate 1  is the module of the component of the momentum 
    %            transfer orthogonal to the direction, selected by property
    %            e_z  of this class. e_z property is expressed in hkl and
    %            defines direction of e_z axis of cylindrical coordinate 
    %            system. Horace has default beam direction along axis 
    %            [1,0,0] so default crystalographic direction of e_z axis is 
    %            [1,0,0] because the secondary symmetry of the instrument
    %            image would be cylindrical symmetry around beam direction
    % phi     -- coordinate 2 is the angle between x-axis of the cylindrical 
    %            coordinate system and the projection of the momentum transfer
    %            (Q_tr) to the xy plain of the cylindircal coordinate
    %            system
    % Q_||    -- coordinate 3 is the component of the momentum Q, (Q_||)
    %            directed along the selected e_z axis. 
    % dE      -- coordinate 4 the energy transfer direction
    %
    %
    properties(Dependent)
        ez;  % [1x3] unit vector specifying crystallographic direction of
        % cylindical coordinates Z-axis within the reciprocal lattice.
        % Z-axis of cylindrical coordinate system is the axis where the
        % elevation (MATLAB convention) is counted from.
        % Default direction is [1,0,0]

        ex; %[1x3] lattice vector together with z-axis defining the crystal
        % rotation plane. Matlab names this angle theta and it is phi
        % angle in Horace/Mantid convention
        %
        type;  % units of the projection. Default ada -- inverse Angstrom, 
        %      degree, inverse Angstrom.
        %      % possible options: ara where letter r describes radian
        %      ie phi angle is calculated in radians
        %
    end
    properties(Access=private)
        %
        ez_ = [1,0,0]
        ex_ = [0,1,0]
        %
        type_ = 'ada' % A^{-1}, degree, A^{-1}
        %------------------------------------
        hor2matlab_transf_ = [...
            0, 1, 0, 0;... % The transformation from
            0, 0, 1, 0;... % Horace pixel coordinate system to the axes coordinates
            1, 0, 0, 0;... % to allow using MATLAB pol2cart/cart2pol functions.
            0, 0, 0, 1];

        pix_to_matlab_transf_ ; % the transformation used for conversion
        % from pix coordinate system to spherical coordinate system
        % if unit vectors are the default, it equal to hor2matlab_transf_.
        % If not, multiplied by rotation from default to the selected
        % coordinate system.
    end
    properties(Constant,Access = private)
        % cellarray describing what letters are available to assign for
        % type properties.
        % 'a' -- Angstrom, 'd' - degree, 'r' -- radians, e-energy transfer in meV;
        types_available_ = {'a',{'d','r'},{'d','r'}};
    end

    methods
        function obj=cylinder_proj(varargin)
            % Constrtuctor for spherical projection
            % See init for the list of input parameters
            %
            obj = obj@aProjectionBase();
            obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_;
            obj.label = {'Q_{tr}','\phi','\Q_{||}','En'};

            obj = obj.init(varargin{:});
        end
        function obj = init(obj,varargin)
            % initialization routine taking any parameters non-default
            % constructor would take and initiating internal state of the
            % projection class.
            %
            % Optional list of positional parameters
            % ez  -- hkl direction of z-axis of the spherical coordinate
            %        system this projection defines. The axis to calculate
            %        theta angle from, notmally beam direction.
            % ex  -- hkl direction of x-axis of the spherical coordinate
            %        system. The axis to calculate Phi angle from. By
            %        default, [ez,ex] defines Horace rotation plane.
            % type-- 3-letter symbol, defining the spherical coordinate
            %        system units (see type property)
            % alatt-- 3-vector of lattice parameters
            % angdeg- 3-vector of lattice angles
            % offset- 4-vector, defining hkldE value of sentre of
            %          coordinate of the spherical coordinate system.
            % label - 4-element celarray, which defines axes lables
            % title - character string to title the plots of cuts, obtained
            %         using this projection.
            %
            if nargin == 1
                obj = obj.check_combo_arg();
                return
            end
            nargi = numel(varargin);
            if nargi== 1 && (isstruct(varargin{1})||isa(varargin{1},'aProjectionBase'))
                if isstruct(varargin{1})
                    obj = serializable.loadobj(varargin{1});
                else
                    obj.do_check_combo_arg = false;
                    obj = obj.from_bare_struct(varargin{1});
                    obj.do_check_combo_arg = true;
                    obj = obj.check_combo_arg();
                end
            else
                opt =  [cylinder_proj.fields_to_save_(:);aProjectionBase.init_params(:)];
                [obj,remains] = ...
                    set_positional_and_key_val_arguments(obj,...
                    opt,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:sphere_proj:invalid_argument',...
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
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        %------------------------------------------------------------------
        function axes_bl = copy_proj_defined_properties_to_axes(obj,axes_bl)
            % copy the properties, which are normally defined on projection
            % into the axes block provided as input
            axes_bl = copy_proj_defined_properties_to_axes@aProjectionBase(obj,axes_bl);
            axes_bl.axes_units  = obj.type;
            %
            axes_bl.img_scales  = obj.img_scales;
        end



        function pix_transformed = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in crystal Cartesian coordinate systems
            % into spherical coordinate system defined by the object
            % properties
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system
            %             or instance of PixelDatBase class containing this
            %             information.
            % Returns:
            % pix_out -- [3xNpix or [4xNpix]Array the pixels coordinates
            %            transformed into spherical coordinate system
            %            defined by object properties
            %
            pix_transformed = transform_pix_to_cylinder_(obj,pix_data);
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (spherical) coordinate system
            % into crystal Cartesian system of pixels
            pix_cc = transform_spher_to_pix_(obj,pix_transformed,varargin{:});
        end

    end

    methods(Access = protected)
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
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(obj)
            flds = saveableFields@aProjectionBase(obj);
            flds = [flds(:);obj.fields_to_save_(:)];
        end
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class. Useful for recovering class from a structure
            obj = cylinder_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
end
