classdef axes_block < serializable
    % The class contains information about axes and scales used for
    % displaying sqw/dnd object.
    %
    % It also contains main methods, used to produce physical image of the
    % sqw/dnd object
    %
    properties(Dependent)
        title      % Title of sqw data structure
        filename   % Name of sqw file that is being read, excluding path. Used in titles
        filepath   % Path to sqw file that is being read, including terminating file separator.
        %          Used in titles

        label    % labels for u1,u2,u3,u4 as cell array
        %               e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
        %                   *OR*
        %   label{1}  label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
        %   label{2}  label for u2 axis
        %   label{3}  label for u3 axis
        %   label{4}  label for u4 axis (e.g. 'E' or 'En')

        iax;      %Index of integration axes into the projection axes  [row vector]
        %          Always in increasing numerical order
        %                  e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
        iint; %Integration range along each of the integration axes. [iint(2,length(iax))]
        %     e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
        pax   %Index of plot axes into the projection axes  [row vector]
        %      Always in increasing numerical order
        %      e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
        %      2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
        dax    %Index into data.pax of the axes for display purposes. For example we may have
        %      data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
        %      the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
        %      the display axes to be permuted but without the contents of the fields p, s,..pix needing to
        %      be reordered [row vector]
        p;     %Cell array containing bin boundaries along the plot axes [column vectors]
        %      i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
        %------------------------------------------------------------------
        %
        ulen   %Length of projection axes vectors in Ang^-1 or meV [row vector]
        %
        % The range (in axes coordinate system), the binning is made and the
        % axes block describes
        img_range
        %
        n_dims;  % Number of axes_block object dimensions
        %
        % binning along each dimension of an object assuming that
        % all objects are 4-dimensional one. E.g. 1D object in with 10 bins in
        % x-direction would have binning [10,1,1,1] and 1D object with 10
        % bins in dE direction would have binning [1,1,1,10];
        nbins_all_dims
        % number of bins for each non-unit dimension. This would be the
        % binning of the data arrays associated with the given axes_block
        data_nbins;
    end

    properties
        %
        %  Reference to class, which define axis captions. TODO: delete this, mutate axes_block
        axis_caption = an_axis_caption();
        %
        %TODO: Its here temporary, until full projection is stored in sqw obj
        nonorthogonal = false % if the coordinate system is non-orthogonal.
    end
    properties(Access=protected)
        title_   =''   % Title of sqw data structure
        filename_=''   % Name of sqw file that is being read, excluding path. Used in titles
        filepath_=''   % Path to sqw file that is being read, including terminating file separator.
        %               Used in titles
        label_  = {'Q_h','Q_k','Q_l','En'}; %Labels of the projection axes [1x4 cell array of character strings]
        ulen_=[1,1,1,1]         %Length of projection axes vectors in Ang^-1 or meV [row vector]
        img_range_      = ...
            [0,0,0,0;0,0,0,0]; % 2x4 vector of min/max values in 4-dimensions
        nbins_all_dims_ = [1,1,1,1];    % number of bins in each dimension
        dax_=[];                        % display axes numbers holder
        % e.g. r.l.u. and energy [h; k; l; en] [row vector]
        %

    end
    properties(Constant,Access=private)
        % fields which fully represent the state of the class and allow to
        % recover it state by setting properties through public interface
        fields_to_save_ = {'title','filename','filepath',...
            'label','ulen','img_range','nbins_all_dims',...
            'dax','nonorthogonal'};
    end
    properties(Dependent,Hidden)
        % old interface to label
        ulabel
    end

    methods (Static)
        % build new axes_block object from the binning parameters, provided
        % as input. If some input binning parameters are missing, the
        % defaults are taken from the given image range which should be
        % properly prepared
        obj = build_from_input_binning(cur_img_range_and_steps,pbin);
        %
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = axes_block();
            obj = loadobj@serializable(S,obj);
        end
        function [any_within,is_within]=bins_in_1Drange(bins,range)
            % get bins which contribute into the given range in one
            % dimension
            % Inputs:
            % bins -- equally spaced increasing array of values,
            %         representing bin edges.
            % range -- 2 element vector of min/max values which should
            %          surround contributing range
            % Output:
            % any_within -- true if any input bin contribute into the
            %               selected range and false otherwise
            % is_within  -- logical array of size numel(bins)-1
            [any_within,is_within]=bins_in_1Drange_(bins,range);
        end

        %
        function img_range = calc_img_db_range(ax_data)
            % LEGACY FUNCTION, left for compartibility with old binary sqw
            % files for transforming the data, stored there into modern
            % axes_block form
            % 
            % Retrieve 4D range used for rebinning pixels
            % from old style sqw objects, where this range was not stored
            % directly as it may become incorrect after some
            % transformations.
            %
            % Returns:
            % img_range  -- the estimate for the image range, used to
            %               build the grid used as keys to get the pixels,
            %               contributed into the image
            %
            % Should not be used directly, only for compatibility with old
            % data formats. New sqw object should maintain correct
            % img_range during all operations
            %
            % Inputs: either data_sqw_dnd instance or a structure
            % containing:
            % The relevant data structure used as source of image range is as follows:
            %
            %   ds.iax        Index of integration axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
            %   ds.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
            %                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
            %   ds.pax        Index of plot axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
            %                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
            %   ds.p          Cell array containing bin boundaries along the plot axes [column vectors]
            %                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
            %   ds.dax        Index into data.pax of the axes for display purposes. For example we may have
            %                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
            %                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
            %                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
            %
            img_range = calc_img_db_range_(ax_data);
        end
    end

    methods
        function obj = axes_block(varargin)
            % constructor
            %
            %>>obj = axes_block() % return empty axis block
            %>>obj = axes_block(ndim) % return unit block with ndim
            %                           dimensions
            %>>obj = axes_block(p1,p2,p3,p4) % build axis block from axis
            %                                  arrays
            %>>obj = axes_block(pbin1,pbin2,pbin3,pbin4) % build axis block
            %                                       from binning parameters
            %
            if nargin==0
                return;
            end
            obj = obj.init(varargin{:});
        end
        %
        function [obj,offset,remains] = init(obj,varargin)
            % initialize object with axis parameters.
            %
            % The parameters are defined as in constructor.
            % Returns:
            % obj    -- initialized by inputs axis_block object
            % offset -- the offset for axis box from the origin of the
            %            coordinate system
            % remains -- the arguments, not used in initialization if any
            %            were provided as input
            %
            [obj,offset,remains] = init_(obj,varargin{:});
        end


        function sz = dims_as_ssize(obj)
            % Return the extent along each dimension of the signal arrays.
            % suitable for allocating appropriate size memory
            sz = obj.data_nbins;
            if isempty(sz)      ; sz = [1,1];
            elseif numel(sz) ==1; sz = [sz,1];
            end
        end

        % return 3 q-axis in the order they mark the dnd object
        % regardless of the integration along some axis
        % TODO: probably should be removed
        [q1,q2,q3] = get_q_axes(obj);
        %

        % find the coordinates along each of the axes of the smallest cuboid
        % that contains bins with non-zero values of contributing pixels.
        [val, n] = data_bin_limits (din);
        %

        function [cube_coord,step] = get_axes_scales(obj)
            % Return 4D cube, describing the minimal grid cell of the axes block
            [cube_coord,step] = get_axes_scales_(obj);
        end
        %
        function [npix,s,e,pix,pix_indx] = bin_pixels(obj,pix_coord_transf,varargin)
            % Bin and distribute data expressed in the coordinate system
            % described by this axes block over the current N-D lattice
            %
            % Usage:
            % >>npix = obj.bin_pixels(coord);
            % >>[npix,s,e] = obj.bin_pixels(coord,npix,s,e);
            % >>[npix,s,e,pix_ok] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
            % >>[npix,s,e,pix_ok,pix_indx] = bin_pixels(obj,coord,npix,s,e,pix_candidates)
            % Where
            % Inputs:
            % pix_coord_transf
            %         -- [4,npix] array of pixels coordinates to bin.
            % Optional:
            % npix    -- the array of size of the grid, defined by this
            %            axes_block, containing the information about
            %            previous pixel data contribution to the axes grid
            %            cells
            % s        --  the array of size of the grid, defined by this
            %            axes_block, containing the information about
            %            previous pixel data contribution to the axes grid
            %            signal cells.
            % e        --  the array of size of the grid, defined by this
            %            axes_block, containing the information about
            %            previous pixel data contribution to the axes grid
            %            variance cells. Must be present if s is present
            %  pix_candidates
            %          -- the PixelData or pixAccees data object,
            %             containing full pixel information.
            % Parameters:
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
            % Returns:
            % npix    -- the array, containing the numbers of pixels
            %            contributing into each grid cell
            % Optional:  Not calculated if not requested as output. Requests
            %            appropriate pix_candidates inputs if requested as
            %            output.
            % s       -- array, containing the accumulated signal for each
            %            grid bin.
            % e       -- array, containing the accumulated error for each
            %            grid bin.
            % pix     -- pixel array or PixelData
            %            object (the output format is the same as for
            %            pix_candidates)
            % pix_indx --Array of indexes for the image bins, where
            %            the input pix elements belong to

            nargou = nargout;
            % convert different input forms into fully expanded common form
            [npix,s,e,pix_cand,argi]=...
                obj.normalize_bin_input(pix_coord_transf,nargou,varargin{:});
            %
            % bin pixels
            [npix,s,e,pix,pix_indx] = bin_pixels_(obj,pix_coord_transf,nargou,...
                npix,s,e,pix_cand,argi{:});
        end
        %
        function [nodes,dE_edges,npoints_in_axes] = get_bin_nodes(obj,varargin)
            % build 3D or 4D vectors, containing all nodes of the axes_block grid,
            % constructed over axes_block axes points.
            %
            % Inputs:
            % obj         -- initialized version of the axes block
            % Optional:
            %  char_cube -- the cube, describing the scale of the grid,
            %              to construct the lattice on.
            %
            % '-3D'     -- generate separate 3D grid nodes for q-axes and
            %              energy transfer binning grid as the energy axis
            %
            % -halo     -- request to build lattice in the
            %              specified range + single sized characteristic
            %              step
            % Returns:
            % nodes     -- [4,nBins] or [3,nBins] array of points,
            %              (depending on state of '-3D' switch)  where
            %              the coordinate of each point is a node of the
            %              grid, formed by axes_block axes.
            % Optional:
            % dE_edges  -- if '-3D' switch is present, coordinates of the
            %              energy transfer grid, empty if not
            % npoints_in_axes
            %           -- 4-elements vector, containing numbers of axes
            %              nodes in each of 4 directions
            %
            opt = {'-3D','-halo'};
            [ok,mess,do_3D,build_halo,argi] = parse_char_options(varargin,opt);
            if ~ok
                error('Horace:axes_block:invalid_argument',mess)
            end
            [nodes,dE_edges,npoints_in_axes] = calc_bin_nodes_(obj,do_3D,build_halo,argi{:});
        end
        %
        function range = get_binning_range(obj,...
                cur_proj,new_proj)
            % Get the default binning range to use in cut, defined by a new
            % projection. If no new projection is provided, return current
            % binning range, i.e. the ranges used to construct this
            % axes_block.
            %
            % If new projection is not aligned with the old projection, the new
            % projection range is transformed from the old projection range and
            % its binning is copied from the old projection binning according to
            % axis number, i.e. if axis 1 of cur_proj had 10 bins, axis 1 of target
            % proj would have 10 bins, etc. This redefines the behaviour of the
            % cuts when some directions are integration directions, but
            % become projection directions, and redefine it when a new
            % projection direction goes in a direction mixing
            % the current projection and the integration directions.
            %
            % Inputs:
            % obj      - current instance of the axes block
            % cur_proj - the projection, current block is defined for
            % new_proj - the projection, for which the requested range should
            %            be defined
            % if both these projection are empty, returning the current binning range
            %
            % Output:
            % range    - 4-element cellarray of ranges, containing current
            %            binning range expressed in the coordinate system,
            %            defined by the new projection (or current binning range if new
            %            projection is not provided)
            if nargin < 3
                cur_proj = [];
                new_proj = [];
            end
            range  = get_binning_range_(obj,cur_proj,new_proj);
        end
        %------------------------------------------------------------------
        % ACCESSORS
        %------------------------------------------------------------------
        function tit = get.title(obj)
            tit = obj.title_;
        end
        function obj = set.title(obj,val)
            if ~ischar(val) || isstring(val)
                error('HORACE:axes_block:invalid_argument',...
                    'title should be defined of array of characters or by a string')
            end
            obj.title_ = val;
        end
        %
        function fn = get.filename(obj)
            fn = obj.filename_;
        end
        function obj = set.filename(obj,fn)
            if ~ischar(fn) || isstring(fn)
                error('HORACE:axes_block:invalid_argument',...
                    'filename should be defined of array of characters or by a string')
            end
            [~,fn,fext] = fileparts(fn);
            obj.filename_ = [fn,fext];
        end
        %
        function fp = get.filepath(obj)
            fp = obj.filepath_;
        end
        function obj = set.filepath(obj,fp)
            if ~ischar(fp) || isstring(fp)
                error('HORACE:axes_block:invalid_argument',...
                    'filepath should be defined of array of characters or by a string')
            end
            obj.filepath_ = fp;
        end

        %
        function lab=get.label(obj)
            lab = obj.label_;
        end
        function obj=set.label(obj,val)
            obj = check_and_set_labels_(obj,val);
        end
        %
        function ir = get.img_range(obj)
            ir = obj.img_range_;
        end
        function obj = set.img_range(obj,val)
            obj = check_and_set_img_range_(obj,val);
        end
        %
        function nbin = get.nbins_all_dims(obj)
            nbin = obj.nbins_all_dims_;
        end
        function obj = set.nbins_all_dims(obj,val)
            obj = check_and_set_nbin_all_dim_(obj,val);
        end
        %
        function ul = get.ulen(obj)
            ul = obj.ulen_;
        end
        function obj = set.ulen(obj,val)
            if isnumeric(val) && numel(val) == 3
                val = [val(:)',1];
            end
            if ~(isnumeric(val) && numel(val) == 4)
                error('HORACE:axes_block:invalid_argument',...
                    'ulen should be vector, containing 4 elements')
            end
            obj.ulen_ = val(:)';
        end
        %
        function da = get.dax(obj)
            da = obj.dax_;
        end
        function obj = set.dax(obj,val)
            obj = check_and_set_dax_(obj,val);
        end

        %------------------------------------------------------------------
        % historical and convenience getters for dependent properties
        % which do not have setters
        %------------------------------------------------------------------
        function ndim = get.n_dims(obj)
            ndim = sum(obj.nbins_all_dims_>1);
        end
        function ds = get.data_nbins(obj)
            ds= obj.nbins_all_dims_(obj.nbins_all_dims_>1);
        end

        function ia = get.iax(obj)
            ia = find(obj.nbins_all_dims_==1);
        end
        function pa = get.pax(obj)
            pa = find(obj.nbins_all_dims_>1);
        end
        function iin = get.iint(obj)
            iin = obj.img_range_(:,obj.nbins_all_dims_==1);
        end
        function pc = get.p(obj)
            pc = build_axes_from_ranges_(obj);
        end
        % old interface
        function obj = set.ulabel(obj,val)
            obj.label = val;
        end
        function lab = get.ulabel(obj)
            lab  = obj.label_;
        end
        %
        %------------------------------------------------------------------
        function flds = indepFields(~)
            % get independent fields, which fully define the state of a
            % serializable object.
            flds = axes_block.fields_to_save_;
        end
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 2;
        end
    end
    methods(Access=protected)
        function [npix,s,e,pix_candidates,argi]=...
                normalize_bin_input(obj,pix_coord_transf,n_argout,varargin)
            % verify inputs of the bin_pixels function and convert various
            % forms of the inputs of this function into a common form,
            % where the missing inputs are returned as empty.
            %
            %Inputs:
            % pix_coord_transf -- the array of pixels coordinates
            %                     transformed into this axes_block
            %                      coordinate system
            % n_argout         -- number of argument, requested by the
            %                     calling function
            %

            [npix,s,e,pix_candidates,argi]=...
                normalize_bin_input_(obj,pix_coord_transf,n_argout,varargin{:});
        end

        function obj = from_old_struct(obj,inputs)
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_bare_struct
            % method, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
            %
            if isfield(inputs,'version') && (inputs.version == 1) || ...
                    isfield(inputs,'iint')
                inputs = axes_block.convert_old_struct_into_nbins(inputs);
            end
            if isfield(inputs,'array_dat')
                obj = obj.from_bare_struct(inputs.array_dat);
            else
                obj = obj.from_bare_struct(inputs);
            end
        end

    end
    methods(Static)
        function input = convert_old_struct_into_nbins(input)
            % the function, used to convert old v1 axes_block structure,
            % containing axes information, into the v2 structure,
            % containing only range and bin numbers
            input = convert_old_struct_into_nbins_(input);
        end
    end
end
