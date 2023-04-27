classdef aProjectionBase < serializable
    %  Abstract class, defining interface and common properties used for
    %  transforming pixels from crystal Cartesian
    %  to the coordinate system defined by an sqw image (dnd-object)
    %  and vice-versa and used by cut, symmetrisation and gen_sqw algorithms
    %  to make appropriate coordinate transformations.
    %
    %  Lattice parameters: (User should not be setting them as cut
    %               algorithm resets their value before the cut taking it
    %               from other places of the sqw object)
    %
    %   alatt       3-element vector, containing lattice parameters
    %   angdeg      3-element vector, containing lattice angles
    %
    %
    %   Other generic properties (user may want or need to set them to modify the
    %              projection behaviour)
    %
    %   offset     Row or column vector of offset of origin of a projection axes (rlu)
    %

    properties(Dependent)
        % Lattice parameters are important in any transformation from Crystal
        % Cartesian (pixels) to image coordinate system but are hidden as
        % user is not requested to set these properties -- cut algorithm
        % would set their values from their permanent and unique place in
        % an sqw object. These parameters are the only the source of the
        % lattice for dnd object when cut from dnd object is made
        alatt        % the lattice parameters
        %
        angdeg       % angles between the lattice edges
        %
        offset; % Offset of origin of the projection in r.l.u.
        %         and energy ie. [h; k; l; en] [row vector]
        %---------------------------------
        label % the method which allows user to change labels present on a
        %      cut
        %      This is transient property, which would be carried out to
        %      and stored in the AxesBlockBase. If you need to modify the
        %      labels on the final cut, you would work rather with the
        %      axes block, but here you may request changed labels when the
        %      projection is provided as input for a cut
        %
        %
        title % this method would allow change cut title if non-empty value
        %     % is provided to the projection, which defines title
    end
    properties(Dependent,Hidden)
        % Internal properties, used by algorithms and better not to be
        % exposed to users
        %
        targ_proj;   % the target projection, used by cut to transform from
        %              source to target coordinate system
        %
        % Old confusing u_to_rlu matrix value
        %
        % Matrix to convert from Crystal Cartesian (pix coordinate system)
        % to the image coordinate system (normally in rlu, except initially
        % generated sqw file, when this image is also in Crystal Cartesian)
        %
        u_to_rlu
        %------------------------------------------------------------------
        % DEVELOPERS or FINE-TUNNING properties
        %------------------------------------------------------------------
        % property mainly used in testing. If set to true,
        % the class will always use generic projection transformation
        % instead of may be optimized transformation, specific for
        % particular projection-projection pair of transformations,
        % optimized for specific projection-projection pair of classes
        do_generic;
        % testing property. Normaly transformation from source to target
        % coordinate system in cut can be optimized as each transformation
        % is described by transformation matrices and the final
        % transformation is the production of all these matrices.
        % if the property set to true, the transformation performed in two
        % steps, namely tranforming from image to pixel coordinate system
        % and then from pixel to other image coordinate system.
        disable_srce_to_targ_optimization
        % check if a projection should use 3D transformation assuming that
        % energy axis is orthogonal to q-axes, which is much more efficient
        % then doing full 4D transformation, where projection may be
        % performed in full 4D space and a cut may be directed in q-dE
        % direction. The majority of physical cases use do_3D_transformation
        % true, though testing or the projection used to identify position
        % of q-dE point in q-dE space may set this property to false.
        do_3D_transformation;
        % Direct access to different parts of 4-component label celarray.
        % sets up appropriate element of such array. Do not have a getter.
        % Do retrieve label as a whole.
        lab1;
        lab2;
        lab3;
        lab4;
        % returns true if lattice parameters have been set up
        alatt_defined
        % returns true if lattice angles have been set up
        angdeg_defined
    end

    properties(Constant, Access=protected)
        % minimal value of a vector norm e.g. how close couple of unit vectors
        % should be to be considered parallel. u*v are orthogonal if u*v'<tol
        % or they are parallel if the length of their vector product
        % is the vector that can be considered a null vector
        % (e.g. abs([9.e-13,0,0,0]) will be treated as [0,0,0,0]
        tol_=1e-12;
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        alatt_ = [2*pi,2*pi,2*pi]; %unit-sized lattice vector
        angdeg_= [90,90,90];
        % true if both alatt and angdeg have been correctly set-up
        lattice_defined_= [false,false];
        %------------------------------------
        %  u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        offset_  = [0,0,0,0] %Offset of origin of projection axes in image units
        % e.g. r.l.u. and energy [h; k; l; en] [row vector]
        %
        label_  = {'Q_h','Q_k','Q_l','En'};
        title_ ='';
        %
        % holds target projection used in cuts.
        targ_proj_;
        %------------------------------------------------------------------
        % Developers options:
        %
        % if true, disable optimized transformation over
        % specific pairs of the projection types if such optimization
        % is available
        do_generic_ = true;
        % if true, disables optimization of the transfornation from source
        % to target coordinate system.
        disable_srce_to_targ_optimization_ = false;
        % majority of projections have energy axis orthogonal to other
        % coordinate axes, so it is much more efficient to analyse 3D
        % transformations only.  Specific projections (and test routines)
        % which request full 4D transformation should set this property to
        % false.  It may be more reasonable to overload the correspondent
        % methods for specific projections, but 4D transformation is
        % algorithmically simpler so actively used in tests.
        do_3D_transformation_ = true;
        %------------------------------------------------------------------
    end
    %======================================================================
    % ACCESSORS AND CONSTRUCTION
    methods
        function [obj,par]=aProjectionBase(varargin)
            % aProjectionBase constructor.
            %
            % Accepts any combination (including empty) of aProjectionBase
            % class properties containing setters in the form:
            % {property_name1, value1, property_name2, value2....}
            %
            % Returns:
            %
            % obj  -- Instance of aProjectionBase class
            % par  -- if input arguments contains key-value pairs, which do
            %         not describe aProjectionBase class, the output contains
            %         cellarray of such parameters. Empty, if all inputs
            %         define the projection parameters.
            if nargin == 0
                par = {};
                return;
            end
            [obj,par] = init(obj,varargin{:});
        end
        %
        function [obj,remains] = init(obj,varargin)
            % Method normally used to initialize an empty object.
            %
            % Inputs:
            % A combination (including empty) of aProjectionBase
            % class properties containing setters in the form:
            % {pos_value2,pos_value2,pos_value3,...
            % property_name1, value1, property_name2, value2....}
            % The list of the possible properties to be available for
            % constructor are specified below (opt_par)

            % Returns:
            % obj  -- Initialized instance of aProjectionBase class
            % remains
            %      -- if input arguments contain key-value pairs which do not
            %         describe aProjectionBase class, the output contains
            %         cellarray of such parameters. Empty, if all inputs
            %         define the projection parameters.
            %

            % get list of the property names, used in initialization
            init_par = aProjectionBase.init_params;
            remains = [];
            if nargin == 0
                return;
            end
            if nargin == 1 && isstruct(varargin{1})
                obj = serializable.loadobj(varargin{1});
            else
                [obj,remains] = ...
                    set_positional_and_key_val_arguments(obj,...
                    init_par,false,varargin{:});
            end
        end
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        % accessors
        %------------------------------------------------------------------
        function alat = get.alatt(obj)
            alat = obj.get_alatt_();
        end
        function obj = set.alatt(obj,val)
            % set lattice parameters as single value, defining 3 equal
            % parameters or vector of 3 different lattice parameters
            %
            % The lattice parameters units expected to be A(Angstrom)
            %
            obj = check_and_set_alatt(obj,val);
        end
        %
        function  angdeg = get.angdeg(obj)
            angdeg = obj.get_angdeg_();
        end
        function obj = set.angdeg(obj,val)
            % set lattice parameters as single value, defining 3 equal
            % lattice angles or vector of 3 different lattice angles
            %
            % All angles are in degrees.
            %
            obj = check_and_set_andgdeg(obj,val);
        end
        %
        function lab=get.label(obj)
            lab = obj.label_;
        end
        function obj=set.label(obj,val)
            obj = check_and_set_labels_(obj,val);
        end
        %
        function uoffset = get.offset(this)
            uoffset = this.offset_;
        end
        function obj = set.offset(obj,val)
            obj = check_and_set_offset_(obj,val);
        end
        %
        function tl = get.title(obj)
            tl = obj.title_;
        end
        function obj = set.title(obj,val)
            if ~istext(val)
                error('HORACE:aProjectionBase:invalid_argument',...
                    'title should be a text string. In fact its type is %s', ...
                    class(val));
            end
            obj.title_ = val;
        end
        function mat = get.u_to_rlu(obj)
            %
            mat = get_u_to_rlu_mat(obj);
        end

        %----------------------------------------------------------------
        function obj = set.lab1(obj,val)
            obj = set_lab_component_(obj,1,val);
        end
        function obj = set.lab2(obj,val)
            obj = set_lab_component_(obj,2,val);
        end
        function obj = set.lab3(obj,val)
            obj = set_lab_component_(obj,3,val);
        end
        function obj = set.lab4(obj,val)
            obj = set_lab_component_(obj,4,val);
        end
        %----------------------------------------------------------------
        function proj = get.targ_proj(obj)
            proj = obj.get_target_proj();
        end
        function obj = set.targ_proj(obj,val)
            obj = obj.check_and_set_targ_proj(val);
        end
        %
        function gen = get.do_generic(obj)
            gen = obj.do_generic_;
        end
        function obj = set.do_generic(obj,val)
            obj = obj.check_and_set_do_generic(val);
        end
        %
        function do = get.do_3D_transformation(obj)
            do = obj.do_3D_transformation_;
        end
        function obj = set.do_3D_transformation(obj,val)
            obj.do_3D_transformation_ = logical(val);
        end
        %
        function is = get.disable_srce_to_targ_optimization(obj)
            is = obj.disable_srce_to_targ_optimization_;
        end
        function obj = set.disable_srce_to_targ_optimization(obj,val)
            obj.disable_srce_to_targ_optimization_ = logical(val);
        end
        %------------------------------------------------------------------
        function def = get.alatt_defined(obj)
            def = obj.lattice_defined_(1);
        end
        function def = get.angdeg_defined(obj)
            def = obj.lattice_defined_(2);
        end
    end
    %======================================================================
    % MAIN PROJECTION OPERATIONS
    methods
        function [bl_start,bl_size] = get_nrange(obj,npix,cur_axes_block,...
                targ_axes_block,targ_proj)
            % return the positions and the sizes of the pixels blocks
            % belonging to the cells which may contribute to the final cut.
            % The cells are defined by the projections and axes block-s,
            % provided as input.
            %
            % Generic (less efficient) implementation
            if ~exist('targ_proj','var')
                targ_proj = [];
            else
                if isa(targ_proj,class(obj))
                    targ_proj.do_generic = obj.do_generic;
                    targ_proj.disable_srce_to_targ_optimization = obj.disable_srce_to_targ_optimization;
                end

                % Assign target projection to verify if optimization is
                % available and enable if it available
                targ_proj.targ_proj = obj;
                obj.targ_proj = targ_proj;
            end
            contrib_ind= obj.get_contrib_cell_ind(...
                cur_axes_block,targ_proj,targ_axes_block);
            if isempty(contrib_ind)
                bl_start  = [];
                bl_size = [];
                return;
            end
            % Calculate pix indexes from cell indexes. Compress indexes of
            % contributing cells into bl_start:bl_start+bl_size-1 form if
            % it has not been done before.
            % Converted to form ideal for filebased access but not
            % so optimal for arrays.
            [bl_start,bl_size] = obj.convert_contrib_cell_into_pix_indexes(...
                contrib_ind,npix);
        end
        function   [may_contribND,may_contrib_dE] = may_contribute(obj, ...
                cur_axes_block, targ_proj,targ_axes_block)
            % return logical array of size of the current axes block grid
            % containing true for the cells which may contribute into
            % into cut, descrined by target projection and target axes
            % block/
            %
            % Part of get_nrange -> get_contrib_cell_ind routines
            % Inputs:
            % cur_axes_block -- the axes block for the current ND_image
            % targ_proj      -- the projection, which defines the target
            %                   coordinate system
            % targ_axes_block-- the axes block for the coordinate system,
            %                   requested by the cut
            % Output:
            % may_contribND --  logical 1D array of cur_axes_block grid numel,
            %                   containing true for cells with may
            %                   contribute to cut and false for thouse
            %                   which would not. If projection does 3D
            %                   transformation and energy axes is
            %                   orthogonal to it, size and values correspond
            %                   to 3D Q-grid.
            %                   if projection does 4D transformation,
            %                   the size and values are for 4D grid.
            % may_contrib_dE -- logical array containing possible
            %                   contribution from energy transfer cells.
            %                   empty in 4D case.

            [may_contribND,may_contrib_dE] = may_contribute_(obj,...
                cur_axes_block,targ_proj,targ_axes_block);
        end
        %
        function ax_num = projection_axes_coverage(obj,source_ax_block)
            % method defines what axes become intertangled if some
            % projection is involved.
            %
            % E.g. if source projection and target projections are ortho_proj,
            % only projection axes contribute into projection axess of each other.
            % if target projection is a spherical projection, changes to
            % one projection axis of the orthogonal source projectin would
            % contribute to all axes of the sperical projection.

            % NOTE: needs some further thinking about it.
            if isempty(obj.targ_proj_) || isa(obj,class(obj.targ_proj_))
                ax_num = source_ax_block.pax;
            else
                if obj.do_3D_transformation && ~any(source_ax_block.pax == 4)
                    ax_num = 1:3;
                else
                    ax_num = 1:4;
                end
            end
        end
        % Generic methods, which provide generic interface but should
        % normally be overloaded for specific projections for efficiency and
        % specific projection differences
        %------------------------------------------------------------------
        function [npix,s,e,pix_ok,unique_runid,pix_indx] = bin_pixels(obj, ...
                axes,pix_cand,npix,s,e,varargin)
            % Convert pixels into the coordinate system defined by the
            % projection and bin them into the coordinate system defined
            % by the axes block, specified as input.
            %
            % Inputs:
            % axes -- the instance of AxesBlockBase class defining the
            %         shape and the binning of the target coordinate system
            % pix_cand
            %      -- PixelData object or pixel data accessor from file
            %         providing access to the full pixel information, or
            %         data containing information about pixels
            %         in any format accepted by the particular projection,
            %         which does transformation from pix_to_img
            %         coordinate system
            % npix -- the array, containing the numbers of pixels
            %         contributing into each axes grid cell, calculated
            %         during the previous iteration step. zeros(size(npix))
            %         if this is the first step.
            % s    -- array, containing the accumulated signal for each
            %         axes grid cell calculated during the previous
            %         iteration step. zeros(size(npix)) if this is the
            %         first step.
            % e    -- array, containing the accumulated error for each
            %         axes grid cell calculated during the previous
            %         iteration step. zeros(size(npix)) if this is the
            %         first step.
            %
            % Outputs:
            % npix    -- the npix array
            %  The same npix, s, e arrays as inputs modified with added
            %  information from pix_candidates if npix, s, e arrays were
            %  present or axes class - shaped arrays of this information
            %  if there were no inputs.
            % Optional:
            % pix_ok -- the pixel coordinate array or
            %           PixelData object (as input pix_candidates) containing
            %           pixels contributing to the grid and sorted according
            %           to the axes block grid.
            % unique_runid -- the run-id (tags) for the runs, which
            %           contributed into the cut
            % pix_indx--indexes of the pix_ok coordinates according to the
            %           bin. If this index is requested, the pix_ok object
            %           remains unsorted according to the bins and the
            %           follow up sorting of data by the bins is expected
            %
            % Optional arguments transferred without any change to
            % AxesBlockBase.bin_pixels( ____ ) routine
            %
            % '-nomex'    -- do not use mex code even if its available
            %               (usually for testing)
            %
            % '-force_mex' -- use only mex code and fail if mex is not available
            %                (usually for testing)
            % '-force_double'
            %              -- if provided, the routine changes type of pixels
            %                 it gets on input, into double. if not, output
            %                 pixels will keep their initial type
            % -nomex and -force_mex options can not be used together.
            %

            pix_transformed = obj.transform_pix_to_img(pix_cand);
            switch(nargout)
                case(1)
                    npix=axes.bin_pixels(pix_transformed,...
                        npix,varargin{:});
                case(3)
                    [npix,s,e]=axes.bin_pixels(pix_transformed,...
                        npix,s,e,pix_cand,varargin{:});
                case(4)
                    [npix,s,e,pix_ok]=axes.bin_pixels(pix_transformed,...
                        npix,s,e,pix_cand,varargin{:});
                case(5)
                    [npix,s,e,pix_ok,unique_runid]=...
                        axes.bin_pixels(pix_transformed,...
                        npix,s,e,pix_cand,varargin{:});
                case(6)
                    [npix,s,e,pix_ok,unique_runid,pix_indx]=...
                        axes.bin_pixels(pix_transformed,...
                        npix,s,e,pix_cand,varargin{:});
                otherwise
                    error('HORACE:aProjectionBase:invalid_argument',...
                        'This function requests 1,3,4,5 or 6 output arguments');
            end
        end
        %
        function pix_target = from_this_to_targ_coord(obj,pix_origin,varargin)
            % Converts from current to target projection coordinate system.
            %
            % Should be overloaded to optimize for a particular case to
            % improve efficiency.
            % (e.g. two orthogonal projections do shift and rotation
            % as the result, so worth combining them into one operation)
            % Inputs:
            % obj       -- current projection, describing the system of
            %              coordinates where the input pixels vector is
            %              expressed in. The target projection has to be
            %              set up
            %
            % pix_origin   4xNpix vector of pixels coordinates expressed in
            %              the coordinate system, defined by current
            %              projection
            %Outputs:
            % pix_target -- 4xNpix vector of the pixels coordinates in the
            %               coordinate system, defined by the target
            %               projection.
            %
            targproj = obj.targ_proj;
            if isempty(targproj)
                error('HORACE:aProjectionBase:runtime_error',...
                    'Target projection property has to be set up to convert to target coordinate system')
            end
            pic_cc = obj.transform_img_to_pix(pix_origin,varargin{:});
            pix_target  = targproj.transform_pix_to_img(pic_cc,varargin{:});
        end
        %
        function ax_bl = get_proj_axes_block(obj,def_bin_ranges,req_bin_ranges)
            % Construct the axes block, corresponding to this projection class
            % Returns generic AxesBlockBase, built from the block ranges or the
            % binning ranges.
            %
            % Usually overloaded for specific projection and specific axes
            % block to return the particular AxesBlockBase specific for the
            % projection class.
            %
            % Inputs:
            % def_bin_ranges --
            %           cellarray of the binning ranges used as defaults
            %           if requested binning ranges are undefined or
            %           infinite. Usually it is the range of the existing
            %           axes block, transformed into the system
            %           coordinates, defined by cut projection using
            %           dnd.targ_range(targ_proj) method.
            % req_bin_ranges --
            %           cellarray of cut bin ranges, requested by user.
            %
            % Returns:
            % ax_bl -- initialized, i.e. containing defined ranges and
            %          numbers of  bins in each direction, AxesBlockBase
            %          corresponding to the projection
            cl_name = class(obj);
            cl_type = split(cl_name,'_');
            proj_class_name = [cl_type{1},'_axes'];
            ax_bl = AxesBlockBase.build_from_input_binning(...
                proj_class_name,def_bin_ranges,req_bin_ranges);
            ax_bl.label = obj.label;
            if ~isempty(obj.title)
                ax_bl.title = obj.title;
            end
        end
        %
        function targ_range = calc_pix_img_range(obj,pix_origin,varargin)
            % Calculate and return the range of pixels in target coordinate
            % system, i.e. the image coordinate system.
            %
            % Not very efficient in the generic form, but may be efficiently
            % overloaded by children. (especially in mex-mode when transformed
            % coordinates may not be stored and not occupy memory)
            %
            % Inputs:
            % pix_origin -- the [4xNpix or 3xNpix] pixel coordinates array
            %               or PixelData object
            % Returns:
            % targ_range  -- the range of the pixels, transformed to target
            %                coordinate system.
            % NOTE:
            % Need verification for non ortho_proj
            pix_transformed = obj.transform_pix_to_img(pix_origin,varargin{:});
            if isa(pix_origin, 'PixelDataBase')
                targ_range = pix_transformed.pixel_range;
            else %Input is array and we want to know its ranges
                targ_range = [min(pix_transformed,[],2),...
                    max(pix_transformed,[],2)]';
            end
        end
    end
    %======================================================================
    methods(Access = protected)
        function  alat = get_alatt_(obj)
            % overloadable alatt accessor
            alat  = obj.alatt_;
        end
        function obj = check_and_set_alatt(obj,val)
            [obj.alatt_,defined] = check_alatt_return_standard_val_(obj,val);
            obj.lattice_defined_(1) = defined;
        end
        function   proj = get_target_proj(obj)
            proj = obj.targ_proj_;
        end
        function  angdeg = get_angdeg_(obj)
            % overloadable angdeg accessor
            angdeg  = obj.angdeg_;
        end
        function obj = check_and_set_andgdeg(obj,val)
            [obj.angdeg_,defined] = check_angdeg_return_standard_val_(obj,val);
            obj.lattice_defined_(2) = defined;
        end
        %
        function obj = check_and_set_targ_proj(obj,val)
            % generic overloadable setter for target proj.
            %
            % made protected to allow overloading to enable optimization for
            % special types of projection pairs
            if ~isa(val,'aProjectionBase')
                error('HORACE:aProjectionBase:invalid_argument',...
                    ['only member of aProjectionBase family can be set up as a target projection.',...
                    ' Attempted to use: %s'],...
                    disp2str(val))
            end
            obj.targ_proj_ = val;
            obj.do_3D_transformation_ = val.do_3D_transformation;
        end
        %
        function   contrib_ind= get_contrib_cell_ind(obj,...
                cur_axes_block,targ_proj,targ_axes_block)
            % get indexes of cells which may contributing into the cut.
            % Inputs:
            % cur_axes_block -- the axes block for the current ND_image
            % targ_proj      -- the projection, which defines the target
            %                   coordinate system
            % targ_axes_block-- the axes block for the coordinate system,
            %                   requested by the cut
            % Output:
            % contrib_ind    -- either array of start_ind;
            %
            contrib_ind= get_contrib_cell_ind_(obj,...
                cur_axes_block,targ_proj,targ_axes_block);
        end
        %
        function obj = check_and_set_do_generic(obj,val)
            % setter for do_generic method
            if ~((islogical(val) || isnumeric(val)) && numel(val)==1)
                error('HORACE:aProjectionBase:invalid_argument',...
                    'you may set do_generic property into true or false state only');
            end
            obj.do_generic_ = logical(val);
        end
    end
    %
    methods(Static,Access=protected)
        %
        function [bl_start,bl_size]=convert_contrib_cell_into_pix_indexes(...
                cell_ind,npix)
            % Compress indexes of contributing cells into the form, which
            % define the indexes of pixels from PixelData dataset, namely
            % the form: bl_start:bl_start+bl_size-1, where bl_start and
            % bl_size are defined below.
            % The routine uses information about the number of pixels,
            % belonging to each cell.
            %
            % Inputs:
            % cell_ind    -- 1D array of linear indexes of cells,
            %                which may contribute into the cut, to be
            %                selected from npix array below
            % npix        -- array with each cell containing the number
            %                of pixels, contributing to a cell.
            % Outputs:
            % bl_start    -- array of the initial positions of the
            %                blocks of pixels which belong to the
            %                requested cells
            % bl_size     -- number of pixels, contributed into each
            %                block
            pix_start = [0,cumsum(npix(:)')]; % pixel location in C-indexed
            % array
            if iscell(cell_ind) % input contributing cell indexes arranged
                % in the form of cellarray, containing cell_start:cell_end
                bl_start = pix_start(cell_ind{1});
                bl_end   = pix_start(cell_ind{2}+1);
                bl_size  = bl_end-bl_start;
            else % input contributing cell indexes arranged as linear array
                % of indexes
                adjacent = cell_ind(1:end-1)+1==cell_ind(2:end);
                adjacent = [false;adjacent];
                adj_end  = [cell_ind(1:end-1)+1<cell_ind(2:end);true];

                bl_start  = pix_start(cell_ind(~adjacent));
                bl_size   = pix_start(cell_ind(adj_end)+1)-bl_start;
            end
            non_empty = bl_size~=0;
            bl_start  = bl_start(non_empty)+1; % +1 converts to Matlab indexing
            bl_size   = bl_size(non_empty);
        end
        %
        function contrib_ind=convert_3Dplus1Ind_to_4Dind_ranges(...
                bin_inside3D,en_inside)
            % Convert cell indexes calculated on 3D-q + 1D-dE
            % grid into 4D indexes on 4D lattice using assumption that
            % dE axis is orthogonal to 3 other q-axes
            % Inputs:
            % bin_inside3D -- 3D logical array, containing true
            %                 for indexes to include
            % en_inside    -- 1D logical array, containing true, for
            %                 orthogonal 1D indexes on dE lattice to include
            %                 into contributing indexes.
            %
            % Uses knowledge about linear arrangement of 4-D array of indexes
            % in memory and on disk

            q_block_size = numel(bin_inside3D);
            change = diff([false;bin_inside3D(:);false]);
            istart = find(change==1);
            if isempty(istart)
                contrib_ind = {};
                return;
            end
            iend   = find(change==-1) - 1;

            % calculate full 4D indexes from the the knowledge of the contributing dE bins,
            % 3D indexes and 4D array allocation layout
            q_stride = (0:numel(en_inside)-1)*q_block_size; % the shift of indexes for
            % every subsequent dE block shifted by q_stride
            q_stride = q_stride(en_inside); % but only contributing dE blocks matter

            n_eblocks = numel(q_stride);
            q_stride  = repmat(q_stride,numel(istart),1); % expand to every q-block

            istart = repmat(istart,1,n_eblocks)+q_stride;
            iend   = repmat(iend,1,n_eblocks)+q_stride;
            % if any blocks follow each other through 4-th dimension, we
            % want to join them together
            not_subsequent = iend(1:end-1)+1 ~= istart(2:end);
            if any(~not_subsequent)
                istart = istart([true,not_subsequent]);
                iend   = iend([not_subsequent,true]);
            end
            contrib_ind = {istart(:)',iend(:)'};
        end
        function val = check_and_brush3vector(val)
            % Helper function verifying setting 3 vector defining direction
            % and modifying it to have standard row form avoiding small values in
            % some directions when other directions are not small.
            val = check_and_brush3vector_(val);
        end

    end
    %----------------------------------------------------------------------
    %  ABSTRACT INTERFACE
    %----------------------------------------------------------------------
    methods(Abstract)
        % Transform pixels expressed in crystal Cartesian or any source
        % coordinate systems defined by projection into image coordinate system
        [pix_transformed,varargout] = transform_pix_to_img(obj,pix_cc,varargin);
        % Transform pixels expressed in image coordinate coordinate systems
        % into crystal Cartesian system or other source coordinate system,
        % defined by projection
        [pix_cc,varargout] = transform_img_to_pix(obj,pix_transformed,varargin);
    end
    methods(Abstract,Access=protected)
        % function returns u_to_rlu matrix for appropriate coordinate
        % system
        mat = get_u_to_rlu_mat(obj);
    end
    %======================================================================
    % Serializable interface
    %======================================================================
    properties(Constant,Access=protected)
        init_params = {'alatt','angdeg','offset','label','title','lab1','lab2','lab3','lab4'};
    end
    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(obj)
            flds = {'alatt','angdeg','offset','label'};
            if ~isempty(obj.title)
                flds = [flds(:);'title']';
            end
        end
    end
end
