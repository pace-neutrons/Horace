classdef symop
    % Symmetry operator describing equivalent points
    %
    % A symmetry operator object describes how equivalent points are defined by
    % operations performed with respect to a reference frame by:
    %   - Rotation about an axis through a given point
    %   - Reflection thrugh a plane passing through a given point
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
    %   is_identity     - Determine if a symmetry operation is the identity operation
    %   is_rotation     - Determine if a symmetry operation is a rotation
    %   is_reflection   - Determine if a symmetry operation is a reflection
    %   is_motion       - Determine if a symmetry operation was supplied as a complete motion
    
    properties (Access=private)
        uoffset_ = [];  % offset vector for symmetry operator (rlu) (row)
        u_ = [];        % first vector defining reflection plane (rlu) (row)
        v_ = [];        % second vector defining reflection plane (rlu) (row)
        n_ = [];        % rotation axis (un-normalised) (rlu) (row)
        theta_deg_ = [];% rotation angle (deg)
        W_ = [];        % motion transformation operation (real space matrix)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
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
                [ok,mess_refl,u,v,uoffset] = check_reflection_args (varargin{:});
                if ok
                    obj.uoffset_ = uoffset;
                    obj.u_ = u;
                    obj.v_ = v;
                    return
                end
                [ok,mess_rot,n,theta_deg,uoffset] = check_rotation_args (varargin{:});
                if ok
                    obj.uoffset_ = uoffset;
                    obj.n_ = n;
                    obj.theta_deg_ = theta_deg;
                    return
                end
                [ok,mess_mot,W,uoffset] = check_motion_args(varargin{:});
                if ok
                    obj.W_ = W;
                    obj.uoffset_ = uoffset;
                    return
                end
                error('dummy:ID','%s\n*OR*\n%s\n*OR*\n%s',mess_refl,mess_rot,mess_mot);
            end
        end
        
        function disp (obj)
            % Display information about the symmetry operator
            %
            %   >> disp(this)
            
            % Format three vector as string:
            vec2str = @(v)(['[',num2str(v(1)),', ',num2str(v(2)),', ',num2str(v(3)),']']);
            
            if isempty(obj)
                disp('Empty symmetry operation object')
            elseif numel(obj)>1
                disp('Sequence of symmetry operations:')
                disp(' ')
            end
            
            indstr='';
            for i=1:numel(obj)
                if numel(obj)>1
                    indstr = sprintf('[%d] ',i);
                end
                if is_identity(obj(i))
                    disp([indstr,'Identity operator (no symmetrisation)'])
                elseif is_rotation(obj(i))
                    disp([indstr,'Rotation operator:'])
                    disp(['       axis (rlu): ',vec2str(obj(i).n_)])
                    disp(['      angle (deg): ',num2str(obj(i).theta_deg_)])
                    disp(['     offset (rlu): ',vec2str(obj(i).uoffset_)])
                elseif is_reflection(obj(i))
                    disp([indstr,'Reflection operator:'])
                    disp([' In-plane u (rlu): ',vec2str(obj(i).u_)])
                    disp([' In-plane v (rlu): ',vec2str(obj(i).v_)])
                    disp(['     offset (rlu): ',vec2str(obj(i).uoffset_)])
                elseif is_motion(obj(i))
                    disp([indstr,'Motion:'])
                    if sum(abs(obj(i).uoffset_))>0
                        fprintf(' % 1d % 1d % 1d    % g\n',obj(i).W_(1,:),obj(i).uoffset_(1));
                        fprintf(' % 1d % 1d % 1d  + % g\n',obj(i).W_(2,:),obj(i).uoffset_(2));
                        fprintf(' % 1d % 1d % 1d    % g\n',obj(i).W_(3,:),obj(i).uoffset_(3));
                    else
                        fprintf(' % 1d % 1d % 1d\n',obj(i).W_(1,:));
                        fprintf(' % 1d % 1d % 1d\n',obj(i).W_(2,:));
                        fprintf(' % 1d % 1d % 1d\n',obj(i).W_(3,:));
                    end
                else
                    error('Logic error - see developers')
                end
                disp(' ')
            end
        end
        
        %------------------------------------------------------------------
        % Other methods
        function status = is_identity(obj)
            % Determine if a symmetry operation is the identity operation
            %
            %   >> status = is_identity (this)
            if isscalar(obj)
                
                status = isempty(obj.uoffset_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = isempty(obj(i).uoffset_);
                end
            end
        end
        
        function status = is_rotation(obj)
            % Determine if a symmetry operation is a rotation
            %
            %   >> status = is_rotation (this)
            if isscalar(obj)
                status = ~isempty(obj.n_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = ~isempty(obj(i).n_);
                end
            end
        end
        
        function status = is_reflection(obj)
            % Determine if a symmetry operation is a reflection
            %
            %   >> status = is_reflection (this)
            if isscalar(obj)
                status = ~isempty(obj.u_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = ~isempty(obj(i).u_);
                end
            end
        end
        
        function status = is_motion(obj)
            if isscalar(obj)
                status = ~isempty(obj.W_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = ~isempty(obj(i).W_);
                end
            end
        end
        
        %------------------------------------------------------------------
        % Interfaces
        [ok, mess, proj, pbin] = transform_proj (obj, alatt, angdeg, proj_in, pbin_in)
        
        pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
    end
end
