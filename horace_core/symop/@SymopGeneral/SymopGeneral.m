classdef SymopGeneral < Symop

    properties(Dependent)
        W;
    end

    properties(Access=protected)
        W_ = eye(3);
    end

    methods

        function obj = set.W(obj, val)
            if  ~obj.is_3x3matrix(val) || abs(det(val)) ~= 1
                error('HORACE:symop:invalid_argument', ...
                      'Motion matrix W must be a 3x3 matrix with determinant 1, det: %d', det(val));
            end
            obj.W_ = reshape(val, [3 3]); % Just requires 9 elements & numeric
        end

        function W = get.W(obj)
            W = obj.W_;
        end

        function R = calculate_transform(obj, Minv)
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
        %             in an orthonormal frame, this is used by SymopRotation
        %
        % Output:
        % -------
        %   R       Transformation matrix to be applied to the components of a
        %          vector given in the orthonormal frame for which Minv is defined
            R = obj.W_;
        end

        function local_disp(obj)
            disp('Sym op:')
            if any(obj.offset ~= 0)
                fprintf(' % 1d % 1d % 1d    % g\n', obj.W(1, :), obj.offset(1));
                fprintf(' % 1d % 1d % 1d  + % g\n', obj.W(2, :), obj.offset(2));
                fprintf(' % 1d % 1d % 1d    % g\n', obj.W(3, :), obj.offset(3));
            else
                fprintf(' % 1d % 1d % 1d\n', obj.W(1, :));
                fprintf(' % 1d % 1d % 1d\n', obj.W(2, :));
                fprintf(' % 1d % 1d % 1d\n', obj.W(3, :));
            end
        end
    end


end
