classdef SymopRotation < Symop

    properties(Dependent)
        n;
        theta_deg;
    end

    properties(Access=private)
        n_;
        theta_deg_;
    end

    methods
        function obj = SymopRotation(n, theta_deg, offset)
            if nargin == 0
                return
            end

            if ~exist('offset', 'var')
                offset = obj.offset;
            end

            if ~SymopRotation.check_args({n, theta_deg, offset})
                error('HORACE:symop:invalid_argument', ...
                      ['Constructor arguments should be:\n', ...
                       '- Rotation:   symop(3vector, scalar, [3vector])\n', ...
                       'Received: %s'], disp2str({n, theta_deg, offset}));
            end

            obj.n = n;
            obj.theta_deg = theta_deg;
            obj.offset = offset;    % make col vector

        end

        function obj = set.n(obj, val)
            if  ~obj.is_3vector(val) || all(val==0)
                error('HORACE:symop:invalid_argument', ...
                      'Rotation vector n must be a three vector with at last one non-zero element');
            end
            obj.n_ = val(:);    % make col vector
        end

        function n = get.n(obj)
            n = obj.n_;
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

        function selected = in_irreducible(obj, coords, proj)
        % Compute whether the coordinates in `coords` (Q) are in the irreducible
        % set following the symmetry reduction under this operator
        %
        % For a rotation `R` about axis `n` of angle `theta`:
        %
        % For any `u` not parallel to `n` and v = R*u;
        % The planes defined by UN, VN encapsulate the reduced region
        % And thus any coordinate `q` from `Q` where
        % q*(n x u) > 0 && q*(v x n) > 0
        % belong to the irreducible set in the upper right quadrant

            if ~exist('proj', 'var')
                proj = line_proj();
            end

            if ~isequal(proj.angdeg, [90 90 90])
                error('HORACE:SymopRotation:invalid_argument', ...
                      ['Rotational reduction is only supported for an orthogonal projection. ', ...
                       'If using symmetrise_sqw, please pass through an orthogonal projection'])
            end

            n = obj.n / norm(obj.n);
            if sum(abs(n - [1; 0; 0])) > 1e-1
                u = [1; 0; 0];
            else
                u = [0; 1; 0];
            end

            v = obj.transform_vec(u);

            u = proj.transform_img_to_pix(u);
            v = proj.transform_img_to_pix(v);

            normvec_u = cross(n, u);
            normvec_v = cross(v, n);

            selected = (coords'*normvec_u >= 0 & ...
                        coords'*normvec_v > 0);
        end

        function R = calculate_transform(obj, Minv)
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
        %   >> R = calculate_transform (obj, Minv)
        %
        % Input:
        % ------
        %   obj     Symmetry operator object (scalar)
        %   Minv    Matrix to convert components of a vector given in rlu to those
        %          in an orthonormal frame
        %
        % Output:
        % -------
        %   R       Transformation matrix to be applied to the components of a
        %          vector given in the orthonormal frame for which Minv is defined
        % Express rotation vector in orthonormal frame
            n = Minv * obj.n_;
            % Perform active rotation (hence reversal of sign of theta
            R = rotvec_to_rotmat(-obj.theta_deg_*n/norm(n));
        end

        function local_disp(obj)
            fprintf('Rotation operator:\n');
            fprintf('       axis (rlu): %s\n', mat2str(obj.n, 2));
            fprintf('      angle (deg): %5.2f\n', obj.theta_deg);
            fprintf('     offset (rlu): %s\n', mat2str(obj.offset, 2));
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
        function flds = local_saveableFields(obj)
            flds = {'n', 'theta_deg', 'offset'};
        end
    end

end
