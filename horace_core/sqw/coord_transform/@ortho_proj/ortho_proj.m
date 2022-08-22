classdef ortho_proj<aProjection
    %  Class defines coordinate transformations necessary to make Horace cuts
    %  in crystal coordinate system (orthogonal or non-orthogonal)
    %
    %  Defines coordinate transformations, used by cut_sqw when making
    %  Horace cuts
    %
    %  Object that defines the orhtolinear projection operations
    %
    % Input accepting the structure:
    %   >> proj = ortho_proj(proj_struct)
    %             where proj_struct is the
    %             structure, containing any fields, with names, equal any
    %             public fields of the ortho_proj class
    %
    % Argument input:
    %   >> proj = ortho_proj(u,v)
    %   >> proj = ortho_proj(u,v,w)
    %
    %   plus any of the optional arguments, provided as key-value pair:
    %
    %   >> proj = ortho_proj(...,'nonorthogonal',nonorthogonal,..)
    %   >> proj = ortho_proj(...,'type',type,...)
    %   >> proj = ortho_proj(...,'uoffset',uoffset,...)
    %   >> proj = ortho_proj(...,'label',labelcellstr,...)
    %   >> proj = ortho_proj(...,'lab1',labelstr,...)
    %                   :
    %   >> proj = ortho_proj(...,'lab4',labelstr,...)
    %
    %
    % Input:
    % ------
    % Projection axes are defined by two vectors in reciprocal space, together
    % with optional arguments that control normalisation, orthogonality, labels etc.
    % The input can be a data structure with fieldnames and contents chosen from
    % the arguments below, or alternatively the arguments
    %
    % Required arguments:
    %   u      [1x3] Vector of first axis (r.l.u.) defining cut plain and projection axes
    %   v      [1x3] Vector of second axis (r.l.u.) defining cut plain and projection axes
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
    end
    properties(Dependent,Hidden) %TODO: all this should go with new sqw design
        % Old confusing u_to_rlu matrix value
        % Matrix to convert from Crystal Cartesian (pix coordinate system)
        % to the image coordinate system (normally in rlu, except initially
        % generated sqw file, when this image is also in Crystal Cartesian)
        u_to_rlu
        % renamed offset projection property
        uoffset
        % Return the compatibility structure, which may be used as additional input to
        % data_sqw_dnd constructor
        compat_struct;
    end
    properties(Hidden)
        % Developers option. Use old (v3 and below) subalgorithm in
        % ortho-ortho transformation to identify cells which may contribute
        % to a cut. Correct value is selected from performance analysis
        use_old_cut_sub_alg=true;
    end

    properties(Access=protected)
        u_ = [1,0,0]
        v_ = [0,1,0]
        w_ = []
        nonorthogonal_=false
        type_='ppr'
        %
        % The properties used to optimize from_current_to_targ method
        % transfromation, if both current and target projections are
        % ortho_proj
        ortho_ortho_transf_mat_;
        ortho_ortho_offset_;

        % inverted ub matrix, used to support alignment as in Horace 3.xxx
        % as real ub matrix is multiplied by alginment matrix
        ub_inv_compat_ = [];
    end

    methods
        %------------------------------------------------------------------
        % Interfaces:
        %------------------------------------------------------------------
        % check interdependent projection arguments
        wout = check_combo_arg (w)
        % set u,v & w simulataniously
        obj = set_axes (obj, u, v, w)
        %------------------------------------------------------------------
        function [proj,remains]=ortho_proj(varargin)
            proj = proj@aProjection();
            proj.label = {'\zeta','\xi','\eta','E'};
            if nargin==0 % return defaults, which describe unit transformation from
                % Crystal Cartesian (pixels) to Crystal Cartesian (image)
                u_to_rlu =eye(3)/(2*pi);
                [ul,vl,~,type]=proj.uv_from_data_rot(u_to_rlu,[1,1,1]);
                proj = proj.init(ul,vl,[],'type',type);
            else
                [proj,remains] = proj.init(varargin{:});
            end
        end
        %
        function [obj,remains] = init(obj,varargin)
            % initialization routine taking any parameters non-default
            % constructor would take and initiating internal state of the
            % projection class.
            %
            if nargin == 0
                return
            end
            obj.do_check_combo_arg_  = false;
            [obj,remains] = process_positional_args_(obj,varargin{:});
            [obj,remains] = init@aProjection(obj,remains{:});
            [obj,remains] = process_keyval_args_(obj,remains{:});
            obj.do_check_combo_arg_  = true;
            obj = obj.check_combo_arg();
        end
        %-----------------------------------------------------------------
        %-----------------------------------------------------------------
        function u = get.u(obj)
            u = obj.u_;
        end
        function obj = set.u(obj,val)
            obj = check_and_set_uv_(obj,'u',val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg_(obj);
            end
        end
        %
        function v = get.v(obj)
            v = obj.v_;
        end
        function obj = set.v(obj,val)
            obj = check_and_set_uv_(obj,'v',val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg_(obj);
            end

        end
        %
        function w = get.w(obj)
            w = obj.w_;
        end
        function obj = set.w(obj,val)
            obj = check_and_set_w_(obj,val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg_(obj);
            end

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
            typ = obj.type_;
        end
        function obj=set.type(obj,type)
            obj = check_and_set_type_(obj,type);
            if obj.do_check_combo_arg_
                obj = check_combo_arg_(obj);
            end

        end
        % -----------------------------------------------------------------
        % OLD sqw object interface compartibility functions
        % -----------------------------------------------------------------
        function obj = set_from_data_mat(obj,u_rot,ulen)
            % build correct projection from input u_to_rlu and ulen matrices
            % stored in sqw object ver < 4
            %
            [ur,vr,wr,tpe,nonortho]=obj.uv_from_data_rot(u_rot(1:3,1:3),ulen(1:3));

            obj.u_ = ur;
            obj.v_ = vr;
            obj.w_ = wr;
            obj.nonorthogonal_ = nonortho;
            obj = check_and_set_type_(obj,tpe);
            if obj.do_check_combo_arg_
                obj = check_combo_arg_(obj);
            end
        end
        %
        function obj = set_ub_inv_compat(obj,ub_inv)
            % Set up inverted ub matrix, used to support alignment as in
            % Horace 3.xxx where the real inverted ub matrix is multiplied
            % by alginment matrix.
            obj.ub_inv_compat_ = ub_inv;
        end
        %------------------------------------------------------------------
        % OLD from new sqw object creation interface.
        % TODO: remove when new SQW object is fully implemented
        %
        function mat = get.u_to_rlu(obj)
  %          if ~isempty(obj.ub_inv_compat_) % TODO: fudge! BUG! should be integrated in the
  %              % the changes to projection!!!!
  %              mat = obj.ub_inv_compat_;
 %           else
                [~, mat] = obj.uv_to_rot();
 %           end
            mat = [mat,[0;0;0];[0,0,0,1]];
        end
        function off = get.uoffset(obj)
            off = obj.offset';
        end
        function str= get.compat_struct(obj)
            str = struct();
            flds = obj.data_sqw_dnd_export_list;
            for i=1:numel(flds)
                str.(flds{i}) = obj.(flds{i});
            end
        end
        %------------------------------------------------------------------
        % Particular implementation of aProjection abstract interface
        % and oveloads for speficic methods
        %------------------------------------------------------------------
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
        function ax_bl = get_proj_axes_block(obj,default_binning_ranges,req_binning_ranges)
            % return the axes block, corresponding to this projection class.
            ax_bl = get_proj_axes_block@aProjection(obj,default_binning_ranges,req_binning_ranges);
            [~,~, ulen] = obj.uv_to_rot([1,1,1]);
            ax_bl.ulen  = ulen;
            % TODO, delete this, mutate axes_block
            ax_bl.axis_caption=an_axis_caption();
            % TODO:  this should go. The projection will keep this property
            % for itself unless it is specific axes block?
            ax_bl.nonorthogonal = obj.nonorthogonal;
        end
        %
        function pix_target = from_this_to_targ_coord(obj,pix_origin,varargin)
            % Converts from current to target projection coordinate system.
            %
            % Overloaded to optimize a ortho_proj to ortho_proj
            % transformation.
            %
            % Inputs:
            % obj       -- current projection, describing the system of
            %              coordinates where the input pixels vector is
            %              expressed in. The target projection property value
            %              has to be set up on this object
            % pix_origin   4xNpix vector of pixels coordinates expressed in
            %              the coordinate system, defined by current
            %              projection
            %Outputs:
            % pix_target -- 4xNpix vector of the pixels coordinates in the
            %               coordinate system, defined by the target
            %               projection.
            %
            if isempty(obj.ortho_ortho_transf_mat_)
                % use generic projection transformation
                pix_target = from_this_to_targ_coord@aProjection(...
                    obj,pix_origin,varargin{:});
            else
                pix_target = do_ortho_ortho_transformation_(...
                    obj,pix_origin,varargin{:});
            end
        end
        %------------------------------------------------------------------
        function  flds = saveableFields(obj)
            flds = saveableFields@aProjection(obj);
            flds = [flds(:);obj.fields_to_save_(:)];
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
        function lst = data_sqw_dnd_export_list()
            % TODO: temporarty method, which define the values to be
            % extracted from projection to convert to old style data_sqw_dnd
            % class. New data_sqw_dnd class will contain the whole projection
            lst = {'u_to_rlu','nonorthogonal','alatt','angdeg','uoffset','label'};
        end

        function proj = get_from_old_data(data_struct,header_av)
            % construct ortho_proj from old style data structure
            % normally stored in binary
            % Horace files versions 3 and lower.
            if nargin == 1
                header_av = [];
            end
            proj = build_from_old_data_struct_(data_struct,header_av);
        end
    end
    methods(Access = protected)
        function is = check_validity(obj)
            % overload this property to verify validity of interdependent
            % properties
            is = obj.isvalid_;
        end
        %------------------------------------------------------------------
        %
        function   contrib_ind= get_contrib_cell_ind(obj,...
                cur_axes_block,targ_proj,targ_axes_block)
            % get indexes of cells which may contributing into the cut.
            %
            if isempty(obj.ortho_ortho_transf_mat_)
                contrib_ind= get_contrib_cell_ind@aProjection(obj,...
                    cur_axes_block,targ_proj,targ_axes_block);
            elseif obj.use_old_cut_sub_alg
                contrib_ind= get_contrib_orthocell_ind_(obj,...
                    cur_axes_block,targ_axes_block);
            else
                contrib_ind= get_contrib_cell_ind@aProjection(obj,...
                    cur_axes_block,targ_proj,targ_axes_block);
            end
        end
        %
        function obj = check_and_set_targ_proj(obj,val)
            % overloadaed setter for target proj.
            % Input:
            % val -- target projection
            %
            % sets up target projection as the parrent method.
            % In addition:
            % sets up matrices, necessary for optimized transformations
            % if both projections are ortho_proj
            %
            obj = check_and_set_targ_proj@aProjection(obj,val);
            if isa(obj.targ_proj_,'ortho_proj') && ~obj.do_generic
                obj = set_ortho_ortho_transf_(obj);
            else
                obj.ortho_ortho_transf_mat_ = [];
                obj.ortho_ortho_offset_ = [];
            end
        end
        %
        function obj = check_and_set_do_generic(obj,val)
            % Overloaded internal setter for do_generic method.
            % Clears specific transformation matrices if do_generic
            % is false.
            obj = check_and_set_do_generic@aProjection(obj,val);
            if obj.do_generic_
                obj.ortho_ortho_transf_mat_ = [];
                obj.ortho_ortho_offset_ = [];
            end
        end
        %
        function [rot_to_img,shift]=get_pix_img_transformation(obj,ndim,varargin)
            % Return the transformation, necessary for conversion from pix
            % to image coordinate system and vise-versa if the projaxes is
            % defined
            % Input:
            % ndim -- number of dimensions in the pixels coordinate array
            %         (3 or 4). Depending on this number the routine
            %         returns 3D or 4D transformation matrix
            %
            rlu_to_ustep = projaxes_to_rlu_(obj, [1,1,1]);
            if isempty(obj.ub_inv_compat_)
                b_mat  = bmatrix(obj.alatt, obj.angdeg);
                rot_to_img = rlu_to_ustep/b_mat;
                rlu_to_u  = b_mat;
            else
                u_to_rlu_ = obj.ub_inv_compat_;
                rot_to_img = rlu_to_ustep*u_to_rlu_;
                rlu_to_u = inv(u_to_rlu_);
            end
            %
            if ndim==4
                shift  = obj.offset;
                rlu_to_u  = [rlu_to_u,[0;0;0];[0,0,0,1]];
                rot_to_img = [rot_to_img,[0;0;0];[0,0,0,1]];
            elseif ndim == 3
                shift  = obj.offset(1:3);
            else
                error('HORACE:orhto_proj:invalid_argument',...
                    'The ndim input may be 3 or 4  actually it is: %s',...
                    evalc('disp(ndim)'));
            end
            if nargin == 2
                % convert shift, expressed in hkl into crystal Cartesian
                shift = rlu_to_u *shift';
            else % do not convert anything
            end
        end
        %
        function  [rlu_to_ustep, u_rot, ulen] = uv_to_rot(proj,ustep)
            % Determine the matrices partially used for conversion
            % to/from image coordinate system from/to Crystal Cartesian
            % (PixelData) coordinate system.
            %
            %   >> [rlu_to_ustep, u_rot, ulen] = uv_to_rot(proj)
            %   >> [rlu_to_ustep, u_rot, ulen] = uv_to_rot(proj, ustep)
            %
            % The projection axes are three vectors that may or may not be orthogonal
            % which are used to create the bins in an sqw object. The bin sizes are in ustep
            %
            % Input:
            % ------
            %   proj    projaxes object containing the information about projection axes
            %           (u,v,[w])
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
            %   u_rot        The projection axis vectors u_1, u_2, u_3 in reciprocal
            %                lattice vectors. The ith column is u_i in r.l.u. i.e.
            %                       ui = u_to_rlu(:,i)
            %
            %   ulen            Row vector of lengths of ui in Ang^-1
            %
            %
            % Original author: T.G.Perring
            %
            if nargin==1
                ustep = [1,1,1];
            end
            [rlu_to_ustep, u_rot, ulen] = projaxes_to_rlu_(proj,ustep);
        end
        %
        function [u,v,w,type,nonortho]=uv_from_data_rot(obj,u_rot_mat,ulen)
            % Extract initial u/v vectors, defining the plane in hkl from
            % lattice parameters and the matrix converting vectors
            % used by data_sqw_dnd class.
            %
            % partially inverting projaxes_to_rlu function of projaxes class
            % as only orthogonal to u part of the v-vector can be recovered
            %
            % Inputs:
            % u_rot_mat -- matrix forming the part of the conversion from pixel coordinate
            %          system to the image coordinate system (normally
            %          expressed in rlu), defined in old data_sqw_dnd classes
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


            [u,v,w,type,nonortho] = uv_from_rlu_mat_(obj,u_rot_mat,ulen);
        end

    end
end