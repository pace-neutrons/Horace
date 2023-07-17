classdef SymopReflection < Symop

    properties(Dependent)
        u;
        v;
        normvec;
    end

    properties(Access=private)
        u_;
        v_;
    end

    methods
        function obj = SymopReflection(u, v, offset)
            if nargin == 0
                return
            end

            if ~exist('offset', 'var')
                offset = obj.offset;
            end

            if ~SymopReflection.check_args({u, v, offset})
                error('HORACE:symop:invalid_argument', ...
                      ['Constructor arguments should be:\n', ...
                       '- Reflection: symop(3vector, 3vector, [3vector])\n', ...
                       'Received: %s'], disp2str({u, v, offset}));
            end

            if norm(cross(u, v)) < 1e-2
                error('HORACE:symop:invalid_argument', ...
                      'Colinear vectors u & v')
            end

            obj.u = u;
            obj.v = v;
            obj.offset = offset;
        end

        function obj = set.u(obj, val)
            if  ~obj.is_3vector(val)
                error('HORACE:symop:invalid_argument', ...
                      'Reflection vector u must be a three vector');
            end
            obj.u_ = val(:);    % make col vector
        end

        function u = get.u(obj)
            u = obj.u_;
        end

        function obj = set.v(obj, val)
            if  ~obj.is_3vector(val)
                error('HORACE:symop:invalid_argument', ...
                      'Reflection vector v must be a three vector');
            end
            obj.v_ = val(:);    % make col vector
        end

        function v = get.v(obj)
            v = obj.v_;
        end

        function normvec = get.normvec(obj)
            normvec = cross(obj.u, obj.v);
            normvec = normvec / norm(normvec);
        end

        function selected = in_irreducible(obj, coords)
        % Compute whether the coordinates in `coords` are in the irreducible
        % set following the operation
            selected = coords'*obj.normvec > 0;
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
        % Determine the representation of u and v in the orthonormal frame
            e1 = Minv * obj.u_;
            e2 = Minv * obj.v_;
            n = cross(e1,e2);
            n = n / norm(n);
            % Create reflection matrix in the orthonormal frame
            R = eye(3) - 2*(n*n');
        end

        function local_disp(obj)
            fprintf('Reflection operator:\n');
            fprintf(' In-plane u (rlu): %s\n', mat2str(obj.u, 2));
            fprintf(' In-plane v (rlu): %s\n', mat2str(obj.v, 2));
            fprintf('     offset (rlu): %s\n', mat2str(obj.offset, 2));
        end
    end

    methods(Static)
        function is = check_args(argin)
            is = (numel(argin) == 2 || ...
                  numel(argin) == 3 && Symop.is_3vector(argin{3})) && ...
                  Symop.is_3vector(argin{1}) && ...
                  Symop.is_3vector(argin{2});
        end
    end

    % Serializable interface
    methods
        function flds = local_saveableFields(obj)
            flds = {'u', 'v', 'offset'};
        end
    end

end
