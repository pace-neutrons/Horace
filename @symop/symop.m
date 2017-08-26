classdef symop
    % Symmetry operator describing reflection or rotation
    properties (Access=private)
        uoffset_ = [];  % offset vector for symmetry operator (rlu) (row)
        u_ = [];        % first vector defining reflection plane (rlu) (row)
        v_ = [];        % second vector defining reflection plane (rlu) (row)
        n_ = [];        % rotation axis (un-normalised) (rlu) (row)
        theta_deg_ = [];% rotation angle (deg)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = symop (varargin)
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
                error ('dummy:ID',[mess_refl,'\n*OR* ',mess_rot])
            end
        end
        
        function disp (obj)
            if is_empty(obj)
                disp('Null operator (no symmetrisation')
            elseif is_rotation(obj)
                disp('Rotation:')
                disp(['       axis (rlu): ',num2str(obj.n_)])
                disp(['      angle (deg): ',num2str(obj.theta_deg_)])
                disp(['     offset (rlu): ',num2str(obj.uoffset_)])
            elseif is_reflection(obj)
                disp('Reflection:')
                disp([' In-plane u (rlu): ',num2str(obj.u_)])
                disp([' In-plane v (rlu): ',num2str(obj.v_)])
                disp(['     offset (rlu): ',num2str(obj.uoffset_)])
            else
                error('Logic error - see developers')
            end
        end
        
        %------------------------------------------------------------------
        % Other methods
        function status = is_empty(obj)
            status = isempty(obj.uoffset_);
        end
        
        function status = is_rotation(obj)
            status = ~isempty(obj.n_);
        end
        
        function status = is_reflection(obj)
            status = ~isempty(obj.u_);
        end
        
        %------------------------------------------------------------------
        % Interfaces
        [ok, mess, proj, pbin] = transform_proj (obj, alatt, angdeg, proj_in, pbin_in)
        
        pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
    end
end
