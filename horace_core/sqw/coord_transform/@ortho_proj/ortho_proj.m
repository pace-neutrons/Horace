classdef ortho_proj<aProjection
    %  Class defines coordinate projections necessary to make Horace cuts
    %  in crystal coordinate system (orthogonal or non-orthogonal)
    %
    %  Uses projection axis and projection logic, defined by projaxis class
    %  and works as interface to this class for defining projection
    %
    %  Defines coordinate transformations, used by cut_sqw when making
    %  Horace cuts
    %
    %
    properties
        %
    end
    properties(Dependent)
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type; %='rrr';
        uoffset; %=[0,0,0,0];
        lab     %={'\zeta','\xi','\eta','E'};
        %
        % Matrix to convert from Crystal Cartesian (pix coordinate system)
        % to the image coordinate system (normally in rlu, except initially
        % generated sqw file, when this image is also in Crystal Cartesian)
        u_to_rlu
    end
    properties(Access=private)
        % reference to the class, which defines the projection axis
        projaxes_=[]
        %
        u_to_rlu_;
    end
    methods(Access = protected)
        % overloads for static methods which define if the projection can
        % keep pixels and have mex functions defined
        function isit= can_mex_cut_(~)
            % ortho projection have mex procedures defined
            isit = true;
        end
        %
        function [rot_to_img,shift]=get_pix_img_transformation(obj,ndim)
            % Return the transformation, necessary for conversion from pix
            % to image coordinate system and vise-versa if the projaxes is
            % defined
            % Input:
            % ndim -- number of dimensions in the pixels coordinate array
            %         (3 or 4). Depending on this number the routine
            %         returns 3D or 4D transformation matrix
            %
            [rlu_to_ustep, ~] = projaxes_to_rlu(obj.projaxes_,obj.alatt, obj.angdeg, [1,1,1]);
            b_mat  = bmatrix(obj.alatt, obj.angdeg);
            rot_to_img = rlu_to_ustep/b_mat;
            %
            if ndim==4
                shift  = obj.uoffset';
                u_to_rlu_l  = [b_mat,[0;0;0];[0,0,0,1]];
                rot_to_img = [rot_to_img,[0;0;0];[0,0,0,1]];
            elseif ndim == 3
                shift  = obj.uoffset(1:3)';
                u_to_rlu_l  = b_mat;
            else
                error('HORACE:rundatah:invalid_argument',...
                    'The size of the pixels array should be [3xNpix] or [4xNpix], actually it is: %s',...
                    evalc('disp(size(pix_cc))'));
            end
            % convert shift, expressed in hkl into crystal Cartesian
            shift = u_to_rlu_l \shift';
            
        end
    end
    
    methods
        function proj=ortho_proj(varargin)
            proj = proj@aProjection();
            if nargin==0 % return defaults
                %proj.projaxes_ = [];
                %proj.data_lab_ = {'qx','qy','qz','en'};
                proj.u_to_rlu_ =eye(3)/(2*pi);
                [ul,vl]=proj.uv_from_rlu_mat(proj.alatt,proj.angdeg,proj.u_to_rlu_,[1,1,1]);                
                proj.projaxes_ = projaxes(ul,vl,[0,0,0.5/pi],'type','ppp');
            else
                if isa(varargin{1},'projaxes')
                    proj.projaxes_ = varargin{1};
                else
                    proj.projaxes_ = projaxes(varargin{:});
                end
            end
        end
        function mat = get.u_to_rlu(obj)
            mat = obj.u_to_rlu_;
        end
        function obj = set.u_to_rlu(obj,mat)
            
            obj.u_to_rlu_ = mat;
            %[ul,vl]=obj.uv_from_rlu_mat(obj.alatt,obj.angdeg,mat,[1,1,1]);
            %obj.u_ = ul;
            %obj.v_ = vl;
        end
        
        
        function u = get.u(this)
            if isempty(this.projaxes_)
                u= 'dnd-X-aligned';
            else
                u = this.projaxes_.u;
            end
        end
        function v = get.v(this)
            if isempty(this.projaxes_)
                v= 'dnd-Y-aligned';
            else
                v = this.projaxes_.v;
            end
        end
        function w = get.w(this)
            if isempty(this.projaxes_)
                w= [];
            else
                w = this.projaxes_.w;
            end
        end
        function type = get.type(this)
            if isempty(this.projaxes_)
                type = 'aaa';
            else
                type = this.projaxes_.type;
            end
        end
        function this =set.type(this,val)
            if isempty(this.projaxes_)
                error('HORACE:rundatah:invalid_argument',...
                    'define ortho_proj plains first');
            else
                this.projaxes_.type = val;
            end
        end
        
        function uoffset = get.uoffset(this)
            if isempty(this.projaxes_)
                uoffset = [0;0;0;0];
            else
                uoffset = this.projaxes_.uoffset;
            end
        end
        function obj = set.uoffset(obj,val)
            if isempty(obj.projaxes_)
                error('HORACE:ortho_proj:invalid_argument',...
                    'Can not set up uoffset when projaxes transformation is not defined');
            end
            obj.projaxes_.uoffset = val;
        end
        function lab = get.lab(this)
            if isempty(this.projaxes_)
                lab = this.data_lab_;
            else
                lab = this.projaxes_.lab;
            end
        end
        %------------------------------------------------------------------
        % Particular implementation of aProjection abstract interface
        %------------------------------------------------------------------
        function range_out = find_old_img_range(this,range_in)
            % find the range of initial data in the coordinate frame
            % of the new projection.
            % Input:
            % range_in -- the range of the data in the initial coordinate
            % system.
            % Output:
            % range_out -- the range the initial image data in the new
            % (transformed) coordinate system of the cut.
            range_out  = find_ranges_(this,range_in);
        end
        
        function [istart,iend,irange,inside,outside] =get_irange_proj(this,img_range,varargin)
            % Get ranges of bins that partially or wholly lie inside an n-dimensional rectangle,
            % where the first three dimensions can be rotated and translated w.r.t. the
            % cuboid that is split into bins.
            [istart,iend,irange,inside,outside] = get_irange_rot(this,img_range,varargin{:});
        end
        %
        function [indx,ok] = get_contributing_pix_ind(this,v)
            % get list of indexes contributing into the cut
            [indx,ok] = get_contributing_pix_ind_(this,v);
        end
        function [uoffset,ulabel,dax,u_to_rlu,ulen,title_build_class] = get_proj_param(this,data_in,pax)
            % get projection parameters, necessary for properly defining a sqw or dnd object
            %
            [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param_(this,data_in,pax);
            title_build_class = an_axis_caption();
        end
        %
        function [urange_step_pix_recent, ok, ix, s, e, npix, npix_retain,success]=...
                accumulate_cut(this,v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads)
            %Method, used to both project data and allocate memory used by
            %sqw&dnd objects. Has to be written in close conjunction with
            %cut_sqw using deep understanding of the ways memory is allocated
            % within sqw objects
            [urange_step_pix_recent, ok, ix, s, e, npix, npix_retain,success]=...
                accumulate_cut_(this,v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads);
        end
        %
        function pix_transformed = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in crystal Cartesian coordinate systems
            % into image coordinate system
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system
            % Returns:
            % pix_transformed -- the pixels transformed into coordinate
            %             system, related to image (often hkl system)
            %
            pix_transformed = transform_pix_to_img_(obj,pix_data);
        end
        %
        function pix_cc = transform_img_to_pix(obj,pix_hkl,varargin)
            % Transform pixels expressed in image coordinate coordinate systems
            % into crystal Cartesian coordinate system
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system
            % Returns
            % pix_cc -- pixels expressed in Crystal Cartesian coordinate
            %            system
            %
            pix_cc = transform_img_to_pix_(obj,pix_hkl);
        end
    end
    
    methods(Static)
        function [u,v]=uv_from_rlu_mat(alatt,angdeg,u_to_rlu,ulen)
            % Extract initial u/v vectors, defining the plane in hkl from
            % lattice parameters and the matrix converting vectors in
            % crystal Cartesian coordinate system into rlu.
            %
            % partially inverting projaxes_to_rlu function of projaxes class
            % as only orthogonal to u part of the v-vector can be recovered
            %
            % Inputs:
            % alatt -- lattice parameters. [1x3]-vector of positive numbers
            %          describing lattice cell size. (In A-units)
            % angdeg-- vector 3 angles describing the lattice cell.
            %          Expressed in degree
            % u_to_rlu -- matrix used for conversion from pixel coordinate
            %          system to the image coordinate system (normally
            %          expressed in rlu)
            % ulen  -- length of the unit vectors of the reciprocal lattice
            %          units, the Horace image is expressed in
            % Outputs:
            % u     -- [1x3] vector expressed in rlu and defining the cut
            %          direction
            % v     -- [1x3] vector expressed in rlu, and together with u
            %          defining the cut plain
            
            
            %u_to_rlu(:,i) = ubinv(:,i)*ulen(i);
            ulen_inv = 1./ulen;
            ubinv = u_to_rlu.*repmat(ulen_inv,3,1);
            ubmat = inv(ubinv);
            b_mat = bmatrix(alatt, angdeg);
            %ub = umat*b_mat;
            umat = ubmat/b_mat;
            %
            u_dir = (b_mat\umat(1,:)')';
            % vector, parallel to u:
            u = u_dir/norm(u_dir);
            
            % the length of the V-vector, orthogonal to u (unit vector)
            % in fact real v-vector is not fully recoverable. We can
            % recover only the orthogonal part
            v_tr =  (b_mat\umat(2,:)')';
            v = v_tr/norm(v_tr);
            %
            w=ubinv(:,3)';  % perpendicular to u and v, length 1 Ang^-1, forms rh set with u and v
            
            uvw=[u(:),v(:),w(:)];
            uvw_orthonorm=ubmat*uvw;    % u,v,w in the orthonormal frame defined by u and v
            ulen_new = diag(uvw_orthonorm);
            scale = ulen./ulen_new';
            u = u*scale(1);
            v = v*scale(2);
        end
    end
end
