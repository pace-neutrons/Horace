classdef SymopGeneral < Symop

    properties(Dependent,Hidden)
        W; % redundant interface. Use R for modern
    end

    methods

        function obj = SymopGeneral(varargin)
            % General transformation class constructor
            %>>op = SymopRotation(R,offset)
            %>>op = SymopRotation(R,offset,b_matrix)
            %Inputs:
            % R --  3x3 matrix defining generic symmetry transformation
            % Optional:
            % offset -- center of transformation
            % 

            if nargin == 0
                return
            end
            flds = obj.saveableFields();
            [obj,remains] = ...
                set_positional_and_key_val_arguments(obj,...
                flds,false,varargin{:});
            if ~isempty(remains)
                error('HORACE:SymopRotation:invalid_argument', ...
                    'Additional arguments %s have not been recognized', ...
                    disp2str(remains));
            end
        end
        % Redundant properties used for compatibility only
        function obj = set.W(obj, val)
            obj = set_R(obj,val);
        end
        function W = get.W(obj)
            W = obj.R_;
        end

        function selected = in_irreducible(~, ~, ~)
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
            R = obj.R_;
        end

        function local_disp(obj)
            fprintf('Sym op: \n')
            if any(obj.offset)
                fprintf(' % 6.4f % 6.4f % 6.4f   % 6.4f\n', obj.R(1, :), obj.offset(1));
                fprintf(' % 6.4f % 6.4f % 6.4f + % 6.4f\n', obj.R(2, :), obj.offset(2));
                fprintf(' % 6.4f % 6.4f % 6.4f   % 6.4f\n', obj.R(3, :), obj.offset(3));
            else
                fprintf(' % 6.4f % 6.4f % 6.4f\n', obj.R(1, :));
                fprintf(' % 6.4f % 6.4f % 6.4f\n', obj.R(2, :));
                fprintf(' % 6.4f % 6.4f % 6.4f\n', obj.R(3, :));
            end
        end

    end
    % Serializable interface
    methods
        function obj = check_combo_arg(obj)
            obj = obj.check_offset_b_matrix_consistency();
        end
    end
    methods(Access = protected)
        function   obj = set_R(obj,val)
            if  ~obj.is_3x3matrix(val) || abs(det(val)) - 1 > 1e-4
                error('HORACE:symop:invalid_argument', ...
                    'Motion matrix R must be a 3x3 matrix with determinant |1|, det: %d', det(val));
            end
            obj.R_ = reshape(val, [3 3]); % Just requires 9 elements & numeric
        end

        function flds = local_saveableFields(~)
            flds = {'R', 'offset','b_matrix'};
        end
    end


end
