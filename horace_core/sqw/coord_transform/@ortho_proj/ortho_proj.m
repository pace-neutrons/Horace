classdef ortho_proj<aProjection
    %  Class defines coordinate projections necessary to make Horace cuts
    %  in crystal coordinate system (orthogonal or non-orthogonal)
    %
    %  Defines coordinate transformations, used by cut_sqw when making
    %  Horace cuts
    %
    % Object that defines the orhtolinear projection operations
    %
    % Structure input:
    %   >> proj = ortho_proj(proj_struct)
    %
    % Argument input:
    %   >> proj = ortho_proj(u,v)
    %   >> proj = ortho_proj(u,v,w)
    %
    %   and any of the optional arguments:
    %
    %   >> proj = ortho_proj(...,'nonorthogonal',nonorthogonal,..)
    %   >> proj = ortho_proj(...,'type',type,...)
    %   >> proj = ortho_proj(...,'uoffset',uoffset,...)
    %   >> proj = ortho_proj(...,'lab',labelcellstr,...)
    %   >> proj = ortho_proj(...,'lab1',labelstr,...)
    %                   :
    %   >> proj = ortho_proj(...,'lab4',labelstr,...)
    %
    % Input:
    % ------
    % Projection axes are defined by two vectors in reciprocal space, together
    % with optional arguments that control normalisation, orthogonality, labels etc.
    % The input can be a data structure with fieldnames and contents chosen from
    % the arguments below, or alternatively the arguments
    %
    % Required arguments:
    %   u           [1x3] Vector of first axis (r.l.u.) defining projection axes
    %   v           [1x3] Vector of second axis (r.l.u.) defining projection axes
    %
    % Optional arguments:
    %   w           [1x3] Vector of third axis (r.l.u.) - only needed if the third
    %               character of argument 'type' is 'p'. Will otherwise be ignored.
    %
    %   nonorthogonal  Indicates if non-orthogonal axes are permitted
    %               If false (default): construct orthogonal axes u1,u2,u3 from u,v
    %               by defining: u1 || u; u2 in plane of u and v but perpendicular
    %               to u with positive component along v; u3 || u x v
    %
    %               If true: use u,v (and w, if given) as non-orthogonal projection
    %               axes: u1 || u, u2 || v, u3 || w if given, or u3 || u x v if not.
    %
    %   type        [1x3] Character string defining normalisation. Each character
    %               indicates how u1, u2, u3 are normalised, as follows:
    %               - if 'a': projection axis unit length is one inverse Angstrom
    %               - if 'r': then if ui=(h,k,l) in r.l.u., is normalised so
    %                         max(abs(h,k,l))=1
    %               - if 'p': if orthogonal projection axes:
    %                               |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
    %                           i.e. the projections of u,v,w along u1,u2,u3 match
    %                           the lengths of u1,u2,u3
    %
    %                         if non-orthogonal axes:
    %                               u1=u;  u2=v;  u3=w
    %               Default:
    %                   'ppr'  if w not given
    %                   'ppp'  if w is given
    %
    
    % Original author: T.G.Perring
    %
    %
    properties
        %
    end
    properties(Dependent)
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type;  % Character string length 3 defining normalisation. each character being 'a','r' or 'p' e.g. 'rrp'
        nonorthogonal; % Indicates if non-orthogonal axes are permitted (if true)
        %
        % Matrix to convert from Crystal Cartesian (pix coordinate system)
        % to the image coordinate system (normally in rlu, except initially
        % generated sqw file, when this image is also in Crystal Cartesian)
        %u_to_rlu
    end
    properties(Access=private)
        u_ = [1,0,0]
        v_ = [0,1,0]
        w_ = []
        nonorthogonal_=false
        type_='ppr'
        %
        %u_to_rlu_;
        
        %
        % The property reports if the object is valid. It can become
        % invalid if some fields have been set up incorrectly after
        % creation (e.g. u set up parallel to v) See check_combo_arg_ for
        % all options which may be invalid
        valid_ = true
    end
    
    methods
        function proj=ortho_proj(varargin)
            proj = proj@aProjection();
            if nargin==0 % return defaults, which describe unit transformation from
                % Crystal Cartesian (pixels) to Crystal Cartesian (image)
                u_to_rlu =eye(3)/(2*pi);
                [ul,vl]=proj.uv_from_rlu(u_to_rlu,[1,1,1]);
                proj = proj.init(ul,vl,[0,0,0.5/pi],'type','ppp');
            else
                proj.lab = {'\zeta','\xi','\eta','E'};
                proj = proj.init(varargin{:});
            end
        end
        function obj = init(obj,varargin)
            if nargin == 0
                return
            end
            [obj,remains] = process_positional_args_(obj,varargin{:});
            [obj,remains] = init@aProjection(obj,remains{:});
            obj = process_keyval_args_(obj,remains{:});
            [ok,mess,obj] = obj.isvalid();
            if ~ok
                error('HORACE:ortho_proj:invalid_argument',mess);
            end
            
        end
        %-----------------------------------------------------------------
        %         function mat = get.u_to_rlu(obj)
        %             mat = obj.u_to_rlu_;
        %         end
        %         function obj = set.u_to_rlu(obj,mat)
        %             obj.u_to_rlu_ = mat;
        %             %[ul,vl]=obj.uv_from_rlu_mat(obj.alatt,obj.angdeg,mat,[1,1,1]);
        %             %obj.u_ = ul;
        %             %obj.v_ = vl;
        %         end
        %
        function u = get.u(obj)
            if obj.valid_
                u = obj.u_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    u = obj.u_;
                else
                    u = mess;
                end
            end
        end
        function obj = set.u(obj,val)
            obj = check_and_set_uv_(obj,'u',val);
            [~,~,obj] = check_combo_arg_(obj);
        end
        %
        function v = get.v(obj)
            if obj.valid_
                v = obj.v_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    v = obj.v_;
                else
                    v = mess;
                end
            end
        end
        function obj = set.v(obj,val)
            obj = check_and_set_uv_(obj,'v',val);
            [~,~,obj] = check_combo_arg_(obj);
        end
        %
        function w = get.w(obj)
            if obj.valid_
                w = obj.w_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    w = obj.w_;
                else
                    w = mess;
                end
            end
        end
        function obj = set.w(obj,val)
            obj = check_and_set_w_(obj,val);
            [~,~,obj] = check_combo_arg_(obj);
        end
        %
        function no=get.nonorthogonal(obj)
            no = obj.nonorthogonal_;
        end
        function obj=set.nonorthogonal(obj,val)
            obj = check_and_set_nonorthogonal_(obj,val);
        end
        %
        function typ=get.type(obj)
            if obj.valid_
                typ = obj.type_;
            else
                [ok,mess] = check_combo_arg_(obj);
                if ok
                    typ = obj.type_;
                else
                    typ  = mess;
                end
            end
        end
        function obj=set.type(obj,type)
            obj = check_and_set_type_(obj,type);
            [~,~,obj] = check_combo_arg_(obj);
        end
        %
        function obj = set_from_ubmat(obj,u_to_rlu,ulen)
            [ur,vr]=obj.uv_from_rlu(u_to_rlu(1:3,1:3),ulen(1:3));
            obj.u = ur;
            obj.v = vr;
            [ok,mess,obj] = check_combo_arg_(obj);
            if ~ok
                error('HORACE:ortho_proj:invalid_argument',...
                    'Can not set uv from ub-matrix: %s',mess);
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
        %
        function  flds = indepFields(obj)
            flds = indepFields@aProjection(obj);
            flds = [flds(:),obj.fields_to_save_(:)];
        end
    end
    %----------------------------------------------------------------------
    properties(Constant, Access=private)
        fields_to_save_ = {'u','v','w','nonorthogonal','type'}
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = ortho_proj();
            obj = loadobj@serializable(S,obj);
        end
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
            [rlu_to_ustep, ~] = projaxes_to_rlu_(obj, [1,1,1]);
            b_mat  = bmatrix(obj.alatt, obj.angdeg);
            rot_to_img = rlu_to_ustep/b_mat;
            %
            if ndim==4
                shift  = obj.offset;
                u_to_rlu_l  = [b_mat,[0;0;0];[0,0,0,1]];
                rot_to_img = [rot_to_img,[0;0;0];[0,0,0,1]];
            elseif ndim == 3
                shift  = obj.offset(1:3);
                u_to_rlu_l  = b_mat;
            else
                error('HORACE:orhto_proj:invalid_argument',...
                    'The ndim input may be 3 or 4  actually it is: %s',...
                    evalc('disp(size(ndim))'));
            end
            % convert shift, expressed in hkl into crystal Cartesian
            shift = u_to_rlu_l \shift';
            
        end
        function  [rlu_to_ustep, u_to_rlu, ulen] = uv_to_rlu(proj,ustep)
            % Determine matricies to convert rlu <=> projection axes, and the scaler
            %
            %
            %   >> [rlu_to_ustep, u_to_rlu, ulen] = projaxes_to_rlu (proj)
            %   >> [rlu_to_ustep, u_to_rlu, ulen] = projaxes_to_rlu (proj, ustep)
            %
            % The projection axes are three vectors that may or may not be orthononal
            % which are used to create the bins in an sqw object. The bin sizes are in ustep
            %
            % Input:
            % ------
            %   proj    projaxes object containg information about projection axes
            %          (type >> help projaxes for details)
            %   ustep   Row vector giving step sizes along the projection axes as multiple
            %           of the projection axes (e.g. [0.05,0.05,0.025]
            %           Default if not given: [1,1,1] i.e. unit step
            %
            % Output:
            % -------
            %   rlu_to_ustep   Matrix to convert components of a vector expressed
            %                  in r.l.u. to the components along the projection axes
            %                  u1,u2,u3, as multiples of the step size along those axes
            %                       Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
            %
            %   u_to_rlu       The projection axis vectors u_1, u_2, u_3 in reciprocal
            %                  lattice vectors. The ith column is u_i in r.l.u. i.e.
            %                       ui = u_to_rlu(:,i)
            %
            %   ulen            Row vector of lengths of ui in Ang^-1
            %
            %
            % Original author: T.G.Perring
            %
            [rlu_to_ustep, u_to_rlu, ulen] = projaxes_to_rlu_(proj,ustep);
        end
        function [u,v]=uv_from_rlu(obj,u_to_rlu,ulen)
            % Extract initial u/v vectors, defining the plane in hkl from
            % lattice parameters and the matrix converting vectors in
            % crystal Cartesian coordinate system into rlu.
            %
            % partially inverting projaxes_to_rlu function of projaxes class
            % as only orthogonal to u part of the v-vector can be recovered
            %
            % Inputs:
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
            
            %Uses class properties:
            % alatt -- lattice parameters. [1x3]-vector of positive numbers
            %          describing lattice cell size. (In A-units)
            % angdeg-- vector 3 angles describing the angles between lattice cell.
            %          Expressed in degree
            
            
            [u,v] = uv_from_rlu_mat_(obj,u_to_rlu,ulen);
        end
        
    end
end