classdef crystal_alignment_info < serializable
    %CRYSTAL_ALIGNMENT_INFO is a helper class, containing the information
    % about the crystal alignment, returned by refine_crystal routine
    %
    % Created to support common interface between legacy alignment,
    % applicable for orthonormal or triclinic coordinate systems only and
    % generic alignemnt, applicable for any projections
    %
    % The properties class should contain:
    %
    %   rlu_corr       Conversion matrix to relate notional rlu to true rlu, accounting for the the
    %                  refined crystal lattice parameters and orientation
    %                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
    %
    %   alatt           Refined lattice parameters [a,b,c] (Angstroms)
    %
    %   angdeg          Refined lattice angles [alf,bet,gam] (degrees)
    %
    %   rotmat         Inverse U matrix contatining U part of the transformation
    %                  from misaligned coordinate system to aligned hkl
    %                  coordinate system.
    %
    %   distance       Distances between peak positions and points given by true indexes, in input
    %                  argument rlu, in the refined crystal lattice. (Ang^-1)
    %
    %   rotangle       Angle of rotation corresponding to rotmat (to give a measure
    %                  of the misorientation) (degrees)
    %
    properties(Dependent)
        alatt  % Refined lattice parameters [a,b,c] (Angstroms)
        angdeg % Refined lattice angles [alf,bet,gam] (degrees)
        rotmat % Rotation matrix that relates crystal Cartesian coordinate
        %        frame of the refined lattice and orientation as a rotation
        %        of the initial crystal frame. Coordinates
        %        are related by:   v(i)= rotmat(i,j)*v0(j)

        distance % Distances between peak positions and points given by
        %          true indexes, in input argument rlu, in the refined
        %          crystal lattice. (Ang^-1)
        rotvec   % Three rotation angles, which define the rotation matrtix
        %          (radian)
        rotangle %  Angle of rotation corresponding to rotmat (to give a
        %           measure of the misorientation) (degrees)

    end
    properties(Hidden)
        % align crystal in legacy mode, changing u_to_rlu matrix rather
        % then rotating pixels and adjusting lattice separately.
        legacy_mode = false;
    end
    properties(Access = protected)
        alatt_ = ones(1,3)/pi % Refined lattice parameters [a,b,c] (Angstroms)
        angdeg_ =ones(1,3)*90; % Refined lattice angles [alf,bet,gam] (degrees)
        rotmat_ = eye(3) % Rotation matrix that relates crystal Cartesian coordinate
        lattice0_ = [ones(1,3)/pi,ones(1,3)*90];
        %        frame of the refined lattice and orientation as a rotation
        %        of the initial crystal frame. Coordinates
        %        are related by:   v(i)= rotmat(i,j)*v0(j)

        distance_ = [];% Distances between peak positions and points given by true indexes, in input
        %          argument rlu, in the refined crystal lattice. (Ang^-1)
        rotvec_ =  zeros(3,1)% Angle of rotation corresponding to rotmat
        %          (to give a measure of the misorientation) (radia)
    end


    methods
        function obj = crystal_alignment_info(varargin)
            %CRYSTAL_ALIGNMENT_INFO Construct an instance of
            % crystal_alignent_info class using default serializable
            % constructor, assigning values to all properties in order of
            % saveableFields or as 'field_name',field_value pairs.
            if nargin == 0
                return;
            end

            flds = obj.saveableFields();
            [obj,remains] = set_positional_and_key_val_arguments(obj,...
                flds,false,varargin{:});
            if ~isempty(remains)
                error('HORACE:crystal_alignment_info:invalid_argument', ...
                    'Input parameters: %s have not been recognized', ...
                    disp2str(remains));
            end
        end
        %------------------------------------------------------------------
        function lat = get.alatt(obj)
            lat = obj.alatt_;
        end
        function ang = get.angdeg(obj)
            ang = obj.angdeg_;
        end
        function rotmat = get.rotmat(obj)
            rotmat=rotvec_to_rotmat2(obj.rotvec_);
        end
        function dist = get.distance(obj)
            dist = obj.distance_;
        end
        function vec = get.rotvec(obj)
            vec = obj.rotvec_;
        end
        function ang = get.rotangle(obj)
            ang =norm(obj.rotvec)*(180/pi);
        end
        %------------------------------------------------------------------
        function obj = set.alatt(obj,val)
            if ~isnumeric(val) || numel(val) ~= 3
                if numel(val) == 1
                    val = [val,val,val];
                else
                    error('HORACE:crystal_alignment_info:invalid_argument', ...
                        'alatt must be 3-component vector of lattice parameters. It is: %s',...
                        disp2str(val));
                end
            end
            obj.alatt_= val(:)';
        end
        function obj = set.angdeg(obj,val)
            if ~isnumeric(val) || numel(val) ~= 3
                if numel(val) == 1
                    val = [val,val,val];
                else
                    error('HORACE:crystal_alignment_info:invalid_argument', ...
                        'angdeg must be 3-component vector of lattice angles. It is: %s',...
                        disp2str(val));
                end
            end
            obj.angdeg_= val(:)';
        end
        function obj = set.distance(obj,val)
            if ~isnumeric(val) || numel(val) < 3
                error('HORACE:crystal_alignment_info:invalid_argument', ...
                    'distance must be a vector of at least 3-components. It is: %s',...
                    disp2str(val));
            end
            obj.distance_= val(:)';
        end
        function obj = set.rotvec(obj,val)
            if ~isnumeric(val) || numel(val) ~= 3
                error('HORACE:crystal_alignment_info:invalid_argument', ...
                    'rotvec must be 3-component vector defining the rotation matrix angles. It is: %s',...
                    disp2str(val));

            end
            obj.rotvec_= val;
        end
        %======================================================================
        function corr_mat = get_corr_mat(obj,proj)
            % Return corrections, necessary for modifying sqw object
            % parameters to become aligned
            % Depending on alignment mode, (legacy_mode ) the
            % correction matrix takes form:
            % a)
            %  legacy_mode == true -> corr_mat == rlu_corr
            %
            %   rlu_corr   Conversion matrix to relate notional rlu to true rlu, accounting for the the
            %              refined crystal lattice parameters and orientation
            %                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
            % b)
            %  legacy_mode == false -> corr_mat == the matrix which rotates
            %                                      misaligned q-coordinates
            %                                      to Crystal Cartezian
            %                                      coordinate system
            %
            %  qframe_corr  rotation matrix to
            if ~isa(proj,'ortho_proj')
                error('HORACE:lattice_functions:invalid_argument', ...
                    'Alignment can currently be performed on sqw objects with triclinic projections only')
            end

            b0 = bmatrix(proj.alatt,proj.angdeg);
            if obj.legacy_mode
                b  = bmatrix(obj.alatt,obj.angdeg);
                corr_mat=b\obj.rotmat*b0;
            else
                u_to_rlu = proj.get_pix_img_transformation(3); % uncorrected  U0*B0
                corr_mat = (u_to_rlu*b0)\obj.rotmat; % U0B0/b0*rotmat = rotmatOld\rotmat_new
            end
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 1;
        end

        function flds = saveableFields(~)
            flds = {'alatt','angdeg','rotvec','distance'};
        end
    end
end