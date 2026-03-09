classdef SymopRotation < SymopSetPlaneInterface

    properties(Dependent)
        theta_deg;  % Angle of rotation
    end

    properties(Access=private)
        theta_deg_;
        normvec_u_;
        normvec_v_;
    end
    properties(Dependent,Hidden)
        % provide compatibility with old SymopRotation interface where
        % norm-vector is described by n
        n
        % vectors, orthogonal to edges of irreducible zone
        normvec_u;
        normvec_v;
    end

    methods
        function obj = SymopRotation(varargin)
            % Rotation class constructor:
            % 1)
            %>>op = SymopRotation(u,v,thetadeg,offset)
            %>>op = SymopRotation(__,b_matrix,["cc"|"rlu"]);
            %Inputs:
            % u,v  --  two vectors, which define rotation plane (two vectors
            %          in the plane,which define it)
            % or
            % 2)
            %>>op = SymopRotation(rot_axis,thetadeg,offset)
            %>>op = SymopRotation(__,b_matrix,["cc"|"rlu"]);
            % Inputs:
            % rot_axis -- define rotation axis (normal to rotation
            %             plane)
            % thetadeg -- rotation angle
            % offset   -- the position of the rotation axis
            %
            %NOTE:
            % "cc" or "rlu" options are mandatory for non-orthogonal lattice
            % defined by rotation axis, but ignored if the axis is defined
            % by u,v vectors.
            if nargin == 0
                return
            end
            [argi,input_nrmv_in_rlu] = SymopSetPlaneInterface.check_and_sanitize_coord(varargin{:});
            %
            flds = obj.saveableFields();
            if ischar(argi{1}) % all defined by key-value pairs
                defined_by_normvec = false;
                flds = ['normvec';flds(:)];
            else
                defined_by_normvec = numel(argi)>1 && isscalar(argi{2});
            end

            if defined_by_normvec %
                flds = ['normvec',flds(3:end)];
                obj.input_nrmv_in_rlu_ = input_nrmv_in_rlu;
            end
            [obj,remains] = ...
                set_positional_and_key_val_arguments(obj,...
                flds,false,argi{:});
            if ~isempty(remains)
                error('HORACE:SymopRotation:invalid_argument', ...
                    'Additional arguments %s have not been recognized', ...
                    disp2str(remains));
            end
        end

        function obj= set.n(obj,val)
            obj = obj.set_normvector(val);
        end
        function n = get.n(obj)
            n = obj.normvec_;
        end

        function un = get.normvec_u(obj)
            un = obj.normvec_u_;
        end
        function vn = get.normvec_v(obj)
            vn = obj.normvec_v_;
        end


        function obj = set.theta_deg(obj, val)
            if ~isnumeric(val) || ~isscalar(val)
                error('HORACE:symop:invalid_argument', ...
                    'Rotation theta_deg must be a numeric scalar');
            end
            obj.theta_deg_ = val;
        end

        function theta_deg = get.theta_deg(obj)
            theta_deg = obj.theta_deg_;
        end

        function selected = in_irreducible(obj, coords, tolerance)
            % Compute whether the coordinates in `coords` (Q) are in the irreducible
            % set following the symmetry reduction under this operator
            %
            % For a rotation `R` about axis `n` of angle `theta`:
            %
            % For any `u` not parallel to `normvec` and v = R*u;
            % The planes defined by UN, VN encapsulate the reduced region
            % And thus any coordinate `q` from `Q` where
            % q*(normvec x u) > 0 && q*(v x normvec) > 0
            % belong to the irreducible set in the upper right quadrant.
            % In expression above `x` means cross and `*` -- scalar
            % products.
            %
            u_offset = obj.u_offset_; %proj.transform_hkl_to_pix(obj.offset);
            nrmv_u = obj.normvec_u_;
            nrmv_v = obj.normvec_v_;

            if tolerance <= 0
                selected = ((coords-u_offset(:))'*nrmv_u >= 0 & ...
                    (coords-u_offset(:))'*nrmv_v  > 0);
            else
                selected = ((coords-u_offset(:))'*nrmv_u + tolerance >= 0 & ...
                    (coords-u_offset(:))'*nrmv_v  + tolerance > 0);
            end
        end

        function R = calculate_transform(obj, varargin)
            % Get transformation matrix for the symmetry operator in an orthonormal frame
            %
            % The transformation matrix converts the components of a vector which is
            % related by the symmetry operation into the equivalent vector. The
            % coordinates of the vector are expressed in an orthonormal frame.
            %
            % For example, if the symmetry operation is a rotation by 90 degrees about
            % [0,0,1] in a cubic lattice with lattice parameter 2*pi, the point [0.3,0.1,2]
            % is transformed into [0.1,-0.3,2].
            %
            % The transformation matrix accounts for reflection or rotation, but not
            % translation associated with the offset in the symmetry operator.
            %
            %   >> R = calculate_transform (obj, BMatrix)
            %
            % Input:
            % ------
            %   obj      Symmetry operator object (scalar)
            %   BMatrix  Matrix to convert components of a vector given in rlu to those
            %            in an orthonormal frame
            %
            % Output:
            % -------
            %   R      Transformation matrix to be applied to the components of a
            %          vector given in the orthonormal frame for which Minv is defined
            % Express rotation vector in orthonormal frame
            nr = obj.normvec;
            % Perform active rotation (hence reversal of sign of theta
            R = rotvec_to_rotmat(-obj.theta_deg_*nr);
        end

        function local_disp(obj)
            local_disp_(obj);
        end
    end
    methods(Static)
        function sym = fold(nfold, axis, varargin)
            % Generate cell array of symmetry required for a n-Fold
            % rotational symmetry reduction
            % Inputs:
            % nfold        -- number of rotation symmetry operations
            % axis         -- either 3-component vector defining rotation
            %                 axis or 2x3 matrix, which define 2 vectors,
            %                 defining the rotation plane. See coord_system
            %                 below.
            % offset       -- if provided, 3-vector defining position of
            %                 the rotation axis (rlu)
            % coord_system --
            %                 shoule be 'rlu' or 'cc'. This value is necessary
            %                 when axis is defined by single vector and
            %                 wen crystal lattice is non-orthogonal, as axis
            %                 direction in non-orthogonal system differs
            %                 depending on this setting. Will be ignored
            %                 for orthogonal lattice or when axis is
            %                 defined by two vectors
            %
            [offset,coord_system,normal_defined] = check_fold_arguments_(nfold, axis, varargin{:});

            sym = cell(nfold, 1);
            ang = 360 / nfold;

            sym{1} = SymopIdentity();
            for i = 2:nfold
                if normal_defined
                    sym{i} = SymopRotation(axis, ang*(i-1), offset,coord_system);
                else
                    sym{i} = SymopRotation(axis(1,:),axis(2,:),ang*(i-1), offset);
                end
            end

        end
    end
    % Serializable interface
    methods
        function obj = check_combo_arg(obj,varargin)
            if isempty(obj.theta_deg_)
                error('HORACE:SymopRotation:invalid_argument', ...
                    'Rotation angle have to be set if any other class property is set')
            end
            obj = check_combo_arg@SymopSetPlaneInterface(obj,varargin{:});
            % define edges of irreducible zone.
            nr = obj.normvec;
            if isempty(obj.b_matrix)
                u_cc = obj.u(:);
                use_rlu_offset = true; % allows to construct rotation without
                % setting b-matrix. To obtain correct results, b-matrix
                % have to be set later
            else
                u_cc = obj.b_matrix*obj.u(:);
                use_rlu_offset = false;                
            end
            u_cc = u_cc/norm(u_cc);
            v_cc = obj.transform_vec(u_cc,use_rlu_offset);
            obj.normvec_u_ = cross(nr, u_cc);
            obj.normvec_v_ = cross(v_cc, nr);

        end

    end
    methods(Access = protected)
        function flds = local_saveableFields(~)
            flds = {'u','v','theta_deg', 'offset','b_matrix'};
        end
    end
end
