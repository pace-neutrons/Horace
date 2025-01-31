classdef kf_sphere_proj<sphere_proj
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts.
    %
    % Unlike sphere_proj, which calculates spherical coordinates of scattrgint
    % vector Q, kf_sphere_proj, calculates spherical coordinates of
    % scattering vector kf, where Q = ki-kf;
    %
    % Usage (with positional parameters):
    %
    % >>sp = kf_sphere_proj(); %default construction
    % >>sp = kf_sphere_proj(Ei);
    % >>sp = kf_sphere_proj(Ei,u,v);
    % >>sp = kf_sphere_proj(Ei,u,v,type);
    % >>sp = kf_sphere_proj(Ei,u,v,type,alatt,angdeg);
    % >>sp = kf_sphere_proj(Ei,u,v,type,alatt,angdeg,offset,label,title);
    %
    % Where:
    % Ei -- Incident energy in direct spectrometer. Will work for indirect
    %       too though its meaning a bit unclear.
    % u  -- [1,3] vector of hkl direction of z-axis of the spherical
    %        coordinate system this projection defines. It defines the
    %        direction of ki vector (incident beam)
    %        The axis to calculate theta angle from.
    % v  -- [1,3] vector of hkl direction of x-axis of the spherical
    %       coordinate system, the axis to calculate Phi angle from.
    % NOTE:
    %       the idea of this projection is that u and v should be set to
    %       the values of u,v vectors, used to obtain sqw object i.e. u
    %       should coicide with beam direction and v selected to define the
    %       uv plane, where rotation occurs.
    %
    % type-- 3-letter character array, defining the spherical
    %        coordinate system units (see type property below)
    % alatt-- 3-vector of lattice parameters. Value will be ignored by cut.
    % angdeg- 3-vector of lattice angles. Value will be ignored by cut.
    % offset- 4-vector, defining hkldE value of centre of
    %         coordinates of the spherical coordinate
    %         system.
    % label - 4-element cellarray, which defines axes labels
    % title - character string to title the plots of cuts, obtained
    %         using this projection.
    %
    % all parameters may be provided as 'key',value pairs appearing in
    % arbitrary order after positional parameters
    % e.g.:
    % >>sp = kf_sphere_proj(10,[1,0,0],[0,1,0],'arr','offset',[1,1,0]);
    % >>sp = kf_sphere_proj(10,[1,0,0],'type','arr','v',[0,1,0],'offset',[1,1,0]);
    %
    % Default angular coordinates names and meaning of the coordinate system,
    % defined by sphere_proj are chosen as follows:
    % |kf|    -- coordinate 1 is the modulus of the scattering momentum.
    % theta   -- coordinate 2, the angle between axis u
    %            and the direction of the kf.
    % phi     -- coordinate 3 is the angle between the projection of the
    %            scattering vector to the plane defined by vector v and
    %            perpendicular to u.
    % dE      -- coordinate 4 the energy transfer direction
    %
    % parent's class "type" property describes which scales are avaliable for
    % each direction:
    % for |Q|:
    % 'a' -- Angstrom,
    % 'r' -- scale = max(\vec{u}*\vec{e_h,e_k,e_l}) -- projection of u to
    %                                       unit vectors in hkl directions
    % 'p' -- |u| = 1 -- i.e. scale = |u|
    % 'h','k' or 'l' -- i.e. scale = (a*,b* or c*);
    % for angular units theta, phi:
    % 'd' - degree, 'r' -- radians
    % For energy transfer:
    % 'e'-energy transfer in meV (no other scaling so may be missing)
    %
    properties(Dependent)
        Ei
        % return vector ki in A^-1. Used for debugging and easy cut range
        % estimation
        ki;
    end
    properties(Access=protected)
        Ei_ = [];
        % cache for ki -- incident beam wave vector
        ki_ = [1;0;0];
    end
    methods
        function obj=kf_sphere_proj(varargin)
            % Constrtuctor for spherical projection
            % See init for the list of input parameters
            %
            obj = obj@sphere_proj();
            obj.type_ = 'add';
            obj.label = {'|kf|','\theta','\phi','En'};
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %------------------------------------------------------------------
        function ei = get.Ei(obj)
            ei = obj.Ei_;
        end
        function ki = get.ki(obj)
            ki=(obj.ki_(:))';
        end
        function obj = set.Ei(obj,val)
            if ~isnumeric(val)||~isscalar(val)
                error('HORACE:kf_sphere_proj:invalid_arguments', ...
                    'Incident beam must be poisitive. Got %d',val);
            end
            if val<=0
                error('HORACE:kf_sphere_proj:invalid_arguments', ...
                    'Incident beam energy must be poisitive. Got %d',val);
            end

            obj.Ei_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        %------------------------------------------------------------------
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
            if isa(pix_data,'PixelDataBase')
                pix_cc = pix_data.q_coordinates;
                shift_ei = obj.offset(4) ~=0; % its ginored for the time being

                ndim = 3;
                input_is_obj = true;
            else % if pix_input is 4-d, this will use 4-D matrix and shift
                % if its 3-d -- matrix is 3-dimensional and energy is not shifted
                % anyway
                ndim         = size(pix_data,1);
                pix_cc       = pix_data;
                input_is_obj = false;
            end
            if ndim ==3
                kf = obj.ki_-pix_cc;
            else
                kf = obj.ki_-pix_cc(1:3,:);
            end
            pix_transformed = transform_pix_to_img@sphere_proj(obj,kf,varargin{:});
            if ndim > 3 || input_is_obj
                if input_is_obj
                    pix_transformed = [pix_transformed;pix_data.dE];
                else
                    pix_transformed = [pix_transformed;pix_data(4,:)];
                end
            end
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (spherical) coordinate system
            % into crystal Cartesian system of pixels
            kf = transform_img_to_pix@sphere_proj(obj,pix_transformed,varargin{:});
            pix_cc = obj.ki_-kf;
            if size(pix_transformed,1) > 3
                pix_cc = [pix_cc;kf(4,:)];
            end
        end
    end

    methods(Access = protected)
        function name = get_axes_name(~)
            % return the name of the axes class, which corresponds to this
            % projection
            name = 'sphere_axes';
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    methods(Access=protected)
        function flds = init_order_fields(obj)
            % overloadeded field construction order to put incident energy
            % first while using sphere_proj initialization procedure.
            flds = init_order_fields@CurveProjBase(obj);
            flds = ['Ei';flds(:)];
        end
    end

    methods
        function  flds = saveableFields(obj)
            flds = saveableFields@sphere_proj(obj);
            flds = ['Ei';flds(:)];
        end
        function ver  = classVersion(~)
            ver = 1;
        end
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
            obj = check_combo_arg@sphere_proj(obj);
            if obj.alatt_defined && obj.angdeg_defined
                bm = obj.bmatrix();
            else
                bm = eye(3);
            end
            kf_modulo=sqrt(obj.Ei_/neutron_constants('c_k_to_emev')); % incident
            % neutron beam wavevector in A^-1
            u_in_A = bm*obj.u(:); % direction in Crystal Cartesian
            obj.ki_ = u_in_A/norm(u_in_A)*kf_modulo;
        end

    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class. Useful for recovering class from a structure
            obj = kf_sphere_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
end
