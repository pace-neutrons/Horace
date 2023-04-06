classdef SymopMotion < SymopBase

    properties(Dependent)
        W;
    end

    properties(Access=private)
        W_;
    end

    methods
        function obj = SymopMotion(W, offset)
            if ~exist('offset', 'var')
                offset = obj.offset;
            end

            if ~SymopMotion.check_args({W})
                error('HORACE:symop:invalid_argument', ...
                      ['Constructor arguments should be:\n', ...
                       '- Motion:     symop(3x3matrix, [3vector])\n', ...
                       'Received: %s'], disp2str(W));
            end

            obj.W = W;
            obj.offset = offset;

        end

        function obj = set.W(obj, val)
            if  ~obj.is_3x3matrix(val) || det(val) ~= 1
                error('HORACE:symop:invalid_argument', ...
                      'Motion matrix W must be a 3x3 matrix with determinant 1, det: %d', det(val));
            end
            obj.W_ = reshape(val, [3 3]);
        end

        function W = get.W(obj)
            W = obj.W_;
        end

        function disp(obj)
            disp('Motion:')
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
            R = obj.W;
        end
    end

    methods(Static)
        function is = check_args(argin)
            is = (numel(argin) == 1 || ...
                  numel(argin) == 2 && SymopBase.is_3vector(argin{2})) && ...
                  SymopBase.is_3x3matrix(argin{1});
        end
    end
end
