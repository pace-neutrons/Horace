classdef AxesBlockBase < serializable
    % The class contains information about axes and scales used for
    % displaying sqw/dnd object and provides scales for neutron image data
    % binned on a grid, defined by this class
    %
    % It also contains main methods, used to produce physical image of the
    % sqw/dnd object
    %
    % Construction:
    %1) ab = AxesBlockBase(num) where num belongs to [0,1,2,3,4];
    %2) ab = AxesBlockBase([min1,step1,max1],...,[min4,step4,max4]); - 4 binning
    %                                          parameters
    %        or
    %   ab = AxesBlockBase([min1,max1],...,[min4,max4]); - 4 binning
    %                                          parameters
    %        or any combination of ranges [min,step,max] or [min,max]
    %3) ab = AxesBlockBase(structure) where structure contains any fields
    %                              returned by savebleFields method
    %4) ab = AxesBlockBase(param1,param2,param3,'key1',value1,'key2',value2....)
    %        where param(1-n) are the values of the fields in the order
    %        fields are returned by saveableFields function.
    %5) ab = AxesBlockBase('img_range',img_range,'nbins_all_dims',nbins_all_dims)
    %    -- particularly frequent case of building axes block (case 4)
    %       from the image range and number of bins in all directions.
    properties(Dependent)
        % Legacy projection interface
        % Title of sqw data structure, displayed on plots.
        title;

        % Name of sqw file that is being read, excluding path.
        %            Used in titles
        filename;

        % Path to sqw file that is being read, including terminating file separator.
        % Used in titles
        filepath;

        % the cellarray of captions, displayed along various axes of plots
        % labels for u1,u2,u3,u4 as cell array
        %               e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
        %                   *OR*
        %   access or set up the axes label separately using their indexes,
        %   i.e.:
        %   label{1}  label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
        %   label{2}  label for u2 axis
        %   label{3}  label for u3 axis
        %   label{4}  label for u4 axis (e.g. 'E' or 'En')
        label;

        % Index of integration axes into the projection axes  [row vector]
        % Always in increasing numerical order e.g. if data is 2D,
        % data.iax=[1,3] means summation has been performed along u1 and u3
        % axes
        iax;

        % Integration range along each of the integration axes. [iint(2,length(iax))]
        %     e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
        iint;

        % Index of plot axes into the projection axes  [row vector]
        %      Always in increasing numerical order
        %      e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
        %      2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
        pax;

        % Index into data.pax of the axes for display purposes. For example we may have
        %      data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
        %      the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
        %      the display axes to be permuted but without the contents of the fields p, s,..pix needing to
        %      be reordered [row vector]
        dax;

        %Cell array containing bin boundaries along the plot axes [column vectors]
        %   e.g. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
        p;
    end
    %
    properties
        %------------------------------------------------------------------
        % The range (in axes coordinate system), the binning is made and the
        % axes block describes.
        img_range;
        % binning along each dimension of an object assuming that
        % all objects are 4-dimensional one. E.g. 1D object in with 10 bins in
        % x-direction would have binning [10,1,1,1] and 1D object with 10
        % bins in dE direction would have binning [1,1,1,10];
        nbins_all_dims;
        %
        %
        dimensions;  % Number of AxesBlockBase object dimensions (number of pax)

        % what each axes units are. Defined by and should be synchoneous
        % to "type" property in projection
        axes_units
        % shift between the origin of the axes block and the origin of
        % hkl-dE coordinate system (in rlu-dE, hkl units, not rotated)
        offset
    end
    properties(Dependent) % Helper properties
        % number of bins for each non-unit dimension. This would be the
        % binning of the data arrays associated with the given AxesBlockBase
        data_nbins;

        % number of bins in each non-unit dimension presented in the form,
        % which allows you to allocate an array of the appropriate size
        % i.e. size(s) == dims_as_ssize and size(zeros(dims_as_ssize)) ==
        % size(s)
        dims_as_ssize;

        % boolean row, identifying if a single bin direction (dir)
        % (nbins_all_dims(dir)==1) is integration axis or a projection
        % axis. By default, single nbins_all_dims direction is
        % integration direction.
        % If the index is false in a direction, where more then one bin
        % is defined, the input binning parameters in this direction
        % are treated as bin edges rather then bin centres.
        single_bin_defines_iax;
    end
    properties(Dependent,Hidden)
        % the step in each pax dimension in units of img_range units,
        % defined by img_range(pax) and nbins_all_dims(pax) properties
        step;
        %
        max_img_range;  % maximal range the image can have. Infinity for linear
        %             but have limits for some dimensions in spherical or
        %             cylindrical projections.
        %
        img_scales; %The scales to convert img_range in image-appropriate units,i.e.
        %          number to transform to A^{-1} for linear axes, to rad/deg
        %          for angular and to meV  for energy transfer
        type;  % units of axes, retrieved from projection. Not currently
        %        used by linear_axes but is deployed in curvilinear
        %        axes to convert from degrees to radians and vice versa.
        %
        % property defines if appropriate axes block presented on
        % picture changes aspect ratio of a 2D image, so that equal
        % physical ranges along axes occupy equal pixel ranges on the image
        % May be set up locally on an object but have defaults specific for
        % each axes block
        changes_aspect_ratio;
        %------------------------------------------------------------------
        full_filename % convenience property as fullfile(filepath, filename)
        % are often used
        % Old name for img_range left for compartibility with old user code
        img_db_range;

        %Old interface to img_scales
        ulen;   % in Ang^-1 or meV [row vector]
    end

    properties(Access=protected)
        title_   =''   % Title of sqw data structure
        filename_=''   % Name of sqw file that is being read, excluding path. Used in titles
        filepath_=''   % Path to sqw file that is being read, including terminating file separator.
        %               Used in titles
        label_  = {'Q_h','Q_k','Q_l','En'}; %Labels of the projection axes [1x4 cell array of character strings]
        img_scales_=[1,1,1,1]         %Length of projection axes vectors in Ang^-1, meV or rad/deg [row vector]
        img_range_      = ... % 2x4 vector of min/max values in 4-dimensions
            PixelDataBase.EMPTY_RANGE_; % [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf]

        nbins_all_dims_ = [1,1,1,1];    % number of bins in each dimension
        single_bin_defines_iax_ = true(1,4); % true if single nbin direction represents integration axis
        dax_=[];                        % display axes numbers holder
        dax_set_ = false;
        % e.g. r.l.u. and energy [h; k; l; en] [row vector]

        % internal property, which defines if appropriate axes block presented on
        % picture changes aspect ratio of a 2D image.
        changes_aspect_ratio_=true;
        % maximal range the image can have
        max_img_range_ = [-inf,-inf,-inf,-inf;inf,inf,inf,inf];
        %
        offset_ = [0,0,0,0];
        %
        type_ = ''
    end
    %----------------------------------------------------------------------
    methods(Static)
        % build new particular AxesBlockBase object from the binning
        % parameters, provided as input. If some input binning parameters
        % are missing, the defaults are taken from the given image range
        % which should be properly pre-calculated
        obj = build_from_input_binning(proj_cl_name,cur_img_range_and_steps,pbin);
        %
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
    end
    %----------------------------------------------------------------------
    methods
        function obj = AxesBlockBase(varargin)
            % constructor
            %
            %>>obj = AxesBlockBase() % return empty axis block
            %>>obj = AxesBlockBase(ndim) % return unit block with ndim
            %                           dimensions
            %>>obj = AxesBlockBase(p1,p2,p3,p4) % build axis block from axis
            %                                  arrays
            %>>obj = AxesBlockBase(pbin1,pbin2,pbin3,pbin4) % build axis block
            %                                       from binning parameters
            %>>obj = AxesBlockBase('key1',value,'key2',value,...)
            %        build axis block from property names and property
            %        values (standard serializable constructor)

            %
            if nargin == 0
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
            if nargin==1
                offset = [];
                remains = [];
                return;
            end
            obj.do_check_combo_arg_ = false;
            [obj,offset,remains] = init_(obj,varargin{:});
            obj.do_check_combo_arg_ = true;
            obj = check_combo_arg(obj);
        end
        %------------------------------------------------------------------
        % ACCESSORS to modern API
        %------------------------------------------------------------------
        function sz = get.dims_as_ssize(obj)
            % Return the extent along each dimension of the signal arrays.
            % suitable for allocating appropriate size memory
            sz = obj.data_nbins;
            if isempty(sz)     ; sz = [1,1];
            elseif isscalar(sz); sz = [sz,1];
            end
        end
        %
        function tit = get.title(obj)
            tit = obj.title_;
        end
        function obj = set.title(obj,val)
            if ~istext(val)
                error('HORACE:AxesBlockBase:invalid_argument',...
                    'title should be defined of array of characters or by a string')
            end
            obj.title_ = val;
        end
        %
        function fn = get.filename(obj)
            fn = obj.filename_;
        end
        function obj = set.filename(obj,fn)
            if ~istext(fn)
                error('HORACE:AxesBlockBase:invalid_argument',...
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
            if ~istext(fp)
                error('HORACE:AxesBlockBase:invalid_argument',...
                    'filepath should be defined of array of characters or by a string')
            end
            obj.filepath_ = fp;
        end
        function fn = get.full_filename(obj)
            fn = fullfile(obj.filepath_,obj.filename_);
        end
        function obj = set.full_filename(obj,fn)
            [flpth_,flnm_] = parse_full_filename(fn);
            obj.filepath_ = flpth_;
            obj.filename_ = flnm_;
        end
        %
        %------------------------------------------------------------------
        % MUTATORS/ACCESSORS to methods in modern API
        %------------------------------------------------------------------
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
            obj = check_and_set_img_range(obj,val);
        end

        function nbin = get.nbins_all_dims(obj)
            nbin = obj.nbins_all_dims_;
        end
        function obj = set.nbins_all_dims(obj,val)
            obj = check_and_set_nbin_all_dim_(obj,val);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function ul = get.ulen(obj)
            ul = obj.img_scales_;
        end
        function obj = set.ulen(obj,val)
            obj.img_scales = val;
        end
        function ul = get.img_scales(obj)
            ul = obj.img_scales_;
        end
        function obj = set.img_scales(obj,val)
            if isnumeric(val) && numel(val) == 3
                val = [val(:)',1];
            end
            if ~(isnumeric(val) && numel(val) == 4)
                error('HORACE:AxesBlockBase:invalid_argument',...
                    'img_scales should be vector, containing 4 elements')
            end
            obj.img_scales_ = val(:)';
        end
        %
        function da = get.dax(obj)
            da = obj.dax_;
        end
        function obj = set.dax(obj,val)
            if min(val(:))~=1
                error('HORACE:AxesBlockBase:invalid_argument',...
                    'Mininal dax value should refer to the first projection axes. Actually: pax = %s; dax = %s', ...
                    mat2str(obj.pax),mat2str(val(:)'));
            end
            obj.dax_ = val(:)';
            obj.dax_set_ = true;
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function off = get.offset(obj)
            off = obj.offset_;
        end
        function obj = set.offset(obj,val)
            obj = check_and_set_offset_(obj,val);
        end
        %
        function is = get.single_bin_defines_iax(obj)
            is = obj.single_bin_defines_iax_;
        end
        function obj = set.single_bin_defines_iax(obj,val)
            if numel(val) ~= 4
                error('HORACE:AxesBlockBase:invalid_argument', ...
                    'single_bin_defines_iax property accepts only 4-element logical vector or vector convertible to logical')
            end
            obj.single_bin_defines_iax_ = logical(val(:)');
        end
        function type = get.type(obj)
            type = obj.type_;
        end
        function type = get.axes_units(obj)
            type = obj.type_;
        end
        function obj = set.type(obj,val)
            obj = check_and_set_type(obj,val);
        end
        function obj = set.axes_units(obj,val)
            obj = check_and_set_type(obj,val);
        end

        %------------------------------------------------------------------
        % LEGACY API: historical and convenience getters for dependent properties
        % which do not have setters
        %------------------------------------------------------------------
        function ndim = get.dimensions(obj)
            ndim = sum(is_pax_(obj));
        end
        function ds = get.data_nbins(obj)
            ds= obj.nbins_all_dims_(obj.nbins_all_dims_>1);
        end
        %
        function ia = get.iax(obj)
            ia = find(obj.nbins_all_dims_==1 & obj.single_bin_defines_iax_);
        end
        function pa = get.pax(obj)
            pa = find(is_pax_(obj));
        end
        function iin = get.iint(obj)
            is_iint = obj.nbins_all_dims_==1 & obj.single_bin_defines_iax_;
            iin = obj.img_range_(:,is_iint);
        end
        function pc = get.p(obj)
            pc = build_axes_from_ranges_(obj);
        end
        %
        function imr = get.img_db_range(obj)
            imr = obj.img_range;
        end
        function obj = set.img_db_range(obj,val)
            obj.img_range = val;
        end
        %------------------------------------------------------------------
        function do_change = get.changes_aspect_ratio(obj)
            do_change  = obj.changes_aspect_ratio_;
        end
        function obj = set.changes_aspect_ratio(obj,val)
            obj.changes_aspect_ratio_ = logical(val);
        end

        function steps = get.step(obj)
            steps = (obj.img_range(2, obj.pax) - obj.img_range(1, obj.pax)) ./ (obj.nbins_all_dims(obj.pax)-1);
        end

        function range = get.max_img_range(obj)
            range = obj.max_img_range_;
        end
    end
    %======================================================================
    % Integration, interpolation and binning
    %----------------------------------------------------------------------
    methods
        % return binning range of existing data object, so that cut without
        % parameters, performed within this range would return the same cut
        % as the original object
        range = get_cut_range(obj,varargin);
        % Identify range this axes block occupies in target coordinate
        % system
        [range,is_in,img_targ_center] = get_targ_range(obj,source_proj,targ_proj,range_requested);

        % Return characteristic size of a grid cell in the target
        % coordinate system.
        sz = get_char_size(obj,this_proj);
        % return nodes of the interpolation grid used to identify grid
        % intercept
        [nodes,inside] = get_interp_nodes(obj,this_proj,char_sizes);

        function volume = get_bin_volume(obj,varargin)
            % Return the volume(s) of the axes grid. For rectilinear grid, the
            % volume of the grid is the scalar equal to the product
            % of the grid steps in all directions.
            % For the coordinate systems where grid volumes depend on
            % the grid number (e.g. spherical), the volume is
            % 1D array of the volumes of the cells. The number of elements
            % in the array is equal to the number of cells in the grid.
            % Inputs:
            % obj   -- initialized instance of an AxesBlockBase class
            % Optional:
            % axes  -- 4-element celarray, containig axes in all 4
            %          directions. If this argument is present, the
            %          volume(s) are calculated for the grid, build from
            %          the axes provided as input.
            % OR:
            % coordinates
            %       -- 3xnbins or 4xnbins array of nodes defining grid
            % grid_size
            %       -- 3 or 4 elements array, defining size of the grid,
            %          defined by the coordinates
            %

            if nargin == 1
                [~,~,~,volume] = obj.get_bin_nodes('-axes_only');
            elseif nargin > 1
                volume = obj.calc_bin_volume(varargin{:});
            else
                error('HORACE:AxesBlockBase:invalid_argument', ...
                    'This method accepts no or one argument. Called with %d arguments', ...
                    nargin);
            end

        end

        function bin_idx = bin_points(obj, pts)
            % Get the bin indices to which the points in pts would be binned
            % Inputs:
            % obj   -- initalized instance of an AxesBlockBase class
            % pts   -- dim X N array of numeric points to bin, where dim is the
            %            number of projection axes of the AxesBlockBase object
            if size(pts, 2) ~= numel(obj.p)
                error('HORACE:AxesBlockBase:invalid_argument', ...
                    'Cannot bin points with different dimensionality to the axes block.')
            end

            bin_idx = zeros(size(pts));
            for i = 1:numel(obj.p)
                bin_idx(:, i) = discretize(pts(:, i), obj.p{i});
            end
        end

        function data_out = rebin_data(obj,data_in,other_ax)
            % Rebin data,defined on this axes grid into other axes grid
            %
            % The other axes grid has to be aligned with this axes block
            % according to realigh_axes method of this axes block
            data_out = rebin_data_(obj,data_in,other_ax);
        end
        %
        function ax_block_al = realign_bin_edges(obj,ax_block)
            % align input axes block to have the same or commensurate
            % bin sizes as this axes block and the integration ranges equal
            % or smaller than the ranges of this axes block but
            % commensurate with this axis block bin edges.
            %
            % The coordinate systems of both access blocks assumed to be
            % the same
            ax_block_al = realign_bin_edges_(obj,ax_block);
        end
        %
        function [interp_points,density] = get_density(obj,datasets)
            % Convert input datasets defined on centre-points of this grid
            % into the density data, defined on edges of the grid.
            %
            % Inputs:
            % datasets -- cellarray of input datasets to calculate density
            %             from.
            %             The size and dimensions of the datasets should
            %             be equal to the dimensions of the axes block
            %             returned by dims_as_ssize property, i.e.:
            %             all(size(dataset{i}) == obj.dims_as_ssize);
            %             datasets contain bin values.
            % Returns:
            % intep_pints
            %          -- 2D [4,nAxesEdgesPoints] array of axes positions
            %             where the density is defined
            % density
            %          -- cellarray of density points calculated in the
            %             density points positions.
            %             Number of cells in the output array is equal to
            %             the number of input datasets

            if ~iscell(datasets)
                datasets = {datasets};
            end
            [interp_points,density] = calculate_density_(obj,datasets);
        end
        %
        function [s,e,npix] = interpolate_data(obj,source_axes, ...
                source_proj,data,varargin)
            % interpolate density data for signal, error and number of
            % pixels provided as input density and defined on the nodes of the
            % references axes block onto the grid, defined by this axes block.
            %
            % Inputs:
            % obj      -- axes block defining the lattice for interpolating
            %             signal on.
            % source_axes
            %           -- axes block -source grid, defining the lattice
            %              where source data are defined on
            % source_proj
            %           -- the projection, which defines the coordinate
            %              system related to the source_axes
            % data      -- 1 to 3-elements cellarray containing arrays of data
            %              to interpolate on the nodes of the input axes
            %              block. In the most common case this is the
            %              celarray of s,e,npix data, defined on source
            %              axes block. source_axes.nbins_all_dims ==
            %              size(data{i}) where
            %
            % Optional:
            % proj      -- the projection object defining the transformation
            %              from this coordinate system to the system,
            %              where the reference nodes are defined
            %              If missing or empty, assume that this coordinate
            %              system and reference coordinate system are the
            %              same
            % Returns:
            % s,e,npix  -- interpolated arrays of signal, error and number
            %              of pixels calculated in the centres of the
            %              cells of this lattice.
            if isempty(varargin)
                proj = [];
            else
                proj = varargin{1};
            end
            [s,e,npix] = interpolate_data_(obj,nargout, ...
                source_axes,source_proj, data,proj);
        end
        %
        function [npix,s,e,pix_ok,unique_runid,pix_indx,selected] = bin_pixels(obj,coord_transf,varargin)
            % Bin and distribute data expressed in the coordinate system
            % described by this axes block over the current N-D lattice
            %
            % Usage:
            % >>npix = obj.bin_pixels(coord_transf);
            % >>[npix,s,e] = obj.bin_pixels(coord_transf,npix,s,e);
            % >>[npix,s,e,pix_ok,unque_runid] = bin_pixels(obj,coord_transf,npix,s,e,pix_candidates)
            % >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord_transf,npix,s,e,pix_candidates)
            % >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord_transf,npix,s,e,pix_candidates,unique_runid);
            % >>[npix,s,e,pix_ok,unque_runid,pix_indx,selected] = bin_pixels(obj,coord_transf,npix,s,e,pix_candidates,unique_runid);
            % Where
            % Inputs:
            % coord_transf
            %         -- [4,npix] array of pixels coordinates to bin.
            % Optional:
            % npix    -- the array of size of the grid, defined by this
            %            AxesBlockBase, containing the information about
            %            previous pixel data contribution to the axes grid
            %            cells
            % s        --  the array of size of the grid, defined by this
            %            AxesBlockBase, containing the information about
            %            previous pixel data contribution to the axes grid
            %            signal cells.
            % e        --  the array of size of the grid, defined by this
            %            AxesBlockBase, containing the information about
            %            previous pixel data contribution to the axes grid
            %            variance cells. Must be present if s is present
            % If these arrays are not provided or provided empty, they are
            % initialized to the axes_grid size arrays containing 0, by the binning
            % routine itself
            %  pix_candidates
            %          -- the PixelData or pixAccees data object,
            %             containing full pixel information or 1xnpix to
            %             3xnpis array of interpolated density for
            %             integration
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
            %   N.B. -nomex and -force_mex options can not be used together.
            % '-return_selected' -- Returns `selected` in `pix_ok`
            %                       for use with DnD cuts where fewer args are requested
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
            % pix     -- pixel array or PixelData object (the output format is
            %            the same as for pix_candidates) if input is PixelData
            %        or  accumulated 3rd row of interpolated data if input
            %            is 3xnpix array of interpolated data.
            % unique_runid-array
            %         -- of unique run-id-s for pixels, contributed
            %            into the cut.
            % pix_indx --Array of indexes for the image bins, where
            %            the input pix elements belong to. If this output
            %            is requested, pixels_ok are not sorted according
            %            to bins, but every element of pix_ok array
            %            corresponds to the appropriate pix_indx.
            % selected -- numerical array of indices of selected pixels after
            %            binning
            %
            % Note:
            % unique_runid argument needed to get pixels sorted according
            % to bins. If it is not requested, pix_ok are returned unsorted.
            %

            if numel(varargin) == 4 && iscell(varargin{4})
                mode = 4;
            else
                mode = nargout;
            end
            % convert different input forms into fully expanded common form
            [npix,s,e,pix_cand,unique_runid,argi]=...
                obj.normalize_bin_input(coord_transf,mode,varargin{:});
            %
            % bin pixels
            [npix,s,e,pix_ok,unique_runid,pix_indx,selected] = bin_pixels_(obj,coord_transf,mode,...
                npix,s,e,pix_cand,unique_runid,argi{:});
        end
        %
        function [nodes,dE_edges,nbin_size,grid_cell_size] = get_bin_nodes(obj,varargin)
            % build 3D or 4D vectors, containing all nodes of the AxesBlockBase grid,
            % constructed over AxesBlockBase axes points.
            %
            % Note: Nodes are 3D or 4D vertices of the axes grid cells, so the
            %       output is 3xN_nodes or 4xN_nodes arrays of the vertices, where each
            %       column describes a point on a grid.
            %
            % Inputs:
            % obj        -- initialized version of the axes block
            %
            % Optional:
            % nbins_all_dims
            %           -- (4-element vector) or single number representing
            %               4-element vector of the same values, describing
            %               the binning along each axis for the lattice to
            %               build instead of existing axis binning
            %
            % '-3D'     -- generate separate 3D grid nodes for q-axes and
            %              energy transfer binning grid as the energy axis
            %              instead of 4D lattice
            %
            % '-halo'   -- request to build lattice in the
            %              specified range + single-cell sized
            %              step expanding the lattice
            % '-bin_edges'
            %           -- if provided, returns grid containing bin edges.
            % '-bin_centre'
            %           -- if provided, returns grid containing bin centers
            % '-dens_interp'
            %           -- if present, return grid used to define density,
            %              bin centers for projection axes and bin edges for
            %              integrated dimensions.
            % '-plot_edges' -- if present, return bin_edges as used for plotting dispersion
            %              i.e. bin edges for plot axes and bin centers for integration
            %              axes

            % '-axes_only'
            %           -- if provided, do not return 3D or 4D grid but
            %              just return the axes in each 3 or 4 dimensions
            %              (as requested by '-3D' switch)
            % '-hull'   -- return only boundary nodes of the grid
            %              If '-halo' is also provided, return edge nodes
            %              and halo nodes.
            % '-ngrid'  -- return nodes as cellarray of arrays, produced by
            %              ngrid function
            % Returns:
            % nodes     -- [4 x nBins] or [3 x nBins] array of points,
            %              (depending on state of '-3D' switch)  where
            %              the coordinate of each point is a node of the
            %              grid, formed by AxesBlockBase axes, or AxesBlockBase
            %              axes if '-axes_only' switch is requested.
            % Optional:
            % dE_edges  -- if '-3D' switch is present, coordinates of the
            %              energy transfer grid, empty if not
            % nbin_size -- 4-elements vector, containing numbers of axes
            %              nodes in each of 4 directions
            % grid_cell_size
            %        -- 4-element vector of characteristic sizes of the grid cell in
            %           4 dimensions
            %
            opt = {'-3D','-halo','-bin_edges','-bin_centre','-dens_interp',...
                '-plot_edges','-axes_only','-ngrid','-hull'};
            [ok,mess,...
                do_3D,build_halo,bin_edges,bin_centre,dens_interp,...
                plot_edges,axes_only,ngrid,hull,argi] ...
                = parse_char_options(varargin,opt);
            if ~ok
                error('Horace:AxesBlockBase:invalid_argument',mess)
            end
            [nodes,dE_edges,nbin_size,grid_cell_size] = ...
                calc_bin_nodes_(obj,nargout,do_3D, ...
                build_halo,bin_edges,bin_centre,dens_interp,...
                plot_edges,axes_only,ngrid,hull,argi{:});
        end
        %
        function nodes = dE_nodes(obj,varargin)
            % helper function which returns nodes along energy transfer axis
            %
            % Optional:
            % '-bin_centers' -- return bin centers rather then bin edges
            %
            nodes = dE_nodes_(obj,varargin{:});
        end
        %
        function [in,in_details] = in_range(obj,coord)
            %IN_RANGE identifies if the input coordinates lie within the
            %image data range.
            %
            % Inputs:
            % obj           --  Axes block object containing image range
            %
            % coord         -- [NDim x N_coord] vector of coordinates to verify against the
            %                  limits where N_coord is the number of vectors to verify
            % return_in_details
            %               -- if provided and true, return in_details array. (see
            %                  below). If false, in_details will be empty
            % Output:
            % in            -- [1 x N_coord] integer array containing 1 if coord are within
            %                  the min_max_ranges, 0 if it is on the edge and -1 if it
            %                  is outside of the ranges.
            % in_details   --  [NDim x N_coord] array of integers, specifying the same
            %                  as
            range = obj.img_range;
            if size(coord,1)==3
                range = range(:,1:3);
            end
            [in,in_details] = in_range(range,coord,nargout>1);
        end

        function [npix,s,e] = init_accumulators(obj,n_accum,force_3D)
            % Initialize binning accumulators, used during bin_pixels
            % process.
            %
            % Inputs:
            % obj     -- initialized instance of AxesBlockBase class
            % n_accum -- number of accumulator arrays to initialize.
            %            may be 1 or 3 (if naccum~=1, n_accum == 3)
            % force_3D-- if true, return only 3-dimensional
            %            accumulator arrays ignoring last (energy transfer)
            %            dimension.
            %
            % Returns:   Depending on n_accum, 1 or 3 arrays of zeros
            %            if n_accum == 1, two other arrays are empty
            %            The size of the arrays is defined by
            %            obj.dims_as_ssize property's value.
            % npix    -- npix array  initialized to zeros and used to
            %            accumulate pixels present in a bin.
            % s       -- signal array initialized to zeros and used to
            %            accumulate pixels signa in a bin.
            % e       -- error array initialized to zeros and used to
            %            accumulate pixels variance in a bin.
            %
            [npix,s,e] = init_accumulators_(obj,n_accum,force_3D);
        end
    end
    %======================================================================
    % Bunch of properties and methods involved in construction of the
    % plotted image titles
    %----------------------------------------------------------------------
    properties(Access=protected)
        % holder for a function which prints information about projection
        % which is responsible for transformation into particular
        % axes_block. Used in main_title generation.
        proj_description_function_ = [];
    end
    methods(Abstract)
        % return all titles, plotted by axes
        [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis] =...
            data_plot_titles(obj,dnd_obj)
    end
    methods
        function title_main = main_title(obj,title_main_pax,title_main_iax)
            %MAIN_TITLE method generates cellarray containing text to plot above
            % standard 1-3D image of sqw/dnd object containing axes block.
            %
            % Inputs:
            % obj            -- initialized instance of the line_axes object
            % title_main_pax -- cellarray of titles to plot along projection axes.
            %                   Number of elements must be equal to total number of
            %                   projection axes in the object.
            % title_main_iax -- cellarray of titles to plot along integration axes.
            %                   Number of elements must be equal to total number of
            %                   integration axes in the object.
            %
            % Returns:
            % title_main     -- cellarray, containing text to plot above
            %                   1-3D image of the of the object containing line_axes.
            %
            title_main = main_title_(obj,title_main_pax,title_main_iax);
        end
        %
        function obj = add_proj_description_function(obj,a_function_handle_to_proj_info)
            % set function, which prints information about projection
            % responsible for transforming pixels into image with this kind
            % of axes_block
            %
            % Inputs:
            % obj   -- initialized instance of a particular axes_block
            % a_function_handle_to_proj_info
            %       -- a function handle which would print requested
            %          description. Should accept instance of particular
            %          AxesBlockBase object and return string
            %          Empty input clears previously set function if any.
            % Returns:
            %      instance of the class with set function handle provided.
            %
            if isempty(a_function_handle_to_proj_info)
                obj.proj_description_function_ = [];
                return;
            end
            if ~isa(a_function_handle_to_proj_info,'function_handle')
                error('HORACE:AxesBlockBase:invalid_argument', ...
                    'Input for projection description function add method should be a function handle. Provided: %s', ...
                    class(a_function_handle_to_proj_info));
            end
            obj.proj_description_function_  = a_function_handle_to_proj_info;
        end
    end
    %----------------------------------------------------------------------
    methods(Abstract,Access=protected)
        % defines bins used when default constructor with dimensions only is called.
        pbin = default_pbin(obj,ndim)
        % calculate bin volume from the  axes of the axes block or input
        % axis organized in cellarray of 4 axis.
        volume = calc_bin_volume(obj,varargin)
        % retrieve the bin volume scale so that any bin volume be expessed in
        % A^-3*mEv
        vol_scale = get_volume_scale(obj);
    end
    %======================================================================
    methods(Access=protected)
        function  obj = check_and_set_img_range(obj,val)
            % main setter for orthogonal image range.
            % Overloadable for different kind
            % of axes blocks.
            obj = check_and_set_img_range_(obj,val);
        end

        function  [range,nbin,ok,mess]=pbin_parse(obj,p,p_defines_bin_centers,range_limits)
            % take binning parameters and converts them into axes bin ranges
            % and number of bins defining this axes block
            [range,nbin,ok,mess]=pbin_parse_(obj,p,p_defines_bin_centers,range_limits);
        end
        function    obj = check_and_set_type(obj,val)
            % not used in generic projections; overloaded in curvilinear.
            % may be expanded in a future
            obj.type_ = val;
            if numel(obj.type_) == 3
                obj.type_ = [obj.type_(:)','e'];
            end
        end
        function [npix,s,e,pix_cand,unique_runid,argi]=...
                normalize_bin_input(obj,pix_coord_transf,n_argout,varargin)
            % verify inputs of the bin_pixels function and convert various
            % forms of the inputs of this function into a common form,
            % where the missing inputs are returned as empty.
            %
            %Inputs:
            % pix_coord_transf -- the array of pixels coordinates
            %                     transformed into this AxesBlockBase
            %                      coordinate system
            % n_argout         -- number of argument, requested by the
            %                     calling function
            % Optional:
            % Optional:
            % npix or nothing if mode == 1
            % npix,s,e accumulators if mode is [4,5,6]
            % pix_cand  -- if mode == [4,5,6], must be present as a PixelData class
            %              instance, containing information about pixels
            % unique_runid -- if mode == [5,6], input array of unique_runid-s
            %                 calculated on the previous step.
            force_3Dbinning = false;
            if size(pix_coord_transf,1) ==3  % Q(3D) binning only. Third axis is always missing
                force_3Dbinning = true;
            end
            [npix,s,e,pix_cand,unique_runid,argi]=...
                normalize_bin_input_(obj,...
                force_3Dbinning,pix_coord_transf,n_argout,varargin{:});
        end
        function obj = set_axis_bins(obj,ndims,p1,p2,p3,p4)
            % Calculates and sets plot and integration axes from binning information
            %
            %   >> obj=set_axis_bins_(obj,p1,p2,p3,p4)
            % where the routine sets the following object fields:
            % iax,iint,pax,p and dax
            %
            % Input:
            % ------
            %   p1,p2,p3,p4 Binning descriptions
            %               - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
            %               - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
            %               - [pint]                    (interpreted as [pint,pint]
            %               - [] or empty               (interpreted as [0,0]
            %               - scalar numeric cellarray  (interpreted as bin boundaries)
            %
            % Output:
            % -------
            %   Sets up img_range and nbin_all_dim parameters of the axes block, which
            %   in turn define all axes block parameters

            obj=set_axis_bins_(obj,ndims,p1,p2,p3,p4);
        end

    end
    methods(Static,Access = protected)
        function [is_axes,grid_size]= process_bin_volume_inputs(ax_instance,nodes_info,grid_size)
            % general routine used to process inputs for routne, used to calculate bin_volume
            % of different sorts of lattice
            %

            if iscell(nodes_info)
                if  numel(nodes_info) ~=4
                    error('HORACE:AxesBlockBase:invalid_argument', ...
                        'Input for calc_bin_volume function should be cellarray containing 4 axis. It is %s', ...
                        disp2str(nodes_info));
                end
                grid_size = cellfun(@(ax)numel(ax),nodes_info);
                is_axes  = true;
            else
                is_axes  = false;
                if nargin<3
                    grid_size = ax_instance.nbins_all_dims+1;
                end
                if size(nodes_info,1) ~= numel(grid_size)
                    error('HORACE:AxesBlockBase:invalid_argument', ...
                        'first size of nodes_into array (%d) have to be equal to number of grid dimensions %d',...
                        size(nodes_info,1),numel(grid_size));
                end
            end
        end
        function [volume,inodes] = expand_to_dE_grid(volume,dE_nodes,inodes)
            % Epand 3-Dimensional interpolation lattice by orthogonal
            % 1-dimensional dE lattice, returning 4-dimensional lattice as
            % the result
            % Inputs:
            % volime    --   3-dimensional array of lattice grid volumes
            % dE_nodes  --   1-dimensional array of energies used as 4-th
            %                interpolation axis.
            % inodes    --   2-dimensional [3,(size(volume)+1] array of
            %                coordinates of 3-dimensional grid, used for
            %                interpolation
            % Return
            % volume    --   4-dimensional array of lattice grid volumes
            % inodes    --   2-dimensional array of coordinates of
            %                4-dimensional interpolation grid.
            %
            % substantially use fact that dE nodes are dirstributed regularly
            dE     = dE_nodes(2:end)-dE_nodes(1:end-1);
            if ~isempty(volume)
                volume  = reshape(volume(:).*dE(:)',[size(volume),numel(dE)]);
            end
            if nargin>2
                inodes = [repmat(inodes,1,numel(dE_nodes));repelem(dE_nodes,size(inodes,2))];
            else
                inodes = [];
            end
        end

    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    properties(Constant,Access=private)
        % fields which fully represent the state of the class and allow to
        % recover it state by setting properties through public interface
        fields_to_save_ = {'title','filename','filepath',...
            'label','img_scales','img_range','nbins_all_dims','single_bin_defines_iax',...
            'dax','offset','changes_aspect_ratio'};
    end
    %----------------------------------------------------------------------
    % Serializable interface
    methods
        %
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Throw
            % 'HORACE:AxesBlockBase:invalid_argument' if object is invalid.
            obj = check_combo_arg_(obj);
        end
        function flds = saveableFields(~,varargin)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = AxesBlockBase.fields_to_save_;
        end
        %
    end
    methods(Access=protected)
        function [inputs,obj] = convert_old_struct(obj,inputs,ver)
            % Update structure created from earlier class versions to the current
            % version. Converts the bare structure for a scalar instance of an object.
            % Overload this method for customised conversion. Called within
            % from_old_struct on each element of S and each obj in array of objects
            % (in case of serializable array of objects)
            if isfield(inputs,'ulen')
                inputs.img_scale = inputs.ulen;
            end
        end
    end
end
