classdef SymopRotation < Symop

    properties(Dependent)
        normvec;     % the vector describing the rotation axis direction (in rlu)
        theta_deg;  % Angle of rotation
    end

    properties(Access=private)
        normvec_;
        theta_deg_;
    end
    properties(Dependent,Hidden)
        % provide compatibility with old SymopRotation interface where
        % norm-vector is described by n
        n
    end

    methods
        function obj = SymopRotation(n, theta_deg, offset,varargin)
            if nargin == 0
                return
            end

            if ~exist('offset', 'var')
                offset = zeros(3,1);
            end

            if ~SymopRotation.check_args({n, theta_deg, offset})
                error('HORACE:symop:invalid_argument', ...
                    ['Constructor arguments should be:\n', ...
                    '- Rotation:   symop(3vector, scalar, [3vector])\n', ...
                    'Received: %s'], disp2str({n, theta_deg, offset}));
            end

            obj.normvec = n;
            obj.theta_deg = theta_deg;
            obj.offset = offset;    % make col vector
            if nargin>3
                obj.b_matrix = varargin{1};
            end

        end

        function obj = set.normvec(obj, val)
            obj = obj.set_normvector(val);
        end
        function obj= set.n(obj,val)
            obj = obj.set_normvector(val);
        end

        function n = get.normvec(obj)
            n = obj.normvec_;
        end
        function n = get.n(obj)
            n = obj.normvec_;
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

            nr = obj.b_matrix_*obj.normvec;  % provided in rlu, so to be converted in CC
            nr = nr/ norm(nr);
            if sum(abs(nr - [1; 0; 0])) > 1e-1  % these vectors considered
                % to be in Crystal Cartesian
                u = [1; 0; 0] + u_offset ;
            else
                u = [0; 1; 0] + u_offset;
            end
            v = obj.transform_vec(u);

            normvec_u = cross(nr, u);
            normvec_v = cross(v, nr);

            if tolerance <= 0
                selected = ((coords-u_offset(:))'*normvec_u >= 0 & ...
                    (coords-u_offset(:))'*normvec_v > 0);
            else
                selected = ((coords-u_offset(:))'*normvec_u + tolerance >= 0 & ...
                    (coords-u_offset(:))'*normvec_v + tolerance > 0);
            end
        end

        function R = calculate_transform(obj, BMatrix)
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
            nr = BMatrix * obj.normvec_;
            % Perform active rotation (hence reversal of sign of theta
            R = rotvec_to_rotmat(-obj.theta_deg_*nr/norm(nr));
        end

        function local_disp(obj)
            fprintf('Rotation operator:\n');
            fprintf('       axis (rlu): %s\n', mat2str(obj.normvec, 2));
            fprintf('      angle (deg): %5.2f\n', obj.theta_deg);
            fprintf('     offset (rlu): %s\n', mat2str(obj.offset, 2));
        end
    end
    methods(Access = protected)
        function obj = set_normvector(obj,val)
            if  ~obj.is_3vector(val) || all(val==0)
                error('HORACE:symop:invalid_argument', ...
                    'Rotation vector n must be a three vector with at last one non-zero element');
            end
            obj.normvec_ = val(:);    % make col vector
        end
    end

    methods(Static)
        function is = check_args(argin)
            is = (numel(argin) == 2 || ...
                numel(argin) == 3 && Symop.is_3vector(argin{3})) && ...
                Symop.is_3vector(argin{1}) && ...
                isscalar(argin{2});
        end

        function sym = fold(nfold, axis, offset)
            % Generate cell array of symmetry required for a n-Fold rotational symmetry reduction
            validateattributes(nfold, {'numeric'}, {'integer'})

            if ~exist('offset', 'var')
                offset = [0; 0; 0];
            end

            sym = cell(nfold, 1);

            ang = 360 / nfold;

            sym{1} = SymopIdentity();
            for i = 2:nfold
                sym{i} = SymopRotation(axis, ang*(i-1), offset);
            end

        end
    end

    % Serializable interface
    methods
        function obj = check_combo_arg(obj)
            obj = obj.check_offset_b_matrix_consistency();
        end
        
        function flds = local_saveableFields(~)
            flds = {'normvec', 'theta_deg', 'offset','b_matrix'};
        end
    end

end
