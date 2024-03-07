classdef ubmat_proj<aProjectionBase
    %  Class defines coordinate transformations necessary to support legacy
    %  Horace cuts in crystal coordinate system (orthogonal or non-orthogonal)
    %
    %  Defines coordinate transformations, used by cut_sqw when making
    %  Horace cuts defined by rotation matrix
    %
    %  Object that defines the ortholinear projection operations
    %
    % Input accepting the structure:
    %   >> proj = ubmat_proj(proj_struct)
    %             where proj_struct is the
    %             structure, containing any fields, with names, equal any
    %             public fields of the line_proj class.
    %
    % As a standard serializable class, class line_proj accepts full set of
    % positional and key-value parameters, which constitute its properties
    %
    % Argument input:
    %   >> proj = ubmat_proj(u_to_rlu)
    %   >> proj = ubmat_proj(u_to_rlu,scale)
    %
    %   Full positional arguments input (can be truncated at any argument
    %   leaving other arguments default):
    %   >> proj = ubmat_proj(u_to_rlu,scale,alatt,angdeg,offset,...
    %                        label,title,lab1,lab2,lab3,lab4)
    %
    %   plus any of other arguments, provided as key-value pair e.g.:
    %
    %   >> proj = ubmat_proj(...,'offset',offset,...)
    %   >> proj = ubmat_proj(...,'label',labelcellstr,...)
    %   >> proj = ubmat_proj(...,'lab1',labelstr,...)
    %                   :
    %   >> proj = ubmat_proj(...,'lab4',labelstr,...)
    %
    % Minimal fully functional form:
    %   >> proj =  ubmat_proj(u_to_rlu,'alatt',latice_parameters,'angdeg',lattice_angles_in_degrees);
    %
    %IMPORTANT:
    % if you want to use ubmat_proj as input for the cut algorithm, it needs
    % at least one input parameter u_to_rlu, (or its default value) as
    % the lattice parameters for cut will be taken from sqw object
    % if not provided with projection.
    %
    % For independent usage u_to_rlu and lattice parameters (minimal fully
    % functional form) needs to be specified. Any other parameters have 
    % their reasonable defaults and need to change only if change in their default values
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
    %   u_to_rlu
    %
    %
    % Also accepts these and aProjectionBase properties as set of key-values
    % pairs following standard serializable class constructor agreements.
    %
    % NOTE:
    % constructor does not accept legacy ub_inv_legacy matrix, even if it is specified
    % in the list of saveable properties.
    %
    properties(Dependent)
        % Matrix to convert from image coordinate system to hklE coordinate
        % system (in rlu or hkle -- both are the same, two different
        % name schemes are used). Should be rotation matrix
        u_to_rlu
        % scaling factors used in transformation from pix to image
        % coordinate system.
        img_scales % 
                %
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type;  % Character string which defines normalization and left
        % for compartibility with line_proj
        nonorthogonal; % Indicates if non-orthogonal axes are used (if true)
        %
    end
    properties(Dependent,Hidden)
        % Old confusing u_to_rlu matrix value
        %

        % Three properties below are responsible for support of old binary
        % file format and legacy alignment
        %
        % LEGACY PROPERTY: (used for saving data in old file format)
        % Return the compatibility structure, which may be used as
        % additional input to data_sqw_dnd constructor
        compat_struct;

 
        % return set of vectors, which define primary lattice cell if
        % coordinate transformation is non-orthogonal
        unit_cell;
        ulen       % old interface
    end
    properties(Hidden)
        % Developers option. Use old (v3 and below) sub-algorithm in
        % ortho-ortho transformation to identify cells which may contribute
        % to a cut. Correct value is chosen on basis of performance analysis
        convert_targ_to_source=true;
    end

    properties(Access=protected)
        u_to_rlu_ = eye(3);
        %
        % The properties used to optimize from_current_to_targ method
        % transformation, if both current and target projections are
        % line_proj
        ortho_ortho_transf_mat_;
        ortho_ortho_offset_;

        % Caches, containing main matrices, used in the transformation
        % this projection defines
        q_to_img_cache_ = [];
        q_offset_cache_ = [];
        ulen_cache_     = [];
        %
        uvw_cache_      = eye(3);
    end
    %======================================================================
    methods
        %------------------------------------------------------------------
        % Interfaces:
        function obj=ubmat_proj(varargin)
            obj = obj@aProjectionBase();
            obj.label = {'\zeta','\xi','\eta','E'};
            % try to use specific range-range identification algorithm,
            % suitable for ortho-ortho transformation
            obj.do_generic = false;
            if nargin==0 % return defaults, which describe unit transformation from
                % Crystal Cartesian (pixels) to Crystal Cartesian (image)
                obj = obj.init(eye(4));
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
            u = obj.uvw_cache_();
        end
        %
        function v = get.v(obj)
            v = obj.v_;
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
        function ul = get.img_scales(obj)
            if isempty(obj.ulen_cache_)
                ul = ones(1,4);
            else
                ul = obj.ulen_cache_;
            end
        end
        %------------------------------------------------------------------
        % set u,v & w simultaneously
        obj = set_axes (obj, u, v, w, offset)
        %------------------------------------------------------------------
    end
    %======================================================================
    % TRANSFORMATIONS:
    methods
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        % and overloads for specific methods
        %------------------------------------------------------------------
        function pix_hkl = transform_img_to_hkl(obj,img_coord,varargin)
            % Converts from image coordinate system to hkl coordinate
            % system
            %
            % Should be overloaded to optimize for a particular case to
            % improve efficiency.
            % Inputs:
            % obj       -- current projection, describing the system of
            %              coordinates where the input pixels vector is
            %              expressed in. The target projection has to be
            %              set up
            %
            % pix_origin   4xNpix or 3xNpix vector of pixels coordinates
            %              expressed in the coordinate system, defined by
            %              this projection
            % Ouput:
            % pix_targ -- 4xNpix or 3xNpix array of pixel coordinates in
            %             hkl (physical) coordinate system (4-th
            %             coordinate, if requested, is the energy transfer)
            if obj.disable_srce_to_targ_optimization
                pix_hkl = transform_img_to_hkl@aProjectionBase(obj,img_coord,varargin{:});
            else
                pix_hkl = transform_img_to_hkl_(obj,img_coord,varargin{:});
            end
        end

        function pix_transformed = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in crystal Cartesian coordinate systems
            % into image coordinate system
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system
            %             or instance of PixelDatBase class containing this
            %             information.
            % Returns:
            % pix_transformed -- the pixels transformed into coordinate
            %             system, related to image. (hkl system here)
            %
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
            % pix_cc --  pixels expressed in Crystal Cartesian coordinate
            %            system
            %
            pix_cc = transform_img_to_pix_(obj,pix_hkl);
        end
        %
        function [pix_hkl,en] = transform_pix_to_hkl(obj,pix_coord,varargin)
            % Converts from pixel coordinate system (Crystal Cartesian)
            % to hkl coordinate system.
            %
            % Overloaded generic method to support legacy alignment
            % appropriate for line_proj only.
            %
            % Inputs:
            % obj       -- current projection, describing the system of
            %              coordinates where the input pixels vector is
            %              expressed in.
            %
            % pix_coord -- 4xNpix or 3xNpix vector of pixels coordinates
            %              expressed in the coordinate system, defined by
            %              this projection
            %
            % Output:
            % pix_hkl  -- 4xNpix or 3xNpix array of pixel coordinates in
            %             hkl (physical) coordinate system (4-th
            %             coordinate, if requested, is the energy transfer)
            [pix_hkl,en] = transform_pix_to_hkl_(obj,pix_coord,varargin{:});
            if nargout == 1
                pix_hkl = [pix_hkl;en];
            end
        end
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

        %------------------------------------------------------------------
        function mat = get.u_to_rlu(obj)
            % get old u_to_rlu transformation matrix from current
            % transformation matrix. Used in legacy code and axes captions
            %
            %
            % u_to_rlu defines the transformation from coordinates in
            % image coordinate system to pixels in hkl(dE) (rlu) coordinate
            % system
            %
            mat = get_u_to_rlu_mat(obj);
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

        function  mat = get_u_to_rlu_mat(obj)
            % u_to_rlu defines the transformation from coordinates in
            % image coordinate system to coordinates in hkl(dE) (rlu) coordinate
            % system
            %
            mat = inv(obj.get_pix_img_transformation(4)*obj.bmatrix(4));
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
    methods(Static)
        function lst = data_sqw_dnd_export_list()
            % Method, which define the values to be extracted from projection
            % to convert to old style data_sqw_dnd class.
            % New data_sqw_dnd class (rather dnd class) contains the whole
            % projection, so this method is left for compatibility with
            % old Horace
            lst = {'u_to_rlu','nonorthogonal','alatt','angdeg','uoffset','label'};
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    properties(Constant, Access=private)
        fields_to_save_ = {'u_to_rlu'}
    end
    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(obj)
            flds = saveableFields@aProjectionBase(obj);
            flds = [obj.fields_to_save_(:);flds(:)];
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
        %
        function proj = get_from_old_data(data_struct,header_av)
            % construct line_proj from old style data structure
            % normally stored in binary Horace files versions 3 and lower.
            %
            proj = ubmat_proj();
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
                    obj = ubmat_proj();
                    inputs.serial_name = 'line_proj';
                end
            end
            obj = build_from_old_data_struct_(obj,inputs,header_av);
        end
    end
end
