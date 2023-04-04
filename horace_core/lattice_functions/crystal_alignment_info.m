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
    %   rotmat         Rotation matrix that relates crystal Cartesian coordinate frame of the refined
    %                  lattice and orientation as a rotation of the initial crystal frame. Coordinates
    %                  in the two frames are related by
    %                       v(i)= rotmat(i,j)*v0(j)
    %
    %   distance       Distances between peak positions and points given by true indexes, in input
    %                  argument rlu, in the refined crystal lattice. (Ang^-1)
    %
    %   rotangle       Angle of rotation corresponding to rotmat (to give a measure
    %                  of the misorientation) (degrees)
    %
    properties(Dependent)
        rlu_corr %Conversion matrix to relate notional rlu to true rlu,
        %         accounting for the the refined crystal lattice parameters
        %         and orientation:  qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
        alatt  % Refined lattice parameters [a,b,c] (Angstroms)
        angdeg % Refined lattice angles [alf,bet,gam] (degrees)
        rotmat % Rotation matrix that relates crystal Cartesian coordinate
        %        frame of the refined lattice and orientation as a rotation
        %        of the initial crystal frame. Coordinates
        %        are related by:   v(i)= rotmat(i,j)*v0(j)

        distance % Distances between peak positions and points given by true indexes, in input
        %          argument rlu, in the refined crystal lattice. (Ang^-1)

        rotangle % Angle of rotation corresponding to rotmat (to give a measure
        %          of the misorientation) (degrees)

    end
    properties(Hidden)
        compat_mode = false;
    end
    properties(Access = protected)
        rlu_corr_ = eye(3);%Conversion matrix to relate notional rlu to true rlu,
        %         accounting for the the refined crystal lattice parameters
        %         and orientation:  qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
        alatt_ = ones(3,1)/pi % Refined lattice parameters [a,b,c] (Angstroms)
        angdeg_ =ones(3,1)*90; % Refined lattice angles [alf,bet,gam] (degrees)
        rotmat_ = eye(3) % Rotation matrix that relates crystal Cartesian coordinate
        %        frame of the refined lattice and orientation as a rotation
        %        of the initial crystal frame. Coordinates
        %        are related by:   v(i)= rotmat(i,j)*v0(j)

        distance_ = [];% Distances between peak positions and points given by true indexes, in input
        %          argument rlu, in the refined crystal lattice. (Ang^-1)
        rotangle_ =  zeros(3,1)% Angle of rotation corresponding to rotmat
        %          (to give a measure of the misorientation) (degrees)
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
        function corr = get.rlu_corr(obj)
            corr = obj.rlu_corr_;
        end
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
        function ang = get.rotangle(obj)
            ang = obj.rotangle_;
        end
        %------------------------------------------------------------------
        function obj = set.rlu_corr(obj,val)
            if ~isnumeric(val) || any(size(val) ~= [3,3])
                error('HORACE:crystal_alignment_info:invalid_argument', ...
                    'rulu_corr must be 3x3 rotation matrix. It is: %s',...
                    disp2str(val));
            end
            obj.rlu_corr_ = val;
        end
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
        function obj = set.rotangle(obj,val)
            if ~isnumeric(val) || numel(val) ~= 3
                error('HORACE:crystal_alignment_info:invalid_argument', ...
                    'rotangle must be 3-component vector defining the rotation matrix angles. It is: %s',...
                    disp2str(val));

            end
            obj.rotangle_= val;
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
            flds = {'rlu_corr','alatt','angdeg',...
                'distance','rotangle'};
        end
    end
end