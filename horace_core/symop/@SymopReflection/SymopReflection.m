classdef SymopReflection < Symop
    % class defines reflection operation

    properties(Dependent)
        u; % first vector lying in and defining reflection plane
        v; % second vector lying in and defining reflection plane
        normvec; % unit vector in CC system, orthogonal to the reflection
        %          plane. Input normvector defines it but does not equal to
        %          it, as input may be expressed in rlu
    end
    properties(Dependent,Hidden)
        input_nrmv_in_rlu; % boolean variable which defines units of input
        %       normvec.  The property affects only case when you set up
        %       reflection plane by providing its normvec. Normally
        %       the vector is treated as the vector defined in Crystal
        %       Cartesian coordinate system, which does not matter for
        %       orthogonal lattice. For non-orthogonal lattice this value
        %       have to be defined as true of false, which defines the way,
        %       normvector have to be treated when B-matrix becomes
        %       available
    end

    properties(Access=private)
        u_ = [1;0;0];
        v_ = [0;1;0];
        normvec_ = [0;0;1];
        input_nrmv_in_rlu_;  %
        set_from_normvec_ = false % true if the reflection plane is set
        % by defining the normal vector to the plane.
    end

    methods
        function obj = SymopReflection(varargin)
            % Construct Reflection operation:
            %
            % Possible inputs:
            % >>obj = SymopReflection(u,v);
            % >>obj = SymopReflection(u,v,offset);
            % >>obj = SymopReflection(__,b_matrix);
            %
            % Alternatively, set up reflection plane from the notmal to it.
            % 'normal','offset' and 'b_matrix' parameters have to be present
            % as key-value pairs
            % >>obj = SymopReflection("no[rmal]",normal,"of[fset]",offset);
            % >>obj = SymopReflection(__,"b_matrix",b_matrix,['rlu'|'cc']);
            %
            % Where:
            % u, v     --  two 3-vectors giving two directions that lie in
            %              a mirror plane (in reciprocal lattice units:
            %              (h,k,l))
            % offset   --  [Optional] 3-vector connecting the mirror plane
            %              to the origin i.e. is an offset vector
            %              (in reciprocal lattice units: (h,k,l))
            %              Default: [0,0,0] i.e. the mirror plane goes
            %              through the origin.
            % b_matrix --  Bussing-Levy matrix converting from rlu to Crystal
            %              Cartesian coordinates.
            %
            % Opional for orthogonal, mandatory for non-orthogonal
            %              coordinate system:
            % coord-sytem
            %          -- 'rlu' or 'cc'. By default, normal vector is
            %              defined in Crystal Cartesian coordinate system,
            %              which is not important if your lattice is
            %              orthogonal.
            % WARNING: -- you must provide 'rlu' or 'cc' parameter if your
            %             crystal lattice is not orthogonal, to emphasisise,
            %             that you understand the meaining of you lattice
            %             vector in non-orthogonal system. In majority of
            %             cases for non-orthogonal system it is easier to
            %             define reflection plane by defining two vectors
            %             in this plane
            if nargin == 0
                return
            end
            if istext(varargin{1})
                % reflection plane is defined by normal to it
                flds = {'normvec','offset','b_matrix','input_nrmv_in_rlu'};
                [argi,coord_defined_at] = Symop.parse_sym_normvec_inputs(flds,varargin{:});
                obj.set_from_normvec_ = true;
                if coord_defined_at>0
                    obj.input_nrmv_in_rlu_ = argi{coord_defined_at};
                end

            else
                flds = obj.saveableFields();
                argi = varargin;
            end
            [obj,remains] = ...
                set_positional_and_key_val_arguments(obj,...
                flds,false,argi{:});
            if ~isempty(remains)
                error('HORACE:SymopReflection:invalid_argument', ...
                    'Additional arguments %s have not been recognized', ...
                    disp2str(remains));
            end
        end
        function is = get.input_nrmv_in_rlu(obj)
            if isempty(obj.input_nrmv_in_rlu_)
                is  = true;
            else
                is = obj.input_nrmv_in_rlu_;
            end
        end
        function obj= set.input_nrmv_in_rlu(obj,val)
            if ~obj.set_from_normvec_
                return;
            end
            obj = obj.set_input_nrmv_in_rlu(val);
        end

        function u = get.u(obj)
            u = obj.u_;
        end
        function obj = set.u(obj, val)
            [is,val] = obj.check_and_brush_3vector(val);
            if  ~is
                error('HORACE:SymopReflection:invalid_argument', ...
                    'Reflection vector u must be a three vector');
            end
            obj.set_from_normvec_ = false;
            obj.u_ = val(:);    % make col vector
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function v = get.v(obj)
            v = obj.v_;
        end
        function obj = set.v(obj, val)
            [is,val] = obj.check_and_brush_3vector(val);
            if  ~is
                error('HORACE:SymopReflection:invalid_argument', ...
                    'Reflection vector v must be a three vector');
            end
            obj.set_from_normvec_ = false;
            obj.v_ = val(:);    % make col vector
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function normvec = get.normvec(obj)
            % method always returns normvec in Crystal Cartesian as this is
            % the system of coordinates, all calculations are performed in.
            normvec = obj.normvec_;
        end
        function obj = set.normvec(obj,val)
            [is,val] = obj.check_and_brush_3vector(val);
            if  ~is
                error('HORACE:symop:invalid_argument', ...
                    'plane-normal vector normvec must be a three-elements vector');
            end
            obj.set_from_normvec_ = true;
            obj.normvec_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function selected = in_irreducible(obj, coords, tolerance)
            % Compute whether the coordinates in `coords` are in the irreducible
            % set following the operation.
            % If tolerance is present, calculate the belonging coordinates
            % including tolerance

            u_offset = obj.u_offset_;
            if tolerance <= 0
                selected = (coords-u_offset)'*obj.normvec > 0;
            else
                selected = (coords-u_offset)'*(obj.normvec) + tolerance > 0;
            end
        end

        function R = calculate_transform(obj, varargin)
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
            %   Bmat    Matrix to convert components of a vector given in rlu
            %           to those in an orthonormal frame
            %
            % Output:
            % -------
            %   R       Transformation matrix to be applied to the components of a
            %          vector given in the orthonormal frame for which Minv is defined
            % Determine the representation of u and v in the orthonormal frame
            n = obj.normvec;
            % Create reflection matrix in the orthonormal frame
            R = eye(3) - 2*(n*n');
        end

        function local_disp(obj)
            if obj.input_nrmv_in_rlu % call to public method to get correct
                % answer regardless of the actual coordinate system is set
                % up or not
                units = '(rlu)';
            else
                units = ' (cc)';
            end
            fprintf('Reflection operator:\n');
            cu = mat2str(obj.u, 2);  cof = mat2str(obj.offset, 2);
            len_cu = numel(cu);  len_cof = numel(cof);
            max_len = max(len_cu,len_cof);
            f1 =sprintf(' In-plane u(rlu): %%%ds;',max_len);
            f2 =sprintf('     offset(rlu): %%%ds; ',max_len);
            fprintf(f1,cu);
            fprintf(' In-plane v(rlu): %s\n',mat2str(obj.v, 2));
            fprintf(f2,mat2str(obj.offset,2));
            fprintf('  normvec %s: %s\n',units,mat2str(obj.normvec, 2));
        end
    end

    % Serializable interface
    methods
        function obj = check_combo_arg(obj,input_in_rlu)
            if nargin>1
                obj.input_nrmv_in_rlu_ = input_in_rlu;
            end
            obj = check_and_caclulate_vectors_and_R_(obj);
            obj = obj.check_offset_b_matrix_consistency();
        end
    end
    methods(Access = protected)
        function  out = set_R(~,varargin)
            error('HORACE:SymopReflection:invalid_argument',[...
                'You can not set up reflection matrix directly.\n' ...
                'Use SymopGeneral or input properties of SymopReflection class'])
        end
        function flds = local_saveableFields(~)
            flds = {'u', 'v', 'offset','b_matrix'};
        end
    end
end
