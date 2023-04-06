classdef SymopRotation < SymopBase

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

        function disp(obj)
            disp([indstr,'Rotation operator:'])
            disp(['       axis (rlu): ',mat2str(obj.n)])
            disp(['      angle (deg): ',num2str(obj.theta_deg)])
            disp(['     offset (rlu): ',mat2str(obj.offset)])
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
    end

    methods(Static)
        function is = check_args(argin)
            is = (numel(argin) == 2 || ...
                  numel(argin) == 3 && SymopBase.is_3vector(argin{3})) && ...
                  SymopBase.is_3vector(argin{1}) && ...
                  isscalar(argin{2});
        end
    end
end
