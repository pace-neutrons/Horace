classdef(Abstract) Symop < matlab.mixin.Heterogeneous
% Symmetry operator describing equivalent points
%
% A symmetry operator object describes how equivalent points are defined by
% operations performed with respect to a reference frame by:
%   - Rotation about an axis through a given point
%   - Reflection through a plane passing through a given point
%
% An array of the symmetry operator objects can be created to express a
% more complex operation, in which operations are applied in sequence op(N)*op(N-1)*...*op(1)*targ
%
% EXAMPLES:
%   Equivalent points are reached by general 3x3 Matrix transform
%       s = SymopGeneral([1,0,0; 0 -1 0; 0,0,-1], [1,1,1]);
%       s = Symop.create([1,0,0; 0 -1 0; 0,0,-1], [1,1,1]);
%
%   Identity (no-op) transform
%       s = SymopIdentity();
%       s = Symop.create(eye(3));
%
%   Equivalent points are reached by [1,0,0] and [0,1,0] directions passing through [1,1,1]
%       s1 = SymopReflection([1,0,0], [0,1,0], [1,1,1]);
%       s1 = Symop.create([1,0,0], [0,1,0], [1,1,1]);
%
%   Equivalent points are reached by rotation by 90 degrees about c* passing
%   through [0,2,0]:
%       s2 = SymopRotation([0,0,1], 90, [0,2,0]);
%       s2 = Symop.create([0,0,1], 90, [0,2,0]);
%
%   Equivalent points are reached by first reflection in the mirror plane and
%   then rotating:
%       stot = [s1,s2]
%
% symop Methods:
% --------------------------------------
%   Symop           - Create a general symmetry operator object through 3x3 matrix specification
%   create          - Create appropriate symmetry operator object from
%   transform_vec   - Transform a 3xN list of vectors
%   transform_pix   - Transform pixel coordinates into symmetry related coordinates
%   transform_proj  - Transform projection axes description by the symmetry operation

    properties(Dependent)
        % Offset of transform
        offset;
        % General transformation matrix for operator
        R;
    end

    properties (Access=private)
        offset_ = [0; 0; 0];  % offset vector for symmetry operator (rlu) (col)
    end

    methods
        function obj = Symop(W, offset)
            if nargin == 0
                return
            end

            if ~exist('offset', 'var')
                offset = obj.offset;
            end

            if ~Symop.check_args({W, offset})
                error('HORACE:symop:invalid_argument', ...
                      ['Constructor arguments should be:\n', ...
                       '- General:  Symop(3x3matrix, [3vector])\n', ...
                       'Received: %s'], disp2str(W));
            end

            obj.W = W;
            obj.offset = offset;

        end

        function offset = get.offset(obj)
            offset = obj.offset_;
        end

        function obj = set.offset(obj, val)
            if ~obj.is_3vector(val)
                error('HORACE:symop:invalid_argument', ...
                      'Offset must be a numeric 3-vector')
            end
            obj.offset_ = val(:);
        end

        function R = get.R(obj)
        % Compute general transformation matrix for operator
        % Computing so as to generate it for Symop subclasses
            R = obj.calculate_transform(eye(3));
        end

    end

    methods(Abstract)
        R = calculate_transform(obj, Minv)
        local_disp(obj)
        selected = in_irreducible(obj, coords)
    end

    methods(Sealed)

        function vec = transform_vec(obj, vec)
        % Transform a vector or list of vectors according to array of
        % Symops stored in `obj`.
        %
        % Input:
        %   obj    Array of symmetry operator objects
        %   vec    3xN list of 3-vectors to transform
        % Output:
        %   vec    Transformed set of vectors

            if size(vec, 1) ~= 3
                error('HORACE:symop:invalid_argument', ...
                      'Input must be list of 3-vectors')
            end

            for i = numel(obj):-1:1
                vec = vec - obj(i).offset;
                vec = obj(i).R * vec;
                vec = vec + obj(i).offset;
            end
        end

        function disp(obj)
        % Display set of symmetry operations resulting in transform
        % even if specified as array of symops
            if isscalar(obj)
                obj.local_disp();
            else
                disp('[');
                for i = obj
                    i.local_disp();
                end
                disp(']');
            end
        end

        function pix = transform_pix(obj, pix)
        % Transform pixel coordinates into symmetry related coordinates
        %
        % The transformation converts the components of a vector which is
        % related by the symmetry operation into the equivalent vector. For example,
        % if the symmetry operation is a rotation by 90 degrees about
        % [0,0,1] in a cubic lattice with lattice parameter 2*pi, the point [0.3;0.1;2]
        % is transformed into [0.1;-0.3;2].
        %
        %   >> pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
        %
        % Input:
        % ------
        %   obj         Symmetry operator or array of symmetry operators
        %               If an array, then they are applied in order obj(1), obj(2),...
        %
        %   upix_to_rlu Matrix to convert components of a vector in pixel coordinate
        %              frame (which is an orthonormal frame) into rlu (3x3 matrix)
        %
        %   upix_offset Offset of origin of pixel coordinate frame (rlu) (vector length 3)
        %
        %   pix         Pixel coordinates (3 x n array).
        %
        % Output:
        % -------
        %   pix_out     Transformed pixel array (3 x n array).

            % Check input
            if ~isa(pix, 'PixelDataBase')
                error('HORACE:symop:invalid_argument', ...
                      'Transform pix requires pixels');
            end

            % Get transformation
            if isa(pix, 'PixelDataMemory')
                sel = obj.in_irreducible(new_coords);
                pix.q_coordinates(:, ~sel) = obj.transform_vec(new_coords(:, ~sel));
            else
                error('HORACE:symop:not_implemented', ...
                      'filebacked pix reduction not possible')
            end

        end

        function [proj, pbin] = transform_proj (obj, proj, pbin)
        % Transform projection axes description by the symmetry operation
        %
        %   >> proj = transform_proj (obj, proj)
        %
        % Input:
        % ------
        %   obj     Symmetry operator or array of symmetry operators
        %           If an array, then they are applied in order obj(1), obj(2),...
        %
        %   proj    Projection object defining projection axes, with fields
        %               u, v, w (optionally)
        %           (other fields are unaffected)
        %
        %   pbin    Cell array with the exact bin descriptor along each Q axis. That is,
        %           if the ith axis is an integration axis pbin_in{i} is a vector
        %           length 2; if a plot axis it is a vector length 3 where the
        %           final element is the true bin centre of the last bin i.e. the
        %           range is an integer multiple of the step. (row, length 3)
        %
        % Output:
        % -------
        %   proj    Transformed projection
        %
        %   pbin    Cell array with transformed bin descriptors. (row, length 3)
        %
        %
        % Note: the reason for requiring the condition on projection axes in the
        % description of pbin_in is that in the case of a reflection and all three
        % momentum axes being plot axes, the third axis has to be inverted to ensure
        % a right-hand coordinate set. Strictly, the condition only applies to the
        % third axis when all three momentum axes are plot axes.

            if isempty(obj)
                error('HORACE:symop:invalid_argument', ...
                      'Empty symmetry operation object array')
            end

            if proj.nonorthogonal
                error('HORACE:symop:invalid_argument', ...
                      'Symmetry transformed non-orthogonal projections not supported');
            end

            % Transform proj
            for i=numel(obj):-1:1
                proj = obj(i).transform_proj_single(proj);
            end
        end
    end

    methods (Access=private)
        function [proj, sgn] = transform_proj_single (obj, proj)
        % Note this function uses matrix Minv which transforms from rlu to
        % orthonormal components


            u_new = obj.R * proj.u(:);
            v_new = obj.R * proj.v(:);
            offset_new = proj.offset(:);
            offset_new(1:3) = obj.transform_vec(offset_new(1:3));
            if ~isempty(proj.w)
                w_new = obj.R * proj.w(:);
                proj = proj.set_axes(u_new, v_new, w_new, offset_new);
            else
                proj = proj.set_axes(u_new, v_new, [], offset_new);
            end

        end

        function offset = compute_offset (obj, R, Minv, upix_offset)

            dp = Minv*(obj.offset - upix_offset(:));
            offset = dp - R \ dp;

        end
    end

    methods(Static)
        function obj = create(varargin)
        % Create a symmetry operator object.
        %
        % Valid operators are:
        %   Rotation:
        %       >> obj = Symop.create (axis, angle)
        %       >> obj = Symop.create (axis, angle, offset)
        %
        %       Input:
        %       ------
        %       axis    Vector defining the rotation axis                                 [3-vector]
        %               (in reciprocal lattice units: (h,k,l))
        %       angle   Angle of rotation in degrees                                      [scalar]
        %       offset  [Optional] Vector defining a point in reciprocal lattice units
        %               through which the rotation axis passes
        %               Default: [0,0,0] i.e. the rotation axis goes throught the origin
        %
        %   Reflection:
        %       >> obj = Symop.create (u, v)
        %       >> obj = Symop.create (u, v, offset)
        %
        %       Input:
        %       ------
        %       u, v    Vectors giving two directions that lie in a mirror plane          [3-vector]
        %               (in reciprocal lattice units: (h,k,l))
        %       offset  [Optional] Vector connecting the mirror plane to the origin
        %               i.e. is an offset vector (in reciprocal lattice units: (h,k,l))
        %               Default: [0,0,0] i.e. the mirror plane goes throught the origin
        %
        %   Symmetry Motion operator:
        %       >> obj = Symop.create(W, offset)
        %
        %       Input:
        %       ------
        %       W       A transformation operation in matrix form.                        [3x3 matrix]
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
        %       obj = Symop.create ([1,1,1], 120)
        %
        %   Reflection through a plane going through the [2,0,0] reciprocal lattice point:
        %       obj = Symop.create ([1,1,0], [0,0,1], [2,0,0])

            if numel(varargin)>0

                if SymopIdentity.check_args(varargin)

                    obj = SymopIdentity(varargin{:});
                elseif SymopReflection.check_args(varargin)

                    obj = SymopReflection(varargin{:});
                elseif SymopRotation.check_args(varargin)

                    obj = SymopRotation(varargin{:});
                elseif Symop.check_args(varargin)

                    obj = SymopGeneral(varargin{:});
                else

                    error('HORACE:symop:invalid_argument', ...
                          ['Constructor arguments should be one of:\n', ...
                           '- Rotation:   symop(3vector, scalar, [3vector])\n', ...
                           '- Reflection: symop(3vector, 3vector, [3vector])\n', ...
                           '- General:    symop(3x3matrix, [3vector])\n', ...
                           'Received: %s'], disp2str(varargin));

                end
            end
        end

        function is = check_args(argin)
            is = (numel(argin) == 1 || ...
                  numel(argin) == 2 && Symop.is_3vector(argin{2})) && ...
                  Symop.is_3x3matrix(argin{1});
        end

        function is = is_3vector(elem)
            is = isnumeric(elem) && numel(elem) == 3;
        end

        function is = is_3x3matrix(elem)
            is = isnumeric(elem) && numel(elem) == 9;
        end
    end

end
