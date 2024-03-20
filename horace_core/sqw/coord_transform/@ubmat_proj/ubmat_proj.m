classdef ubmat_proj < LineProjBase
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
    % As a standard serializable class, class ubmat_proj accepts full set of
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
    % Minimal fully functional form which has reasonable defaults:
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
        %-----------------------------------------------------------------
        % DERIVED PROPERTIES:
        u; %[1x3] Vector of first axis (r.l.u.)
        v; %[1x3] Vector of second axis (r.l.u.)
        w; %[1x3] Vector of third axis (r.l.u.) - used only if third character of type is 'p'
        type;  % Character string which defines normalization and left
        % for compatibility with line_proj
        nonorthogonal; % Indicates if non-orthogonal axes are used (if true)
        %
        %
    end
    properties(Dependent,Hidden)
        % Legacy problematic property, The problem is that if cut has
        % defines uoffset, it is offset in source image coorinate system
        % and not target coordinate system which is defined by the
        % projection. Left for compartibility with old data. Use offset
        % instead.
        uoffset  % offset expressed in image coordinate system. Old interface to img_offset
        % which is under construction. Transient property used to process
        % input parameters which converted to offset and nullified after
        % that.

        % return set of vectors, which define primary lattice cell if
        % coordinate transformation is non-orthogonal
        unit_cell;
    end
    properties(Access=protected)
        % Cached properties value, calculated from input u_to_rlu matrix
        type_  = 'rrr';
        nonorthogonal_ = false;
        uvw_cache_     = eye(4);
        % holder for matrix to convert from image coordinate system to
        % hklE coordinate system (in rlu or hkle -- both are the same, two
        % different name schemes are used)
        u_to_rlu_ = eye(4);
    end
    %======================================================================
    methods
        %------------------------------------------------------------------
        % Interfaces:
        function obj=ubmat_proj(varargin)
            obj = obj@LineProjBase();
            obj.label = {'\zeta','\xi','\eta','E'};
            if nargin>0
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
            u = obj.uvw_cache_(:,1)';
        end
        %
        function v = get.v(obj)
            v = obj.uvw_cache_(:,2)';
        end
        %
        function w = get.w(obj)
            w = obj.uvw_cache_(:,3)';
        end
        function cell = get.unit_cell(obj)
            cell = [obj.uvw_cache_,[0;0;0];[0,0,0,1]];
        end
        %
        function no=get.nonorthogonal(obj)
            no = obj.nonorthogonal_;
        end
        %
        function typ=get.type(obj)
            typ = obj.type_;
        end
        %
        function uoff = get.uoffset(obj)
            uoff = obj.uoffset_;
        end
        function obj = set.uoffset(obj,val)
            obj = obj.set_uoffset(val);
        end
        %------------------------------------------------------------------
        % return line_proj which is sister projection to ubmat_proj
        proj = get_line_proj(obj);
        function proj = get_ubmat_proj(obj)
            % return themselves
            proj = obj;
        end
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
        function  mat = get_u_to_rlu(obj)
            % u_to_rlu defines the transformation from coordinates in
            % image coordinate system to coordinates in hkl(dE) (rlu) coordinate
            % system
            %
            mat = obj.u_to_rlu_;
        end
        function obj = set_u_to_rlu(obj,val)
            %
            if all(size(val) == [3,3])
                obj.u_to_rlu_ = [val,zeros(3,1);[0,0,0,1]];
            elseif all(size(val) == [4,4])
                obj.u_to_rlu_ = val;
            else
                error('HORACE:horace3_proj_interface:invalid_argument', ...
                    'u_to_rlu matrix must be 3x3 or 4x4 matrix. Actually its size is %s', ...
                    disp2str(size(val)));
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function is = get_proj_aligned(obj)
            is = obj.proj_aligned_;
        end
        function obj = set_proj_aligned(obj,val)
            obj.proj_aligned_ = logical(val);
        end
        function obj = set_img_scales(obj,val)
            obj = set_img_scales@LineProjBase(obj,val);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj = set_uoffset(obj,val)
            if ~isnumeric(val) || numel(val)~=4
                error('HORACE:horace3_proj_interface:invalid_argument', ...
                    'uoffset has to be 4-components numeric vector. It is %s', ...
                    disp2str(val));
            end
            obj.uoffset_ = val(:)';
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(obj)
            %
            aproj_flds = saveableFields@aProjectionBase(obj);
            comp_fils = {'u_to_rlu','img_scales'};
            flds = [comp_fils(:);aproj_flds(:)];
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
            obj = ubmat_proj();
            obj = loadobj@serializable(S,obj);
        end
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
end
