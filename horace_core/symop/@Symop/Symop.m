classdef(Abstract) Symop < matlab.mixin.Heterogeneous & serializable
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
        function [iseq,mess] = equal_to_tol(obj1,obj2,varargin)
            % overload equal_to_tol as this method requested to be called
            % on serializable interface
            [iseq,mess] = equal_to_tol@serializable(obj1,obj2,varargin{:});
        end
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

        function pix = transform_pix(obj, pix, proj, selected, trust)
            % Transform pixel coordinates into symmetry related coordinates
            %
            % The transformation converts the components of a vector which is
            % related by the symmetry operation into the equivalent vector. For example,
            % if the symmetry operation is a rotation by 90 degrees about
            % [0,0,1] in a cubic lattice with lattice parameter 2*pi, the point [0.3;0.1;2]
            % is transformed into [0.1;-0.3;2].
            %
            %   >> pix = transform_pix (obj, pix_in)
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
            %   pix         PixelData object
            %
            %   selected    Pixels to transform
            %
            %   trust       Whether to trust that `selected` is valid
            %               and bypass `in_irreducible` checks.
            % Output:
            % -------
            %   pix         Transformed PixelData object

            if ~exist('proj', 'var')
                proj = {};
            end
            if ~exist('selected', 'var')
                selected = 1:pix.num_pixels;
            end
            if ~exist('trust', 'var')
                trust = false;
            end

            % Check input
            if ~isa(pix, 'PixelDataBase')
                error('HORACE:Symop:invalid_argument', ...
                    'transform_pix requires pixels');
            end

            % Get transformation
            if isa(pix, 'PixelDataMemory')
                if ~trust
                    for i = numel(obj):-1:1
                        in_zone = obj(i).in_irreducible(pix.q_coordinates, proj{:});
                        in_zone(~selected) = false;
                        pix.q_coordinates(:, ~in_zone) = obj(i).transform_vec(pix.q_coordinates(:, ~in_zone));
                    end
                else
                    for i = numel(obj):-1:1
                        pix.q_coordinates(:, selected) = obj(i).transform_vec(pix.q_coordinates(:, selected));
                    end
                end
            else
                error('HORACE:Symop:not_implemented', ...
                    'Transforming file-backed pixels is not currently implemented');
            end

        end

        function proj = transform_proj (obj, proj)
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
            % Output:
            % -------
            %   proj    Transformed projection
            %

            % Check input
            if ~isa(proj, 'aProjectionBase')
                error('HORACE:Symop:invalid_argument', ...
                    'transform_proj requires projection');
            end

            % Transform proj
            for i=numel(obj):-1:1
                proj = obj(i).transform_proj_single(proj);
            end
        end
    end

    methods (Access=private)
        function proj = transform_proj_single (obj, proj)
            % Note this function uses matrix Minv which transforms from rlu to
            % orthonormal components

            switch class(proj)
                case 'line_proj'

                    u_new = obj.R * proj.u(:);
                    v_new = obj.R * proj.v(:);
                    offset_new = proj.offset(:);
                    offset_new(1:3) = obj.transform_vec(offset_new(1:3));
                    if ~isempty(proj.w)
                        w_new = obj.R * proj.w(:);
                        proj = proj.set_directions(u_new, v_new, [], offset_new);
                    else
                        proj = proj.set_directions(u_new, v_new, [], offset_new);
                    end
                case 'ubmat_proj'
                    lp = proj.get_line_proj();
                    u_new = obj.R * proj.u(:);
                    v_new = obj.R * proj.v(:);
                    offset_new = proj.offset(:);
                    proj = lp.set_directions(u_new, v_new, [], offset_new);

                case {'sphere_proj','cylinder_proj','kf_sphere_proj'}
                    if ~isa(obj,'SymopIdentity')
                        error('HORACE:Symop:not_implemented', ...
                            'Symmetry operation %s is not yet implemented for %s', ...
                            class(obj),class(proj));
                    end

                    %% TODO non-aligned ez/ey not supported
                    % ez_new = obj.R * proj.ez(:);
                    % ey_new = obj.R * proj.ey(:);

                    %                 offset_new = proj.offset(:);
                    %                 offset_new(1:3) = obj.transform_vec(offset_new(1:3));
                    %
                    %                 proj.offset = offset_new;
                otherwise
                    error('HORACE:Symop:not_implemented', ...
                        'Cannot transform projection class "%s"', class(proj));
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

    % Serializable interface
    methods(Sealed)
        function ser = serialize(obj, varargin)
            ser = serialize@serializable(obj, varargin{:});
        end

        function ser = deserialize(obj, varargin)
            ser = deserialize@serializable(obj, varargin{:});
        end

        function out = to_struct(obj, varargin)
            out = to_struct@serializable(obj, varargin{:});
            out.serial_name = 'SymopIdentity';
        end

        function out = to_bare_struct(obj, bare)
            out = struct('class', cell(numel(obj), 1), 'data', cell(numel(obj), 1));
            for i = 1:numel(obj)
                out(i) = struct('class', class(obj(i)), ...
                    'data', {cellfun(@(x) obj(i).(x), obj(i).saveableFields, 'UniformOutput', false)});
            end
        end

        function out = from_bare_struct(obj, array_dat)
            out = arrayfun(@(x) feval(x.class, x.data{:}), array_dat, 'UniformOutput', false);
            out = [out{:}];
        end

        function ver = classVersion(obj)
            ver = 1;
        end

        function flds = saveableFields(obj)
            flds = obj.local_saveableFields();
        end

        function [isne, mess] = ne(A, B, varargin)
            isne = ~eq(A, B, varargin);
            mess = '';
        end

        function [iseq, mess] = eq(A, B, varargin)

            mess = '';
            iseq = numel(A) == numel(B);
            if ~iseq
                mess = sprintf('Arrays not same size (%d, %d)', ...
                    numel(objA), numel(objB));
                return;
            end

            for i = 1:numel(A)
                objA = A(i);
                objB = B(i);

                iseq = class(objA) == class(objB);
                if ~iseq
                    mess = sprintf('Objects not of same class (%s, %s)', ...
                        class(objA), class(objB));
                    return;
                end

                iseq = equal_to_tol(objA.saveableFields(), objB.saveableFields());
                if ~iseq
                    mess = sprintf('Objects have mismatched fields (%s, %s)', ...
                        disp2str(objA.saveableFields()), ...
                        disp2str(objB.saveableFields()));
                    return;
                end

                fld = objA.saveableFields();
                for i = 1:numel(fld)
                    iseq = objA.(fld{i}) == objB.(fld{i});
                    if ~iseq
                        mess = sprintf('Objects differ in field %s (%s, %s)', ...
                            fld{i}, ...
                            disp2str(objA.(fld{i})), ...
                            disp2str(objB.(fld{i})));
                        return;
                    end
                end

            end
        end

    end
end
