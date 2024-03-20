classdef line_proj < LineProjBase
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
        % if requested type has been set directly or has default values.
        % used to determine last letter of type if w is not defined and
        % needs to be constructed from u/v
        type_is_defined_explicitly_ = false;
        %
        % Caches, containing main matrices, used in the transformation
        % this projection defines
        q_to_img_cache_ = [];
        q_offset_cache_ = [];
    end
    %======================================================================
    methods
        %------------------------------------------------------------------
        % Interfaces:
        function obj=line_proj(varargin)
            obj = obj@LineProjBase();
            obj.label = {'\zeta','\xi','\eta','E'};
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
        % return ubmat_proj which is sister projection to line_proj
        proj = get_ubmat_proj(obj);
        function proj = get_line_proj(obj)
            proj = obj;
        end
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
        end
    end
    %======================================================================
    methods(Access = protected)
        function  u_to_rlu = get_u_to_rlu(obj)
            % u_to_rlu defines the transformation from coordinates in
            % image coordinate system to coordinates in hkl(dE) (rlu) coordinate
            % system
            %
            mat = obj.get_pix_img_transformation(4)*obj.bmatrix(4);
            u_to_rlu = inv(mat);
        end
        function obj = set_u_to_rlu(varargin)
            error('HORACE:line_proj:invalid_argument', ...
                'u_to_rlu is dependent property for line_proj')
        end
        function obj = set_img_scales(varargin)
            error('HORACE:line_proj:invalid_argument', ...
                'line_proj scaling is defined by specifying values for "type" property')
        end
        %
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    properties(Constant, Access=private)
        fields_to_save_ = {'u';'v';'w';'nonorthogonal';'type'}
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
            % Regardless if we actually loading legacy data or not,
            % set this property to true, not to warn if
            S.warn_on_legacy_data = false;
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
end
