classdef SymopReflection < Symop
    % class defines reflection operation

    properties(Dependent)
        u; % first vector lying in and defining reflection plane
        v; % second vector lying in and defining reflection plane
        normvec; % unit vector, orthogonal to reflection plane
        is_rlu; % boolean variable which defines which units the vectors
        %       above are expressed in. Default true. (rlu, reciprocal
        %       lattice units)
    end

    properties(Access=private)
        u_ = [1;0;0];
        v_ = [0;1;0];
        normvec_ = [0;0;1];
        is_rlu_;
        set_from_normvec_ = false % true if the  is set from normal to
        % the plane
    end

    methods
        function obj = SymopReflection(varargin)
            % Construct Reflection operation:
            %
            % Possible inputs:
            % >>obj = SymopReflection(u,v);
            % >>obj = SymopReflection(u,v,offset);
            % >>obj = SymopReflection(__,b_matrix);
            % >>obj = SymopReflection(__,b_matrix,is_rlu);
            %
            % >>obj = SymopReflection('normal',normal,'offset',offset);
            %
            % Where:
            % u, v  -- two 3-vectors giving two directions that lie in a mirror plane
            %          (in reciprocal lattice units: (h,k,l), unless is_rlu is set to false)
            % offset   [Optional] 3-vector connecting the mirror plane to the origin
            %           i.e. is an offset vector (in reciprocal lattice units: (h,k,l))
            %          Default: [0,0,0] i.e. the mirror plane goes through the origin
            % or, optionally,
            % 'normal' keyword normal following by 3-vector defining normal
            if nargin == 0
                return
            end
            if strncmp(varargin{1},'no',2)
                % reflection plane is defined by bormal
                flds = {'normal','offset','b_matrix','is_rlu'};
            else
                flds = obj.saveableFields();
            end
            [obj,remains] = ...
                set_positional_and_key_val_arguments(obj,...
                flds,false,varargin{:});
            if ~isempty(remains)
                error('HORACE:SymopReflection:invalid_argument', ...
                    'Additional arguments %s have not been recognized', ...
                    disp2str(remains));
            end
        end
        function is = get.is_rlu(obj)
            if isempty(obj.is_rlu_)
                is = true;
            else
                is = obj.is_rlu_;
            end
        end
        function obj= set.is_rlu(obj,val)
            obj.is_rlu_ = logical(val);
        end

        function u = get.u(obj)
            u = obj.u_;
        end
        function obj = set.u(obj, val)
            if  ~obj.is_3vector(val)
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
            if  ~obj.is_3vector(val)
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
            normvec = obj.normvec_;
        end
        function obj = set.normvec(obj,val)
            if  ~obj.is_3vector(val)
                error('HORACE:symop:invalid_argument', ...
                    'plane-normal vector normvec must be a three vector');
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
            n = obj.normvec_;
            % Create reflection matrix in the orthonormal frame
            R = eye(3) - 2*(n*n');
        end

        function local_disp(obj)
            if obj.is_rlu
                units = 'rlu';
            else
                units = 'cc';
            end
            fprintf('Reflection operator:\n');
            fprintf(' In-plane u (%s): %s\n',units,mat2str(obj.u, 2));
            fprintf(' In-plane v (%s): %s\n',units,mat2str(obj.v, 2));
            fprintf('     offset (%s): %s\n',units,mat2str(obj.offset, 2));
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
        function obj = check_combo_arg(obj)
            obj = check_and_caclulate_vectors_and_R_(obj);
            obj = obj.check_offset_b_matrix_consistency();
        end
    end
    methods(Access = protected)
        function   obj = set_R(obj,varargin)
            error('HORACE:SymopReflection:invalid_argument',[...
                'You can not set up reflection matrix directly.\n' ...
                'Use SymopGeneral or input properties of SymopReflection class'])
        end
        function flds = local_saveableFields(~)
            flds = {'u', 'v', 'offset','b_matrix','is_rlu'};
        end
    end
end
