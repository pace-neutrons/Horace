classdef spher_proj<aProjectionBase
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts.
    %
    % TODO: #954 NEEDS verification:
    % The angular coordinates names and meanings are chosen according
    % to the conventions of inelastic spectrometry, i.e.:
    % |Q|     -- coordinate 1 is the module of the scattering momentum,
    % theta   -- coordinate 2, the angle between the beam direction (k_i)
    %            and the direction of the Q,
    % phi     -- coordinate 3 is the angle between the projection of the
    %            scattering vector to the instrument plain (perpendicular
    %            to k_i) and the crystal rotation plain.
    % dE      -- coordinate 4 the energy transfer direction
    %
    %
    properties(Dependent)
        ez; %[1x3] Unit vector of Z axis in spherical coordinate system
        % where the elevation angle (MATLAB convention) is counted from.
        % In Horace/Mantid convention this angle is named pi/2-theta.
        % Default direction [0,0,1] is a beam direction for this coordinate system.
        %
        ey; %[1x3] unit vector of axis in spherical coordinate system
        % where the theta angle is counted from. The direction coincides
        % with the crystal rotation axis here.

        %
        type;  % units of the projection. Default add -- inverse Angstrom, degree, degree
        %      % possible options: rrr where first r is responsible for rlu
        %      units and two other -- for radian e.g. 'rdr' or adr are
        %      allowed combinations of letters
        %
    end
    properties(Access=private)
        %
        ez_ = [0,0,1]
        ey_ = [0,1,0]
        %
        type_ = 'add' % A^{-1}, degree, degree
        %------------------------------------
        % For the future. See if we want spherical projection in hkl,
        % non-orthogonal
        %orhtonormal_ = true;
        hor2matlab_transf_ = ...
            [0,0,1;... % The transformation from
            1 ,0,0;... % Horace pixel coordinate system to the axes above to
            0 ,1,0];   % allow to use MATLAB sph2cart/cart2sph functions.  


        pix_to_matlab_transf_ ; % the transformation used for conversion
        % from pix coordinate system to spherical coordinate system
        % if unit vectors are the default, it equal to hor2matlab_transf_.
        % If not, multiplied by rotation from default to the selected
        % coordinate system.
    end
    properties(Constant,Access = private)
        % cellarray describing what letters are available to assign for
        % type properties.
        % 'a' -- Angstrom, 'd' - degree, 'r' -- radians
        types_available_ = {'a',{'d','r'},{'d','r'}};
    end

    methods
        function obj=spher_proj(varargin)
            obj = obj@aProjectionBase();
            obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_;
            obj.label = {'|Q|','\theta','\phi','En'};

            obj = obj.init(varargin{:});
        end
        function obj = init(obj,varargin)
            % initialization routine taking any parameters non-default
            % constructor would take and initiating internal state of the
            % projection class.
            %
            if nargin == 1
                return
            end
            nargi = numel(varargin);
            if nargi== 1 && (isstruct(varargin{1})||isa(varargin{1},'aProjectionBase'))
                if isstruct(varargin{1})
                    obj = serializable.loadobj(varargin{1});
                else
                    obj = obj.from_bare_struct(varargin{1});
                end
            else
                opt =  [ortho_proj.fields_to_save_(:);aProjectionBase.init_params(:)];
                [obj,remains] = ...
                    set_positional_and_key_val_arguments(obj,...
                    opt,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:spher_proj:invalid_argument',...
                        'The parameters: "%s" provided as input to spher_proj constructor initialization have not been recognized',...
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
            if any(val ~= [0,0,1])
                warning('HORACE:spher_proj:not_implemented', ...
                    'changes in beam-axis direction is not yet implemented')
                val = [0,0,1];
            end

            obj.ez_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function u = get.ey(obj)
            u = obj.ey_;
        end
        function obj = set.ey(obj,val)
            val = aProjectionBase.check_and_brush3vector(val);
            if any(val ~= [0,1,0])
                warning('HORACE:spher_proj:not_implemented', ...
                    'changes in rotation-axis direction is not yet implemented')
                val = [0,1,0];
            end
            
            obj.ey_ = val;
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
        function [rot_to_img,offset,theta_to_ang,phi_to_ang]=get_pix_img_transformation(obj,ndim,varargin)
            % Return the constants and parameters used for transformation
            % from Crystal Cartezian to spherical coordinate system and
            % back
            %
            % Inputs:
            % obj  -- initialized instance of the spher_proj class
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
            % theta_to_ang
            %     -- depending on the projection type, the constant used to
            %        convert Theta angles in radians to Theta angles in
            %        degrees or vice versa.
            % phi_to_ang
            %     -- depending on the projection type, the constant used to
            %        convert Phi angles in radians to Phi angles in
            %        degrees or vice versa.

            %
            % TODO: #954 NEEDS verification:
            [rot_to_img,offset,theta_to_ang,phi_to_ang]=get_pix_img_transformation_(obj,ndim,varargin{:});

        end
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        %------------------------------------------------------------------
        function ax_bl = get_proj_axes_block(obj,default_binning_ranges,req_binning_ranges)
            % return the axes block, corresponding to this projection class.
            ax_bl = get_proj_axes_block@aProjectionBase(obj,default_binning_ranges,req_binning_ranges);
            ax_bl.angular_unit_is_rad = obj.type(2:3);
            %
            %ax_bl.ulen  = [1,1,1,1]; ??? Usage not yet clear TODO: #954.
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
            pix_transformed = transform_pix_to_spher_(obj,pix_data);
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (spherical) coordinate system
            % into crystal Cartesian system of pixels
            pix_cc = transform_spher_to_pix_(obj,pix_transformed,varargin{:});
        end

    end

    methods(Access = protected)
        function mat = get_u_to_rlu_mat(obj)
            % TODO: #954 NEEDS verification:
            % u_to_rlu matrix used to tranfer offset expressed in Crystal Cartesian
            % into rlu (normally this matrix contans inverse operation)
            %
            bm = bmatrix(obj.alatt,obj.angdeg);
            mat = inv(bm);
            mat = [mat,zeros(3,1);[0,0,0,1]];
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    methods
        % check interdependent projection arguments
        function obj = check_combo_arg (obj)
            % Check validity of interdependent fields
            %
            %   >> obj = check_combo_arg(w)
            %
            % Throws HORACE:spher_proj:invalid_argument with the message
            % suggesting the reason for failure if the inputs are incorrect
            % w.r.t. each other.
            %
            % Normalizes input vectors to unity and constructs the
            % transformation to new coordinate system when operation is
            % successful
            %
            obj = check_combo_arg_(obj);
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
    properties(Constant, Access=private)
        fields_to_save_ = {'ez','ey','type'}
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class. Useful for recovering class from a structure
            obj = spher_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
    methods(Access=protected)
    end
end
