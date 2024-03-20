classdef LineProjBase < aProjectionBase
    %LINE_PROJ_BASE
    % is the parent for line_proj and ubmat_proj and also contains
    % properties, common for these two projections
    %
    % class is also responsible for providing methods for
    %converting aProjection data into HORACE3 dnd structures (data_sqw_dnd)
    %to save these data in Horace3 file format and maintain compatibility
    %with the algorithms which still have not been updated from this
    %interface. Also helps to load old data into new class structure
    %
    %
    properties(Dependent)
        % scaling factors used in transformation from pix to image
        % coordinate system.
        img_scales % the scaling factor (in A^-1)
    end
    properties(Dependent,Hidden)
        % Matrix to convert from image coordinate system to scaled. The
        % scale is defined by ulen
        % hklE coordinate system (in rlu or hkle -- both are the same, two
        % different name schemes are used)
        u_to_rlu
        % length of image coordinate system vectors expressed in hkle as
        % above)
        % coordinate system. Defined by type property
        ulen;       % old interface providing access to image scales

        % Three properties below are responsible for support of old binary
        % file format and legacy alignment
        %
        % LEGACY PROPERTY: (used for saving data in old file format)
        % Return the compatibility structure, which may be used as
        % additional input to data_sqw_dnd constructor
        compat_struct;

        % PROPERTIES superseded by u_to_rlu and not used any more but written
        % on some stages on disk so left here for loading
        %
        % LEGACY PROPERTY:
        % inverted B matrix, obtained from headers and set on
        % projection when loading realigned data from file in the new code
        % as old aligned files modify it and there are no way
        % of identifying if the file was aligned or not. Modern code
        % calculates this matrix on request using alignment matrix attached
        % to pixels.
        ub_inv_legacy;
        %
        u_to_rlu_legacy; % old u_to_rlu transformation matrix,
        % calculated by original Toby algorithm.

    end
    properties(Access=protected)
        % Holder for image scales
        img_scales_     = ones(1,4);

        % The properties used to optimize from_current_to_targ method
        % transformation, if both current and target projections are
        % line_proj_interface children classes
        ortho_ortho_transf_mat_;
        ortho_ortho_offset_;
    end
    methods(Abstract)
        proj = get_ubmat_proj(obj);
        proj = get_line_proj(obj);

    end
    methods(Abstract,Access= protected)
        u_to_rlu = get_u_to_rlu(obj)
        obj = set_u_to_rlu(obj,u_to_rlu)
    end

    methods
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
            mat = get_u_to_rlu(obj);
        end
        function obj = set.u_to_rlu(obj,val)
            obj = obj.set_u_to_rlu(val);
        end
        %
        function ul = get.img_scales(obj)
            ul = get_img_scales(obj);
        end
        function ul = get.ulen(obj)
            ul = get_ulen(obj);
        end
        function obj = set.img_scales(obj,val)
            obj = obj.set_img_scales(val);
        end
        % function obj = set.ulen(obj,val)
        %     obj = obj.set_img_scales(val);
        % end
        % OTHER NAMES
        %------------------------------------------------------------------
        function ub_inv = get.ub_inv_legacy(obj)
            ub_inv = get_u_to_rlu(obj);
        end
        function u2rlu_leg = get.u_to_rlu_legacy(obj)
            % U_to_rlu legacy is the matrix, returned by appropriate
            % operation in Horace version < 4.0
            u2rlu_leg   = get_u_to_rlu(obj);
        end

        function obj = set.ub_inv_legacy(obj,val)
            % no comprehensive checks performed here.  It is compatibility
            % with old file format. The method should be used
            % by saveobj/loadobj only. Use set_ub_inv_compat, which does all
            % necessary checks in any other case.
            obj = obj.set_u_to_rlu(val);
        end
        %------------------------------------------------------------------
        function str= get.compat_struct(obj)
            str = struct();
            flds = obj.data_sqw_dnd_export_list;
            for i=1:numel(flds)
                str.(flds{i}) = obj.(flds{i});
            end
        end
    end
    %======================================================================
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

        function  [rlu_to_u, u_to_rlu, ulen] = u_to_rlu_legacy_from_uvw(obj,u,v,w,type,nonortho)
            % Method returns transformation matrices used for pixel-image
            % and image pixel transformation in Horace-3. Horace-3 was
            % using these matrices to convert image from hkle to image
            % orthogonal system and back and the pixel-to hkle
            % transformation was performed using bmatrix of Bussing and
            % Levy
            %
            % Not used in production code and left for testing and
            % reference purposes
            b_mat = obj.bmatrix(3);
            [rlu_to_u, u_to_rlu, ulen] = projaxes_to_rlu_legacy_(b_mat,type,nonortho,u,v,w);
        end

        function [u,v,w,type,nonortho]=uv_from_u_to_rlu_legacy(obj,u_to_rlu,ulen,varargin)
            % Extract initial u/v vectors, defining the plane in hkl from
            % lattice parameters and the matrix converting vectors in
            % crystal Cartesian coordinate system into image coordinate system.
            %
            % partially inverting projaxes_to_rlu function of line_proj class
            % as only orthogonal to u part of the v-vector can be recovered
            %
            % Inputs:
            % u_to_rlu -- matrix used for conversion from pixel coordinate
            %          system to the image coordinate system divided by B-matrix
            %          If it is orthogonal coordinate system, the matrix is rotation
            %          matrix but if it does not -- it is
            %
            % ulen  -- length of the unit vectors of the reciprocal lattice
            %          units, the Horace image is expressed in
            % Outputs:
            % u     -- [1x3] vector expressed in rlu and defining the cut
            %          direction
            % v     -- [1x3] vector expressed in rlu, and together with u
            %          defining the cut plain
            % w    --  [1x3] vector expressed in rlu, defining the cut area. May be
            %          empty
            % type --  3-letter projection type as defined by line_proj
            % Optional:
            % b-matrix  Busing and Levy B-matrix which defines transformation between
            %           hkle and Crystal Cartesian coordinate systems.
            %
            % Returns:
            %  u,v,w  -- vectors with define line_proj direction
            %  type   -- 3-letter type of line_proj
            % nonortho
            %         -- true or false depending on if u_to_rlu is
            %            orthogonal projection or not
            [u,v,w,type,nonortho]=uv_from_u_to_rlu_(obj,u_to_rlu,ulen,varargin{:});
        end
        %
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
        %
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
        function [is,mess] = eq(obj,other_obj,varargin)
            % Overloaded equality operator comparing the projection
            % transformation rather then all projection properties
            %
            % Different projection property values may define the same
            % transformation, so the projections, which define the same
            % transformation should be considered the equal.
            %
            % Inputs:
            % other_obj -- the object or array of objects to compare with
            %               current object
            % Optional:
            % any set of parameters equal_to_tol function would accept, as
            % eq uses equal_to_tol function internally
            %
            % Returns:
            % True if the objects define the sample pixel transformation and
            %      false if not.
            % Optional:
            % message, describing in more details where non-equality
            % occurs (used in unit tests to indicate the details of
            % inequality)

            if nargout == 2
                if nargin>2
                    names = LineProjBase.extract_eq_neq_names(varargin{:});
                else
                    names = cell(2,1);
                    names{1} = inputname(1);
                    names{2} = inputname(2);
                end
                [is,mess] = eq_(obj,other_obj,nargout,names,varargin{:});
            else
                is = eq_(obj,other_obj,nargout,cell(2,1),varargin{:});
            end
        end

        function [nis,mess] = ne(obj,other_obj,varargin)
            % Non-equality operator expressed through equality operator
            %
            if nargout == 2
                if nargin > 2
                    names = line_proj.extract_eq_neq_names(varargin{:});
                else
                    names{1} = inputname(1);
                    names{2} = inputname(2);
                end
                [is,mess] = eq_(obj,other_obj,nargout,names,varargin{:});
            else
                is = eq_(obj,other_obj,nargout,cell(2,1),varargin{:});
            end
            nis = ~is;
        end
        %
    end
    %
    methods(Static)
        function lst = data_sqw_dnd_export_list()
            % Method, which define the values to be extracted from projection
            % to convert to old style data_sqw_dnd class.
            % New data_sqw_dnd class (rather dnd class) contains the whole
            % projection, so this method is left for compatibility with
            % old Horace
            lst = {'u_to_rlu','ulen','nonorthogonal','alatt','angdeg','uoffset','label'};
        end
    end
    %======================================================================
    methods(Access=protected)
        function scales = get_img_scales(obj)
            scales = obj.img_scales_;
        end
        function ulen = get_ulen(obj)
            ulen = obj.img_scales_;
            %ulen = obj.transform_img_to_hkl(scales(:));
        end

        function obj = set_img_scales(obj,val)
            if ~isnumeric(val)||(numel(val)<3) || numel(val)>4
                error('HORACE:horace3_proj_interface:invalid_argument', ...
                    'ulen has to be 3 or 4-components numeric vector. It is %s', ...
                    disp2str(val));
            end
            if numel(val) == 3
                obj.img_scales_ = [val(:)',1];
            elseif numel(val)== 4
                obj.img_scales_ = val(:)';
            end
        end
        function name = get_axes_name(~)
            % return the name of the axes class, which corresponds to this
            % projection
            name = 'line_axes';
        end
        %==================================================================
        % Transformation
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
            if isa(obj.targ_proj_,'LineProjBase') && ~obj.disable_srce_to_targ_optimization
                obj = set_ortho_ortho_transf_(obj);
            else
                obj.ortho_ortho_transf_mat_ = [];
                obj.ortho_ortho_offset_ = [];
            end
        end
        %
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
    methods(Static,Access=private)
        function names = extract_eq_neq_names(varargin)
            % function helps to parse inputs of eq/neq functions in case
            % when it called within the chain of other functions containing
            % input parameters
            % if varargin contains
            names = cell(2,1);
            argi = cellfun(@(x)char(string(x)),varargin,'UniformOutput',false);
            is = ismember(argi,'name_a');
            if any(is)
                ind = find(is);
                names{1} = varargin{ind+1};
            end
            is = ismember(argi,'name_b');
            if any(is)
                ind = find(is);
                names{2} = varargin{ind+1};
            end
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
