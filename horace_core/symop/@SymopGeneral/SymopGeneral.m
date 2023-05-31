classdef SymopGeneral < Symop

    properties(Dependent)
        W;
    end

    properties(Access=protected)
        W_ = eye(3);
    end

    methods

        function obj = set.W(obj, val)
            if  ~obj.is_3x3matrix(val) || abs(det(val)) - 1 > 1e-4
                error('HORACE:symop:invalid_argument', ...
                      'Motion matrix W must be a 3x3 matrix with determinant 1, det: %d', det(val));
            end
            obj.W_ = reshape(val, [3 3]); % Just requires 9 elements & numeric
        end

        function W = get.W(obj)
            W = obj.W_;
        end

        function selected = in_irreducible(~, ~)
        % Compute whether the coordinates in `coords` are in the irreducible
        % set following the operation
            error('HORACE:symop:not_implemented', ...
                  'Cannot compute the irreducible set from general 3x3 transform');
        end

        function R = calculate_transform(obj, ~)
        % Get transformation matrix for the symmetry operator in an orthonormal frame
        %
        % The transformation matrix converts the components of a vector which is
        % related by the symmetry operation into the equivalent vector. The
        % coordinates of the vector are expressed in an orthonormal frame.
        %
        % For example, if the symmetry operation is a rotation by -90 degrees about
        % [0,0,1] in a cubic lattice with lattice parameter 2*pi, the point [0.3,0.1,2]
        % is transformed into [0.1,-0.3,2].
        %
        % The transformation matrix accounts for reflection or rotation, but not
        % translation, which is associated with the offset in the symmetry operator.
        %
        %   >> R = calculate_transform (obj, Minv)
        %
        % Input:
        % ------
        %   obj     Symmetry operator object (scalar)
        %   Minv    Matrix to convert components of a vector given in rlu to those
        %             in an orthonormal frame
        %
        % Output:
        % -------
        %   R       Transformation matrix to be applied to the components of a
        %          vector given in the orthonormal frame for which Minv is defined
            R = obj.W_;
        end

        function local_disp(obj)
            fprintf('Sym op: \n')
            if any(obj.offset)
                fprintf(' % 6.4f % 6.4f % 6.4f   % 6.4f\n', obj.W(1, :), obj.offset(1));
                fprintf(' % 6.4f % 6.4f % 6.4f + % 6.4f\n', obj.W(2, :), obj.offset(2));
                fprintf(' % 6.4f % 6.4f % 6.4f   % 6.4f\n', obj.W(3, :), obj.offset(3));
            else
                fprintf(' % 6.4f % 6.4f % 6.4f\n', obj.W(1, :));
                fprintf(' % 6.4f % 6.4f % 6.4f\n', obj.W(2, :));
                fprintf(' % 6.4f % 6.4f % 6.4f\n', obj.W(3, :));
            end
        end
    end


end
