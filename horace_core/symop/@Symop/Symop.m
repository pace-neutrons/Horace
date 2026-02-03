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
        % General transformation matrix for selected symmetry operation
        R;
    end
    properties(Dependent,Hidden)
        % helper property, used to transform offset from hkl to Crystal
        % Cartesian coordinate system used in marjority of pixel
        % transformations
        b_matrix;
    end

    properties (Access=private)
        offset_ = [0; 0; 0];  % offset vector for symmetry operator (rlu) (col)
        % this is not true
        u_offset_ = [0;0;0] % offset vector in Crystal Cartesian coordinate system (orthogonal, A^-1)

        % CACHES for performance
        offset_specified_uoffset_not_ = false; % helper property used to ensure
        % that offset in Crystal Cartesisian has been modified in
        % accordence with offset in rlu. Calculations should not happen if they are asynchroneous
        b_matrix_ = [];
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
            obj.offset_specified_uoffset_not_  = true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function bm = get.b_matrix(obj)
            bm = obj.b_matrix_;
        end
        function obj = set.b_matrix(obj,matr)
            if ~obj.is_3x3matrix(matr)
                error('HORACE:symop:invalid_argument', [...
                    'B-matrix must be a numeric 3x3-martix converting rlu to Crystal Cartesian.\n',...
                    'Provided object type is %s and size %s'],...
                    class(matr),disp2str(size(matr)))
            end
            obj.b_matrix_ = matr;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function R = get.R(obj)
            % Compute general transformation matrix for operator
            % Computing so as to generate it for Symop subclasses
            R = obj.calculate_transform(eye(3));
        end

    end

    methods(Abstract)
        R = calculate_transform(obj, B_mat)
        local_disp(obj)
        selected = in_irreducible(obj, coords)
    end

    methods(Sealed)
        function obj = check_combo_arg(obj)
            % check interdependent class variables and
            % put them into consistent state
            %
            % Here we synchronize u_offset and offset if B-matrix is
            % defined. If not, they remain unsynchronized
            zero_offset =  all(obj.offset_ == 0);
            if zero_offset
                obj.u_offset_ = zeros(3,1);
                obj.offset_specified_uoffset_not_  = false;
            else
                if isempty(obj.b_matrix_)
                    obj.offset_specified_uoffset_not_  = true;
                else
                    obj.u_offset_ = obj.b_matrix_*obj.offset_;
                    obj.offset_specified_uoffset_not_  = false;
                end
            end

        end
        function [iseq,mess] = equal_to_tol(obj1,obj2,varargin)
            % overload equal_to_tol as this method requested to be called
            % on serializable interface
            [iseq,mess] = equal_to_tol@serializable(obj1,obj2,varargin{:});
        end
        function vec = transform_vec(obj, vec,use_rlu_offset)
            % Transform a vector or array of vectors according to array of
            % Symops stored in `obj`.
            %
            % To avoid confusion, vector coorinate system expected to be
            % orthogonal and Crystal Cartesian (if offset present, it
            % expressed in CC, if it is 0, other coordinates may be
            % considered
            %
            % Input:
            %   obj    Array of symmetry operator objects
            %   vec    3xN list of 3-vectors to transform
            %   use_rlu_offset
            %          normally input vector is expressed in Crystal
            %          Cartesian coordinate system, so offset should be
            %          defined accordingly. In some cases (e.g. tests)
            %          one may want to transform vector expressed in rlu.
            %          In this case,
            %          this property should be set to true. The option
            %          should be used carefully, to ensure that vector is
            %          in rlu indeed and not in arbitrary image coordinate
            %          system.
            %          Important for cases where offset is present.
            % Output:
            %   vec    Transformed set of vectors

            if size(vec, 1) ~= 3
                error('HORACE:symop:invalid_argument', ...
                    'Input must be list of 3-vectors')
            end
            if nargin<3
                use_rlu_offset = false;
            end

            % only single offset is allowed on groupt of objects
            if use_rlu_offset
                shift = obj(1).offset;
            else
                if obj(1).offset_specified_uoffset_not_
                    error('HORACE:symop:invalid_argument',[ ...
                        'You are attempting to symmetry-transform vector in Crystal Cartesial coordinate system,\n',...
                        'but the information to transfer offset in rlu to CC have not been set.\n',...
                        'Set up B-matrix, used to transfer vector into Crystal Cartesian coordinate system either by\n',...
                        'using extended form of transform_proj method or assigning it directly to hidden Symop property: "b_matrix"'])
                end
                shift = obj(1).u_offset_;
            end

            vec = vec - shift;
            for i = numel(obj):-1:1
                vec = obj(i).R * vec;
            end
            vec = vec + shift;
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

        function pix = transform_pix(obj, pix, proj, selected, trust,use_rlu_offset)
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
            %
            % Output:
            % -------
            %   pix         Transformed PixelData object

            if ~exist('proj', 'var')
                proj = {};
            end
            define_selected = false;
            if ~exist('selected', 'var')
                define_selected = true;
            end
            if nargin<5 % ~exist('trust', 'var')
                trust = false;
            end
            if nargin<6 % ~exist('use_rlu_offset','var')
                use_rlu_offset = false;
            end

            % Check input
            if isa(pix,'PixelDataMemory')
                q_coordinates = pix.q_coordinates;
                is_pix_obj = true;
                if define_selected
                    selected = true(1,pix.num_pixels);
                end
            elseif isnumeric(pix) && size(pix,1) == 3
                q_coordinates = pix;
                is_pix_obj = false;
                if define_selected
                    selected = true(1,size(pix,2));
                end
            else
                error('HORACE:Symop:not_implemented', ...
                    'Transforming of %s pixels is not currently implemented',class(pix));
            end

            % Do transformation
            if ~trust
                for i = numel(obj):-1:1
                    nin_zone = ~obj(i).in_irreducible(q_coordinates, proj{:});
                    %in_zone(~selected) = false;
                    transform = selected & nin_zone';
                    q_coordinates(:,transform) = obj(i).transform_vec(q_coordinates(:,transform),use_rlu_offset);
                end
            else
                for i = numel(obj):-1:1
                    q_coordinates(:, selected) = obj(i).transform_vec(q_coordinates(:, selected),use_rlu_offset);
                end
            end
            if is_pix_obj
                pix.q_coordinates = q_coordinates;
            else
                pix = q_coordinates;
            end
        end

        function [proj,obj] = transform_proj (obj, proj)
            % Transform projection axes description by the symmetry operation
            % or array of symmetry operations.
            %
            % NOTE:
            % first operation in symmetry array should not be a
            % SymopIdentity unless it is intentional as all other
            % transformations in the array will be ignored.
            % Array of transformations should not contain SymopIdentity as
            % the result may be confusing.
            %
            %   >> proj = transform_proj (obj, proj)
            %
            % Input:
            % ------
            %   obj     Symmetry operator or array of symmetry operators
            %           If an array, then symmetries are applied in order:
            %           obj(end), obj(end-1),...obj(1);
            %           All symmetry operations in array must have the same
            %           offset. If non-zero offset is set on one symmetry
            %           operation out of array, it will be distribured to
            %           all operations in the array.
            %
            %
            %   proj    Projection object describing original coordinate
            %           system
            %
            % Output:
            % -------
            %   proj    Projection object describing coordinate system
            %           modified by symmetry transformation(s)
            %   obj     input array of symmetries modified by having b-matrix
            %           taken from input projection and set on each symmetry
            %           operation.
            %           This matrix is necessary if symmetry operations
            %           are using offset and allow to transfer offset
            %           expressed in hkl coordinate system into Crystan
            %           Cartesian coordinate system, where all symmetry
            %           transformations should be applied initially.
            %           Also, if offset is set on only one symmetry
            %           transformation, it will be propagated to all
            %           symmetry transformations.
            %
            %

            % Check input
            if ~isa(proj, 'aProjectionBase')
                error('HORACE:Symop:invalid_argument', ...
                    'transform_proj requires projection');
            end
            [sym_offset,obj] = obj.extract_common_group_offset();

            % Build transformation, constructed from number of primitive
            % transformations available in array of transformations
            sym_transf_mat = proj.sym_transf;
            if isempty(sym_transf_mat )
                sym_transf_mat = eye(3);
            end
            bm = proj.bmatrix(3);
            for i=numel(obj):-1:1
                obj(i).do_check_combo_arg = false;
                obj(i).b_matrix = bm;
                if ~isa(obj(i),'SymopIdentity')
                    sym_transf_mat = obj(i).R*sym_transf_mat;
                    obj(i).offset = sym_offset;
                end
                obj(i).do_check_combo_arg = true;
                obj(i) = obj(i).check_combo_arg();
            end

            proj = obj(1).transform_proj_single(proj,sym_transf_mat,sym_offset,bm);
        end
    end

    methods (Access=private)
        function [sym_offset,symmetries] = extract_common_group_offset(symmetries)
            % check if offset is the same within the group of symmetry
            % transformations, extract common offset if some symmetry
            % objects in the group does not have offset and throw if
            % non-zero offset are different.
            %
            % Set up common offset on each element of the group if some
            % elements of the group had zero offset.
            %
            % Inputs:
            %
            % symmetries -- array of symop-s. (Should not contain identity)
            zer = zeros(3,1);
            sym_offset = zer;
            n_sym_offsets = 0;
            for obj=symmetries
                if any(abs(obj.offset-zer)>4*eps('double'))
                    n_sym_offsets = n_sym_offsets + 1;
                    if n_sym_offsets>1
                        if any(abs(obj.offset-sym_offset)>4*eps('double'))
                            error('HORACE:Symop:not_implemented',[ ...
                                'Multiple offsets for group of transformations are not implemented.\n',...
                                'All transformations in a transformation group array must have the same offset\n',...
                                'used by all transfomations in the group\n',...
                                'or the same offset for each element of the group']);
                        end
                    else
                        sym_offset  = obj.offset;
                    end
                end
            end
            if n_sym_offsets> 0 && n_sym_offsets ~= numel(obj)
                % there are offsets set on one or multiple symmetries but
                % some symmetries have zero offsets. This is not allowed as
                % assumed that they all must have the same offset.
                for obj=symmetries
                    obj.offset = sym_offset;
                end
            end
        end
        function lp = transform_proj_single (obj, proj,sym_transf_mat,sym_offset,bm)
            % Transform input projection in such a way, that its
            % pix to image transformation become equivalent to
            % original pix to image transformation followed by symmetry
            % transformation, i.e.:
            % new_proj.transform_pix_to_img(vec) == obj.R*orig_proj.transform_pix_to_img(vec);
            %
            %
            % Note this function uses matrix Minv which transforms from rlu to
            % orthonormal components
            switch class(proj)
                case 'line_proj'
                    lp = proj;
                case 'ubmat_proj'
                    lp = proj.get_line_proj();
                otherwise
                    if isa(obj,'SymopIdentity')
                        return
                    else
                        error('HORACE:Symop:not_implemented', ...
                            'Symmetry operation %s is not yet implemented for proj class: %s', ...
                            class(obj),class(proj));
                    end
            end

            % To avoid keeping unnecessary transformation matrices
            % and multiply by them later, clear up unit transformation
            % if this is the transformation to apply to projection.
            dif = sym_transf_mat-eye(3);
            if any(abs(dif(:))>4*eps('double'))
                lp.do_check_combo_arg = false;
                lp.sym_transf = sym_transf_mat;
            else
                lp.sym_transf= [];
                return
            end
            offset_old = lp.offset(1:3);
            offset_old_cc = bm*offset_old(:);
            sym_offset_cc = bm*sym_offset(:);
            % new offset in Crystal Cartesian
            offset_cc = sym_transf_mat*sym_offset_cc(:) -sym_offset_cc(:)+offset_old_cc(:);

            offset_new = bm\offset_cc; % new offset in hkl

            lp.offset(1:3) = offset_new';
            lp.do_check_combo_arg = true;
            lp = lp.check_combo_arg();
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
            is = (isscalar(argin) || ...
                numel(argin) == 2 && Symop.is_3vector(argin{2})) && ...
                Symop.is_3x3matrix(argin{1});
        end

        function is = is_3vector(elem)
            is = isnumeric(elem) && numel(elem) == 3;
        end

        function is = is_3x3matrix(elem)
            is = isnumeric(elem) && all(size(elem) == [3,3]);
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

        function out = to_bare_struct(obj, varargin)
            out = struct('class', cell(numel(obj), 1), 'data', cell(numel(obj), 1));
            for i = 1:numel(obj)
                out(i) = struct('class', class(obj(i)), ...
                    'data', {cellfun(@(x) obj(i).(x), obj(i).saveableFields, 'UniformOutput', false)});
            end
        end

        function out = from_bare_struct(~, array_dat)
            out = arrayfun(@(x) feval(x.class, x.data{:}), array_dat, 'UniformOutput', false);
            out = [out{:}];
        end

        function ver = classVersion(~)
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
                    numel(A), numel(B));
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
                for j = 1:numel(fld)
                    iseq = objA.(fld{j}) == objB.(fld{j});
                    if ~iseq
                        mess = sprintf('Objects differ in field %s (%s, %s)', ...
                            fld{j}, ...
                            disp2str(objA.(fld{j})), ...
                            disp2str(objB.(fld{j})));
                        return;
                    end
                end

            end
        end

    end
end
