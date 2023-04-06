classdef (Abstract) SymopBase < matlab.mixin.Heterogeneous
% Symmetry operator describing equivalent points
%
% A symmetry operator object describes how equivalent points are defined by
% operations performed with respect to a reference frame by:
%   - Rotation about an axis through a given point
%   - Reflection through a plane passing through a given point
%
% An array, O, of the symmetry operator objects can be created to express a
% more complex operation, in which operations are applied in sequence O(1), O(2),...
%
% EXAMPLES:
%   Mirror plane defined by [1,0,0] and [0,1,0] directions passing through [1,1,1]
%       s1 = symop ([1,0,0], [0,1,0], [1,1,1]);
%
%   Equivalent points are reached by rotation by 90 degrees about c* passing
%   through [0,2,0]:
%       s2 = symop([0,0,1], 90, [0,2,0]);
%
%   Equivalent points are reached by first reflection in the mirror plane and
%   then rotating:
%       stot = [s1,s2]
%
% symop Methods:
% --------------------------------------
%   symop           - Create a symmetry operator object
%   transform_pix   - Transform pixel coordinates into symmetry related coordinates
%   transform_proj  - Transform projection axes description by the symmetry operation

    properties (Dependent)
        offset
    end

    properties (Access=private)
        offset_ = [0; 0; 0];  % offset vector for symmetry operator (rlu) (row)
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

        function vec = transform(obj, vec)
            if size(vec, 1) ~= 3
                error('HORACE:symop:invalid_argument', ...
                      'Input must be list of 3-vectors')
            end


            for i = numel(obj):-1:1
                R = obj(i).calculate_transform(eye(3));
                vec = R * vec;
            end
        end

        function pix = transform_pix(obj, upix_to_rlu, upix_offset, pix)
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
            if ~isequal(size(upix_to_rlu), [3,3])
                error('HORACE:symop:invalid_argument', ...
                      'Check upix_to_rlu is a 3x3 matrix')
            elseif ~(numel(upix_offset)==3 || numel(upix_offset)==4)
                error('HORACE:symop:invalid_argument', ...
                      'Check upix_offset is a vector length 3|4')
            elseif isempty(obj)
                error('HORACE:symop:invalid_argument', ...
                      'Empty symmetry operation object array')
            end

            % Get transformation
            n = numel(obj);

            Minv = upix_to_rlu(1:3,1:3) \ eye(3);  % seems to be slightly better than inv(M)
            Rtot = obj(end).calculate_transform(Minv);
            Om = obj(end).compute_offset(Rtot, Minv, upix_offset(1:3));

            for i=n-1:-1:1
                R = obj(i).calculate_transform(Minv);
                O = obj(i).compute_offset(R, Minv, upix_offset(1:3));
                Rtot = Rtot * R;
                Om = R \ Om + O;
            end

            % Transform pixels
            pix = Rtot \ pix_in + Om;

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
            b = bmatrix(proj.alatt, proj.angdeg);

            sgn = ones(1,numel(obj));
            for i=1:numel(obj)
                [proj, sgn] = transform_proj_single(obj(i), b, proj);
            end
            sgntot = prod(sgn);     % +1 or -1 depending on even or odd number of reflections

            if sgntot == -1     % odd number of reflections
                                % Does not work for non-orthogonal axes. The problem is that reflections
                                % do not have a simple relationship
                                % Find an axis to invert. Invert an integration axis (then there are no
                                % problems with order of bins in the sqw object); if none, then invert axis 3
                invert = cellfun(@numel, pbin) == 2;

                if invert(3)
                    pbin{3} = -flip(pbin{3});
                    proj.w = -proj.w;

                elseif invert(2)
                    pbin{2} = -flip(pbin{2});
                    proj.v = -proj.v;

                elseif invert(1)
                    pbin{1} = -flip(pbin{1});
                    proj.u = -proj.u;

                else
                    % The following is correct if the true bin descriptor is given
                    % i.e. the interval is an integer multiple of the step size
                    nbin = (pbin{3}(3) - pbin{3}(1)) / pbin{3}(2);
                    if floor(nbin) ~= nbin
                        error('HORACE:symop:invalid_argument', ...
                              'Range along third projection axis is not an integer multiple of bin size');
                    end
                    pbin{3} = -flip(pbin{3});
                    proj.w = -proj.w;

                end
            end
        end

    end

    methods (Access=private)
        function [proj, sgn] = transform_proj_single (obj, Minv, proj)
        % Note this function uses matrix Minv which transforms from rlu to
        % orthonormal components

            R = obj.calculate_transform(Minv);

            sgn = round(det(R));    % will be +1 for rotation, -1 for reflection

            proj.offset(1:3) = Minv \ R * Minv * (proj.offset(1:3)'-obj.offset_) + obj.offset_;

            u_new = (Minv \ R * Minv * proj.u(:));
            v_new = (Minv \ R * Minv * proj.v(:));
            if ~isempty(proj.w)
                w_new = (Minv \ R * Minv * proj.w(:));
                proj = proj.set_axes(u_new, v_new, w_new);
            else
                proj = proj.set_axes(u_new, v_new);
            end

        end

        function offset = compute_offset (obj, R, Minv, upix_offset)

            dp = Minv*(obj.offset - upix_offset(:));
            offset = dp - R \ dp;

        end
    end

    methods (Abstract)
        disp(obj)
        R = calculate_transform(Minv)
    end

    methods(Static)
        function is = is_3vector(elem)
            is = isnumeric(elem) && numel(elem) == 3;
        end

        function is = is_3x3matrix(elem)
            is = isnumeric(elem) && numel(elem) == 9;
        end
    end

end
