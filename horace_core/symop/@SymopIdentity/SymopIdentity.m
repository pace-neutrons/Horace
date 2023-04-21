classdef SymopIdentity < Symop

    methods
        function obj = SymopIdentity(id, offset)
            if ~exist('id', 'var')
                id = eye(3);
            end
            if ~exist('offset', 'var')
                offset = [0; 0; 0];
            end

            if ~SymopIdentity.check_args({id, offset})
                error('HORACE:symop:invalid_argument', ...
                      ['Constructor arguments should be:\n', ...
                       '[1 0 0  [0\n', ...
                       ' 0 1 0 , 0\n', ...
                       ' 0 0 1]  0]\n', ...
                       'Actual arguments received : %s'], disp2str({id, offset}));
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
            R = Minv * eye(3);
        end

        function local_disp(obj)
            disp('Identity operator (no symmetrisation)')
        end
    end

    methods(Static)
        function is = check_args(argin)
            is = (numel(argin) == 1 || ...
                  numel(argin) == 2 && Symop.is_3vector(argin{2}) && ...
                  all(argin{2} == 0)) && ...
                 isequal(argin{1}, eye(3));
        end
    end
end
