function obj = symop (varargin)
    % Create a symmetry operator object.
    %
    % Valid operators are:
    %   Rotation:
    %       >> this = symop (axis, angle)
    %       >> this = symop (axis, angle, offset)
    %
    %       Input:
    %       ------
    %       axis    Vector defining the rotation axis
    %               (in reciprocal lattice units: (h,k,l))
    %       angle   Angle of rotation in degrees
    %       offset  [Optional] Vector defining a point in reciprocal lattice units
    %               through which the rotation axis passes
    %               Default: [0,0,0] i.e. the rotation axis goes throught the origin
    %
    %   Reflection:
    %       >> this = symop (u, v)
    %       >> this = symop (u, v, offset)
    %
    %       Input:
    %       ------
    %       u, v    Vectors giving two directions that lie in a mirror plane
    %               (in reciprocal lattice units: (h,k,l))
    %       offset  [Optional] Vector connecting the mirror plane to the origin
    %               i.e. is an offset vector (in reciprocal lattice units: (h,k,l))
    %               Default: [0,0,0] i.e. the mirror plane goes throught the origin
    %
    %   Symmetry Motion operator:
    %       >> this = symop(W, offset)
    %
    %       Input:
    %       ------
    %       W       A transformation operation in matrix form.
    %               W can represent the identity element {eye(3)},
    %               the inversion element {-eye(3)}, any rotation
    %               or any rotoinversion. The elements of W are
    %               almost certainly integers.
    %       offset  [Optional] The origin at which the transformation
    %               is performed, expressed in r.l.u.
    %               Default: [0,0,0]
    %
    % EXAMPLES:
    %   Rotation of 120 degress about [1,1,1]:
    %       this = symop ([1,1,1], 120)
    %
    %   Reflection through a plane going through the [2,0,0] reciprocal lattice point:
    %       this = symop ([1,1,0], [0,0,1], [2,0,0])

    if numel(varargin)>0

        if SymopIdentity.check_args(varargin)

            obj = SymopIdentity(varargin{:});
        elseif SymopReflection.check_args(varargin)

            obj = SymopReflection(varargin{:});
        elseif SymopRotation.check_args(varargin)

            obj = SymopRotation(varargin{:});
        elseif SymopMotion.check_args(varargin)

            obj = SymopMotion(varargin{:});
        else

            error('HORACE:symop:invalid_argument', ...
                  ['Constructor arguments should be one of:\n', ...
                   '- Rotation:   symop(3vector, scalar, [3vector])\n', ...
                   '- Reflection: symop(3vector, 3vector, [3vector])\n', ...
                   '- Motion:     symop(3x3matrix, [3vector])\n', ...
                   'Received: %s'], disp2str(varargin));

        end
    end
end
