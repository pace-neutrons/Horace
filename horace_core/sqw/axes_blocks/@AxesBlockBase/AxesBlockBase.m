classdef AxesBlockBase < serializable
    % The class contains information about axes and scales used for
    % displaying sqw/dnd object and provides scales for neutron image data.
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
        title;      % Title of sqw data structure, displayed on plots.
        filename;   % Name of sqw file that is being read, excluding path. Used in titles
        filepath;   % Path to sqw file that is being read, including terminating file separator.
        %            Used in titles
        % the cellarray of captions, displayed along various axes of plots
        label;    % labels for u1,u2,u3,u4 as cell array
        %               e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
        %                   *OR*
        %   access or set up the axes label separately using their indexes,
        %   i.e.:
        %   label{1}  label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
        %   label{2}  label for u2 axis
        %   label{3}  label for u3 axis
        %   label{4}  label for u4 axis (e.g. 'E' or 'En')

        iax;      %Index of integration axes into the projection axes  [row vector]
        %          Always in increasing numerical order
        %                  e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
        iint; %Integration range along each of the integration axes. [iint(2,length(iax))]
        %     e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
        pax;   %Index of plot axes into the projection axes  [row vector]
        %      Always in increasing numerical order
        %      e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
        %      2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
        dax;    %Index into data.pax of the axes for display purposes. For example we may have
        %      data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
        %      the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
        %      the display axes to be permuted but without the contents of the fields p, s,..pix needing to
        %      be reordered [row vector]
        p;     %Cell array containing bin boundaries along the plot axes [column vectors]
        %      i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
        %------------------------------------------------------------------
        %
        ulen;   %Length of projection axes vectors in Ang^-1 or meV [row vector]
        %
        % The range (in axes coordinate system), the binning is made and the
        % axes block describes
        img_range;
        %
        dimensions;  % Number of AxesBlockBase object dimensions
        %
        % binning along each dimension of an object assuming tha
        % all objects are 4-dimensional one. E.g. 1D object in with 10 bins in
        % x-direction would have binning [10,1,1,1] and 1D object with 10
        % bins in dE direction would have binning [1,1,1,10];
        nbins_all_dims;
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

        % property defines if appropriate axes block presented on
        % picture changes aspect ratio of a 2D image, so that equal
        % physical ranges along axes occupy equal pixel ranges on the image
        %
        % May be set up locally on an object but have defaults specific for
        % each axes block
        changes_aspect_ratio;
    end

    properties(Access=protected)
        title_   =''   % Title of sqw data structure
        filename_=''   % Name of sqw file that is being read, excluding path. Used in titles
        filepath_=''   % Path to sqw file that is being read, including terminating file separator.
        %               Used in titles
        label_  = {'Q_h','Q_k','Q_l','En'}; %Labels of the projection axes [1x4 cell array of character strings]
        ulen_=[1,1,1,1]         %Length of projection axes vectors in Ang^-1 or meV [row vector]
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
    end
    properties(Dependent,Hidden)
        full_filename % convenience property as fullfile(filepath, filename)
        % are often used
        % Old name for img_range left for compartibility with old user code
        img_db_range;
    end

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
            if isempty(sz)      ; sz = [1,1];
            elseif numel(sz) ==1; sz = [sz,1];
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
            if ~istext(fn)
                error('HORACE:AxesBlockBase:invalid_argument',...
                    'full_filename should be defined of array of characters or by a string. It is %s', ...
                    disp2str(fn));
            end
            [fp,fn,fe] = fileparts(fn);
            obj.filename_ = [fn,fe];
            obj.filepath_ = fp;
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
        %
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
            ul = obj.ulen_;
        end
        function obj = set.ulen(obj,val)
            if isnumeric(val) && numel(val) == 3
                val = [val(:)',1];
            end
            if ~(isnumeric(val) && numel(val) == 4)
                error('HORACE:AxesBlockBase:invalid_argument',...
                    'ulen should be vector, containing 4 elements')
            end
            obj.ulen_ = val(:)';
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

    end
    %======================================================================
    % Integration, interpolation and binning
    methods
        % return binning range of existing data object, so that cut without
        % parameters, performed within this range would return the same cut
        % as the original object
        range = get_cut_range(obj,varargin);
        %

        function volume = get_bin_volume(obj,varargin)
            % Return the volume(s) of the axes grid. For rectilinear grid, the
            % volume of the grid is the scalar equal to the product
            % of the grid steps in all directions.
            % For the coordinate systems where grid volumes depend on
            % the grid number (e.g. spherical), the volume is
            % 1D array of the volumes of the cells. The number of elements
            % in the array is equal to the number of cells in the grid.
            % Inputs:
            % obj   -- initialized instance of an axes_block class
            % Optional:
            % axes  -- 4-element celarray, containig axes in all 4
            %          directions. If this argument is present, the
            %          volume(s) are calculated for the grid, buil from
            %          the axes provided as input.
            if nargin == 1
                [~,~,~,volume] = obj.get_bin_nodes('-axes_only');
            elseif nargin == 2
                volume = obj.calc_bin_volume(varargin{1});
            else
                error('HORACE:AxesBlockBase:invalid_argument', ...
                    'This method accepts no or one argument. Called with %d arguments', ...
                    nargin);
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
        function [npix,s,e,pix_ok,unique_runid,pix_indx,ok] = bin_pixels(obj,coord_transf,varargin)
            % Bin and distribute data expressed in the coordinate system
            % described by this axes block over the current N-D lattice
            %
            % Usage:
            % >>npix = obj.bin_pixels(coord_transf);
            % >>[npix,s,e] = obj.bin_pixels(coord_transf,npix,s,e);
            % >>[npix,s,e,pix_ok,unque_runid] = bin_pixels(obj,coord_transf,npix,s,e,pix_candidates)
            % >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord_transf,npix,s,e,pix_candidates)
            % >>[npix,s,e,pix_ok,unque_runid,pix_indx] = bin_pixels(obj,coord_transf,npix,s,e,pix_candidates,unique_runid);
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
            % -nomex and -force_mex options can not be used together.
            % '-return_ok' -- For DnD only cuts returns `ok` in `pix_ok`
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
            % ok     -- numerical array of indices of selected pixels after
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
            [npix,s,e,pix_ok,unique_runid,pix_indx,ok] = bin_pixels_(obj,coord_transf,mode,...
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
            % obj         -- initialized version of the axes block
            % Optional:
            %  char_cube -- the cube, describing the scale of the grid,
            %               to construct the lattice on, defined by its
            %               minimal and maximal points (4x2 matrix)
            %  or         --
            %               char_size directly (4x1 vector), describing the
            %               scales along each axis the lattice should have
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
                '-axes_only','-ngrid','-hull'};
            [ok,mess,...
                do_3D,build_halo,bin_edges,bin_centre,dens_interp,...
                axes_only,ngrid,hull,argi] ...
                = parse_char_options(varargin,opt);
            if ~ok
                error('Horace:AxesBlockBase:invalid_argument',mess)
            end
            [nodes,dE_edges,nbin_size,grid_cell_size] = ...
                calc_bin_nodes_(obj,nargout,do_3D, ...
                build_halo,bin_edges,bin_centre,dens_interp,...
                axes_only,ngrid,hull,argi{:});
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
    end
    methods(Abstract,Access=protected)
        % main setter for image range. Overloadable for different kind
        % of axes blocks.
        obj = check_and_set_img_range(obj,val);
        % defines bins used when default constructor with dimensions only is called.
        pbin = default_pbin(obj,ndim)
        % takes binning parameters converts it into axis binning for the
        % given axes
        [range,nbin]=pbin_parse(obj,p,p_defines_bin_centers,i)
        % calculate bin volume from the  axes of the axes block or input
        % axis organized in cellarray of 4 axis.

        volume = calc_bin_volume(obj,axis_cell)
    end
    %======================================================================
    methods(Access=protected)
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
            %
            grid_size = obj.dims_as_ssize();
            if size(pix_coord_transf,1) ==3  % Q(3D) binning only. Third axis is always missing
                grid_size = obj.nbins_all_dims;
                grid_size = grid_size(1:3);
            end
            [npix,s,e,pix_cand,unique_runid,argi]=...
                AxesBlockBase.normalize_binning_input(...
                grid_size,pix_coord_transf,n_argout,varargin{:});
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
        function [npix,s,e,pix_cand,unique_runid,argi]=...
                normalize_binning_input(grid_size,pix_coord_transf,n_argout,varargin)
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

            [npix,s,e,pix_cand,unique_runid,argi]=...
                normalize_bin_input_(grid_size,pix_coord_transf,n_argout,varargin{:});
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    properties(Constant,Access=private)
        % fields which fully represent the state of the class and allow to
        % recover it state by setting properties through public interface
        fields_to_save_ = {'title','filename','filepath',...
            'label','ulen','img_range','nbins_all_dims','single_bin_defines_iax',...
            'dax','changes_aspect_ratio'};
    end

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
end
