classdef line_proj < line_proj_interface
    %  Class defines coordinate transformations necessary to make Horace cuts
    %  in crystal coordinate system (orthogonal or non-orthogonal)
    %
    %  Defines coordinate transformations, used by cut_sqw when making
    %  Horace cuts
    %
    %  Object that defines the ortholinear projection operations
    %
    % Input accepting the structure:
    %   >> proj = line_proj(proj_struct)
    %             where proj_struct is the
    %             structure, containing any fields, with names, equal any
    %             public fields of the line_proj class.
    %
    % As a standard serializable class, class line_proj accepts full set of
    % positional and key-value parameters, which constitute its properties
    %
    % Argument input:
    %   >> proj = line_proj(u,v)
    %   >> proj = line_proj(u,v,w)
    %
    %   Full positional arguments input (can be truncated at any argument
    %   leaving other arguments default):
    %   >> proj = line_proj(u,v,w,nonorthogonal,type,alatt,angdeg,...
    %                        offset,label,title,lab1,lab2,lab3,lab4)
    %
    %   plus any of other arguments, provided as key-value pair e.g.:
    %
    %   >> proj = line_proj(...,'nonorthogonal',nonorthogonal,..)
    %   >> proj = line_proj(...,'type',type,...)
    %   >> proj = line_proj(...,'offset',offset,...)
    %   >> proj = line_proj(...,'label',labelcellstr,...)
    %   >> proj = line_proj(...,'lab1',labelstr,...)
    %                   :
    %   >> proj = line_proj(...,'lab4',labelstr,...)
    %
    % Minimal fully functional form:
    %   >> proj =  line_proj(u,v,'alatt',lat_param,'angdeg',lattice_angles_in_degrees);
    %
    %IMPORTANT:
    % if you want to use line_proj as input for the cut algorithm, it needs
    % at least two input parameters u and v, (or their default values) as
    % the lattice parameters for cut will be taken from sqw object
    % if not provided with projection.
    %
    % For independent usage u,v and lattice parameters (minimal fully functional
    % form) needs to be specified. Any other parameters have their reasonable
    % defaults and need to change only if change in their default values
    % is required.
    %
    % Input:
    % ------
    % Projection axes are defined by two vectors in reciprocal space, together
    % with optional arguments that control normalisation, orthogonality, labels etc.
    % The input can be a data structure with field-names and contents chosen from
    % the arguments below, or alternatively the arguments
    %
    % Required arguments:
    %   u    [1x3] Vector of first axis  (r.l.u.) defining cut plane and projection axes
    %   v    [1x3] Vector of second axis (r.l.u.) defining cut plane and projection axes
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
    % Also accepts these and aProjectionBase properties as set of key-values
    % pairs following standard serializable class constructor agreements.
    %
    % NOTE:
    % constructor does not accept legacy ub_inv_legacy matrix, even if it is specified
    % in the list of saveable properties.
    %
    properties(Dependent)
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type;  % Character string length 3 defining normalisation. each character being 'a','r' or 'p' e.g. 'rrp'
        nonorthogonal; % Indicates if non-orthogonal axes are permitted (if true)
    end
    properties(Hidden)
        % return set of vectors, which define primary lattice cell if
        % coordinate transformation is non-orthogonal
        unit_cell;

        % Developers option. Use old (v3 and below) sub-algorithm in
        % ortho-ortho transformation to identify cells which may contribute
        % to a cut. Correct value is chosen on basis of performance analysis
        convert_targ_to_source=true;
        % property used by bragg_positions routine for realigning already
        %  aligned old version sqw files. If set to true, existing legacy
        %  alignment matrix is ignored and cut is performed from
        %  misaligned source file
        ignore_legacy_alignment = false;
    end

    properties(Access=protected)
        u_ = [1,0,0]
        v_ = [0,1,0]
        w_ = []
        nonorthogonal_=false
        type_='ppr'
        % if requested type has been set directly or has default values
        type_is_defined_explicitly_ = false;
        %
        % Caches, containing main matrices, used in the transformation
        % this projection defines
        q_to_img_cache_ = [];
        q_offset_cache_ = [];
        % Internal property, which specifies if alignment algorithm has
        % been applied to pixels. These two transformations are
        % equivalent, so if it was, pix_to_img transformation
        % should use proj alignment rather then pix alignment provided to
        % transformation
        proj_aligned_ = false;
    end
    %======================================================================
    methods
        %------------------------------------------------------------------
        % Interfaces:
        function obj=line_proj(varargin)
            obj = obj@line_proj_interface();
            obj.label = {'\zeta','\xi','\eta','E'};
            % try to use specific range-range identification algorithm,
            % suitable for ortho-ortho transformation
            obj.do_generic = false;
            if nargin==0 % return defaults, which describe unit transformation from
                % Crystal Cartesian (pixels) to Crystal Cartesian (image)
                obj = obj.init([1,0,0],[0,1,0],[],'type','ppr');
            else
                obj = obj.init(varargin{:});
            end
        end
        %
        function obj = init(obj,varargin)
            % initialization routine taking any parameters non-default
            % constructor would take and initiating internal state of the
            % line_proj class.
            %
            narg = numel(varargin);
            if narg == 0
                return
            end
            obj = init_(obj,narg,varargin{:});
        end
        %-----------------------------------------------------------------
        %-----------------------------------------------------------------
        function u = get.u(obj)
            u = obj.u_;
        end
        function obj = set.u(obj,val)
            obj.u_ = obj.check_and_brush3vector(val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function v = get.v(obj)
            v = obj.v_;
        end
        function obj = set.v(obj,val)
            obj.v_ = obj.check_and_brush3vector(val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end

        end
        %
        function w = get.w(obj)
            w = obj.w_;
        end
        function obj = set.w(obj,val)
            if isempty(val)
                obj.w_ = [];
                return;
            end
            obj.w_ = obj.check_and_brush3vector(val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        function cell = get.unit_cell(obj)
            cell = get_unit_cell_(obj);
        end
        %
        function no=get.nonorthogonal(obj)
            no = obj.nonorthogonal_;
        end
        function obj=set.nonorthogonal(obj,val)
            obj = check_and_set_nonorthogonal_(obj,val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function typ=get.type(obj)
            typ = obj.type_;
        end
        function obj=set.type(obj,type)
            obj = check_and_set_type_(obj,type);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        %------------------------------------------------------------------
        % set u,v & w simultaneously
        obj = set_directions(obj, u, v, w, offset)
        %------------------------------------------------------------------
        % return ubmat_proj which is siter projection to line_proj
        proj = get_ubmat_proj(obj);
    end
    methods
        %
    end
    %======================================================================
    % TRANSFORMATIONS:
    methods
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        % and overloads for specific methods
        %------------------------------------------------------------------
        %
        %
        function pix_target = from_this_to_targ_coord(obj,pix_origin,varargin)
            % Converts from current to target projection coordinate system.
            %
            % Overloaded to optimize a line_proj to line_proj
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
                pix_target = from_this_to_targ_coord@aProjectionBase(...
                    obj,pix_origin,varargin{:});
            else
                pix_target = do_ortho_ortho_transformation_(...
                    obj,pix_origin,varargin{:});
            end
        end
        %
        function [q_to_img,shift,img_scales,obj]=get_pix_img_transformation(obj,ndim,varargin)
            % Return the transformation, necessary for conversion from pix
            % to image coordinate system and vice-versa.
            %
            % Input:
            % ndim -- number of dimensions in the pixels coordinate array
            %         (3 or 4). Depending on this number the routine
            %         returns 3D or 4D transformation matrix
            % Optional:
            % pix_transf_info
            %      -- PixelDataBase or pix_metadata class, providing the
            %         information about pixel alignment. If present and
            %         pixels are misaligned, contains additional rotation
            %         matrix, used for aligning the pixels data into
            %         Crystal Cartesian coordinate system
            % Outputs:
            % q_to_img -- [ndim x ndim] matrix used to transform pixels
            %             in Crystal Cartesian coordinate system to image
            %             coordinate system
            % shift    -- [1 x ndim] array of the offsets of image coordinates
            %             expressed in Crystal Cartesian coordinate system
            % img_scales
            %          -- [1 x ndim] array of scales along the image axes
            %             used in the transformation
            %
            [q_to_img,shift,img_scales,obj]=get_pix_img_transformation_(obj,ndim,varargin{:});
        end
    end
    %======================================================================
    % Related Axes and Alignment
    methods
        function axes_bl = copy_proj_defined_properties_to_axes(obj,axes_bl)
            % copy the properties, which are normally defined on projection
            % into the axes block provided as input
            axes_bl = copy_proj_defined_properties_to_axes@aProjectionBase(obj,axes_bl);
            [~,~,scales]  = obj.get_pix_img_transformation(3);
            axes_bl.img_scales  = scales;
            axes_bl.hkle_axes_directions = obj.u_to_rlu;
            %
        end
        %
        function [obj,axes] = align_proj(obj,alignment_info,varargin)
            % Apply crystal alignment information to the projection
            % and optionally, to the axes block provided as input
            % Inputs:
            % obj -- initialized instance of the projection info
            % alignment_info
            %     -- crystal_alignment_info class, containing information
            %        about new alignment
            % Optional:
            % axes -- line_axes class, containing information about
            %         axes block, related to this projection.
            % Returns:
            % obj  -- the projection class, modified by information,
            %         containing in the alignment info block
            % optional
            % axes -- the input line_axes, modified according to the
            %         realigned projection.
            [obj,axes] = align_proj_(obj,alignment_info,varargin{:});
            [obj,axes] = align_proj@aProjectionBase(obj,alignment_info,axes);
            obj.proj_aligned_ = true;
        end
    end
    %======================================================================
    methods(Access = protected)
        function is = get_proj_aligned(obj)
            is = obj.proj_aligned_;
        end
        function obj = set_proj_aligned(obj,val)
            obj.proj_aligned_ = logical(val);
        end
        function obj = set_img_scales(varargin)
            error('HORACE:line_proj:invalid_argument', ...
                'line_proj scaling is defined by specifying values for "type" property')
        end
        %------------------------------------------------------------------
        function   contrib_ind= get_contrib_cell_ind(obj,...
                cur_axes_block,targ_proj,targ_axes_block)
            % get indexes of cells which may contributing into the cut.
            %
            if obj.convert_targ_to_source && isa(targ_proj,class(obj))
                contrib_ind= get_contrib_orthocell_ind_(obj,...
                    cur_axes_block,targ_axes_block);
            else
                contrib_ind= get_contrib_cell_ind@aProjectionBase(obj,...
                    cur_axes_block,targ_proj,targ_axes_block);
            end
        end
        %
        function obj = check_and_set_targ_proj(obj,val)
            % overloaded setter for target proj.
            % Input:
            % val -- target projection
            %
            % sets up target projection as the parent method.
            % In addition:
            % sets up matrices, necessary for optimized transformations
            % if both projections are line_proj
            %
            obj = check_and_set_targ_proj@aProjectionBase(obj,val);
            if isa(obj.targ_proj_,'line_proj') && ~obj.disable_srce_to_targ_optimization
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
            obj = check_and_set_do_generic@aProjectionBase(obj,val);
            if obj.do_generic_
                obj.ortho_ortho_transf_mat_ = [];
                obj.ortho_ortho_offset_ = [];
            end
        end
        %
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    properties(Constant, Access=private)
        fields_to_save_ = {'u';'v';'w';'nonorthogonal';'type';
            'proj_aligned'}
        % still need to recover if received 'ub_inv_legacy'
    end
    methods
        function ver  = classVersion(~)
            ver = 7;
        end
        function  flds = saveableFields(obj)
            flds = saveableFields@aProjectionBase(obj);
            flds = [flds(:);obj.fields_to_save_(:)];
        end
        %------------------------------------------------------------------
        % check interdependent projection arguments
        function wout = check_combo_arg (w)
            % Check validity of interdependent fields
            %
            %   >> obj = check_combo_arg(w)
            %
            % Throws HORACE:line_proj:invalid_argument with the message
            % suggesting the reason for failure if the inputs are incorrect
            % w.r.t. each other.
            %
            % Sets up the internal image transformation caches.
            %
            wout = check_combo_arg_(w);
            % check arguments, possibly related to image offset (if
            % defined)
            wout = check_combo_arg@aProjectionBase(wout);
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = line_proj();
            obj = loadobj@serializable(S,obj);
        end
        %
        function proj = get_from_old_data(data_struct,header_av)
            % construct line_proj from old style data structure
            % normally stored in binary Horace files versions 3 and lower.
            %
            proj = line_proj();
            if ~exist('header_av','var')
                header_av = [];
            end
            proj = proj.from_old_struct(data_struct,header_av);
        end
    end
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs,header_av)
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain a version or the version, stored
            % in the structure does not correspond to the current version
            % of the class.
            if ~exist('header_av', 'var')
                header_av = [];
            end
            if isfield(inputs,'version') && inputs.version<7
                if strcmp(inputs.serial_name,'ortho_proj')
                    obj = line_proj();
                    inputs.serial_name = 'line_proj';
                end
            end
            obj = build_from_old_data_struct_(obj,inputs,header_av);
        end

    end
end
