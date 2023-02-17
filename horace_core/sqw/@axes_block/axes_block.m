classdef axes_block < serializable
    % The class contains information about axes and scales used for
    % displaying sqw/dnd object and provides scales for neutron image data.
    %
    % It also contains main methods, used to produce physical image of the
    % sqw/dnd object
    %
    % Construction:
    %1) ab = axes_block(num) where num belongs to [0,1,2,3,4];
    %2) ab = axes_block([min1,step1,max1],...,[min4,step4,max4]); - 4 binning
    %                                          parameters
    %        or
    %   ab = axes_block([min1,max1],...,[min4,max4]); - 4 binning
    %                                          parameters
    %        or any combination of ranges [min,step,max] or [min,max]
    %3) ab = axes_block(structure) where structure contains any fields
    %                              returned by savebleFields method
    %4) ab = axes_block(param1,param2,param3,'key1',value1,'key2',value2....)
    %        where param(1-n) are the values of the fields in the order
    %        fields are returned by saveableFields function.
    %5) ab = axes_block('img_range',img_range,'nbins_all_dims',nbins_all_dims)
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
        dimensions;  % Number of axes_block object dimensions
        %
        % binning along each dimension of an object assuming that
        % all objects are 4-dimensional one. E.g. 1D object in with 10 bins in
        % x-direction would have binning [10,1,1,1] and 1D object with 10
        % bins in dE direction would have binning [1,1,1,10];
        nbins_all_dims;
        % number of bins for each non-unit dimension. This would be the
        % binning of the data arrays associated with the given axes_block
        data_nbins;
        % number of bins in each non-unit dimension presented in the form,
        % which allows you to allocate an array of the appropriate size
        % i.e. size(s) == dims_as_ssize and size(zeros(dims_as_ssize)) ==
        % size(s)
        dims_as_ssize;
        % boolean row, identifying if a single bin direction
        % (nbins_all_dims(dir)==1) is integration axis or a projection
        % axis. By default, single nbins_all_dims direction is
        % integration direction.
        % If the index is false in a direction, where more then one bin
        % is defined, the input binning parameters in this direction
        % are treated as bin edges rather then bin centres.
        single_bin_defines_iax;
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
        img_range_      = ... % 2x4 vector of min/max values in 4-dimensions
            PixelDataBase.EMPTY_RANGE_; % [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf]

        nbins_all_dims_ = [1,1,1,1];    % number of bins in each dimension
        single_bin_defines_iax_ = true(1,4); % true if single nbin direction represents integration axis
        dax_=[];                        % display axes numbers holder
        % e.g. r.l.u. and energy [h; k; l; en] [row vector]
    end
    properties(Dependent,Hidden)
        % old interface to label
        ulabel
        full_filename % convenience property as fullfile(filepath, filename)
        % are often used
    end

    methods
        % return binning range of existing data object, so that cut without
        % parameters, performed within this range would return the same cut
        % as the original object
        range = get_cut_range(obj,varargin);
        % find the coordinates along each of the axes of the smallest cuboid
        % that contains bins with non-zero values of contributing pixels.
        [val, n] = data_bin_limits (obj);
        %
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
            obj.do_check_combo_arg_ = false;
            [obj,offset,remains] = init_(obj,varargin{:});
            obj.do_check_combo_arg_ = true;
            obj = check_combo_arg(obj);
        end
        %
        function [cube_coord,step] = get_axes_scales(obj)
            % Return the array of vertices of a 4D hypercube, describing a
            % grid cell of the axes block.
            % Output:
            % cube_coord -- 4x16 array of vertices of minimal-sized axes
            %               cube. (Cubes sizes differ in case if axes
            %               contains different sized grid, e.g.
            %               cylindrical grid)
            % step       -- 4x1 vector, containing the axes block grid
            %               steps. (change of the coordinates in each
            %               direction, the length of the each side of the
            %               axes cell hypercube)
            [cube_coord,step] = get_axes_scales_(obj);
        end
        function volume = get_bin_volume(obj)
            % return the volume of the axes grid. For rectilinear grid, the
            % volume of the grid is the single value equal to the product
            % of the grid step array obtained from get_axes_scales
            % function, because all grid cells of such grid are equal.
            % For other coordinate systems (e.g. spherical), the volume is
            % 1D array of the cells, with the volume, dependent on the cell
            % radius
            [~,step] = obj.get_axes_scales();
            volume = prod(step);
        end
        function data_out = rebin_data(obj,data_in,other_ax)
            % Rebin data,defined on this axes grid into other axes grid
            %
            % The other axes grid has to be aligned with this axes block
            % according to realigh_axes method of this axes block
            data_out = rebin_data_(obj,data_in,other_ax);
        end
        function ax_block_al = realign_bin_edges(obj,ax_block)
            % align input axes block to have the same or commensurate
            % bin sizes as this axes block and the integration ranges equal
            % or smaller than the ranges of this axes block but
            % commensurate with this axis block bin edges
            ax_block_al = realign_bin_edges_(obj,ax_block);
        end
        %
        function [interp_points,density,cell_sizes] = get_density(obj,datasets)
            % Convert input datasets defined on centerpoints of this grid
            % into the density data, defined on edges of the grid.
            %
            % Inputs:
            % datasets -- cellarray of input datasets to calculate density
            %             from.
            %             The size and dimensions of the datasets should
            %             be equal to the dimensions of the axes block
            %             returned by data_nbins property, i.e.:
            %             all(size(dataset{i}) == obj.data_nbins;
            %             datasets contain bin values.
            % Returns:
            % intep_pints
            %          -- 2D [4,nAxesEdgesPoints] array of axes positions
            %              where the density is defined
            % density
            %          -- cellarray of density points calculated in the
            %             density points positions.
            %             Number of cells in the output array is equal to
            %             the number of input datasets
            % cell_sizes
            %          -- 4-elements vector containing the sizes of the
            %             cell (to be extended on heterogheneous cell)
            %
            if ~iscell(datasets)
                datasets = {datasets};
            end
            [interp_points,density,cell_sizes] = calculate_density_(obj,datasets);
        end
        %
        function [s,e,npix] = interpolate_data(obj,ref_nodes,density,varargin)
            % interpolate density data for signal, error and number of
            % pixels provided as input density and defined on the nodes of the
            % references axes block onto the grid, defined by this axes block.
            %
            % Inputs:
            % ref_nodes -- 4D array of the nodes of the reference lattice,
            %              produced by get_density routine of the reference
            %              axes block.
            % density   -- 3-elements cellarray containing arrays of
            %              signal, error and npix densities,
            %              produced by get_density routine of the reference
            %              axes block.
            % Optional:
            % grid_cell_size
            %           -- 4D array of the scales of the reference lattice
            %              if missing or empty, assume ref_nodes have the same
            %              cell sizes as these nodes
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
            if nargin < 5
                proj = [];
            else
                proj = varargin{2};
            end
            if nargin < 4
                grid_cell_size = [];
            else
                grid_cell_size = varargin{1};
            end
            [s,e,npix] = interpolate_data_(obj,nargout,ref_nodes, ...
                density,grid_cell_size,proj);
        end
        %
        function [npix,s,e,pix_ok,unique_runid,pix_indx] = bin_pixels(obj,coord_transf,varargin)
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
            [npix,s,e,pix_ok,unique_runid,pix_indx] = bin_pixels_(obj,coord_transf,mode,...
                npix,s,e,pix_cand,unique_runid,argi{:});
        end
        %
        function [nodes,dE_edges,nbin_size,grid_cell_size] = ...
                get_bin_nodes(obj,varargin)
            % build 3D or 4D vectors, containing all nodes of the axes_block grid,
            % constructed over axes_block axes points.
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
            % '-data_to_density'
            %           -- if provided, returns grid used to define density,
            %              namely with points located on the grid cell edges +
            %              edges of integrated  dimensions.
            % '-density_integr'
            %           -- if provided, returns grid used for integration
            %              by summation in centerpoints, namely, points
            %              are in the center of cells and integration
            %              dimensions
            % Returns:
            % nodes     -- [4 x nBins] or [3 x nBins] array of points,
            %              (depending on state of '-3D' switch)  where
            %              the coordinate of each point is a node of the
            %              grid, formed by axes_block axes.
            % Optional:
            % dE_edges  -- if '-3D' switch is present, coordinates of the
            %              energy transfer grid, empty if not
            % nbin_size -- 4-elements vector, containing numbers of axes
            %              nodes in each of 4 directions
            % grid_cell_size
            %        -- 4-element vector of characteristic sizes of the grid cell in
            %           4 dimensions
            %
            opt = {'-3D','-halo','-data_to_density','-density_integr'};
            [ok,mess,do_3D,build_halo,data_to_density,density_inegr_grid,argi] = parse_char_options(varargin,opt);
            if ~ok
                error('Horace:axes_block:invalid_argument',mess)
            end
            if density_inegr_grid && data_to_density
                error('Horace:axes_block:invalid_argument',...
                    '"-interpolation" and "-extrapolation" keys can not be used together')
            end
            [nodes,dE_edges,nbin_size,grid_cell_size] = ...
                calc_bin_nodes_(obj,do_3D, ...
                build_halo,data_to_density,density_inegr_grid,argi{:});
        end
        %
        function range = get_binning_range(obj,cur_proj,new_proj)
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
            if ~(ischar(fn) || isstring(fn))
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
            if ~(ischar(fp) || isstring(fp))
                error('HORACE:axes_block:invalid_argument',...
                    'filepath should be defined of array of characters or by a string')
            end
            obj.filepath_ = fp;
        end
        function fn = get.full_filename(obj)
            fn = fullfile(obj.filepath_,obj.filename_);
        end
        function obj = set.full_filename(obj,fn)
            if ~(ischar(fn) || isstring(fn))
                error('HORACE:axes_block:invalid_argument',...
                    'full_filename should be defined of array of characters or by a string. It is %s', ...
                    disp2str(fn));
            end
            [fp,fn,fe] = fileparts(fn);
            obj.filename_ = [fn,fe];
            obj.filepath_ = fp;
        end

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
            obj = check_and_set_img_range_(obj,val);
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
            if min(val(:))~=1
                error('HORACE:axes_block:invalid_argument',...
                    'A display axis should refer the first projection axis')
            end
            obj.dax_ = val(:)';
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
                error('HORACE:axes_block:invalid_argument', ...
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
        % old interface
        function obj = set.ulabel(obj,val)
            obj.label = val;
        end
        function lab = get.ulabel(obj)
            lab  = obj.label_;
        end
    end
    methods(Access=protected)

        function [npix,s,e,pix_cand,unique_runid,argi]=...
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
            % Optional:
            %
            grid_size = obj.dims_as_ssize();
            if size(pix_coord_transf,1) ==3  % Q(3D) binning only. Third axis is always missing
                grid_size = obj.nbins_all_dims;
                grid_size = grid_size(1:3);
            end
            [npix,s,e,pix_cand,unique_runid,argi]=...
                axes_block.normalize_binning_input(...
                grid_size,pix_coord_transf,n_argout,varargin{:});
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function input = convert_old_struct_into_nbins(input)
            % the function, used to convert old v1 axes_block structure,
            % containing axes information, into the v2 structure,
            % containing only range and bin numbers
            input = convert_old_struct_into_nbins_(input);
        end
        % build new axes_block object from the binning parameters, provided
        % as input. If some input binning parameters are missing, the
        % defaults are taken from the given image range which should be
        % properly prepared
        obj = build_from_input_binning(cur_img_range_and_steps,pbin);
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
        function img_range = calc_img_db_range(ax_data)
            % LEGACY FUNCTION, left for compatibility with old binary sqw
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
        %
        function [npix,s,e,pix_cand,unique_runid,argi]=...
                normalize_binning_input(grid_size,pix_coord_transf,n_argout,varargin)
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
            % Optional:

            [npix,s,e,pix_cand,unique_runid,argi]=...
                normalize_bin_input_(grid_size,pix_coord_transf,n_argout,varargin{:});
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=private)
        % fields which fully represent the state of the class and allow to
        % recover it state by setting properties through public interface
        fields_to_save_ = {'title','filename','filepath',...
            'label','ulen','img_range','nbins_all_dims','single_bin_defines_iax',...
            'dax','nonorthogonal','axis_caption'};
    end    
    methods(Static)
        function ax = get_from_old_data(input)
            % supports getting axes block from the data, stored in binary
            % Horace files versions 3 and lower.
            ax = axes_block();
            ax = ax.from_old_struct(input);
        end
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = axes_block();
            obj = loadobj@serializable(S,obj);
        end
    end    
    %----------------------------------------------------------------------
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw/sqw data format. Each new version would presumably
            % read the older version, so version substitution is based on
            % this number
            ver = 5;
        end
        %
        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = axes_block.fields_to_save_;
        end
        %
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Throw
            % 'HORACE:axes_block:invalid_argument' if object is invalid.
            obj = check_combo_arg_(obj);
        end
        %        
    end
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case where the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % Overloaded to accept Horace 3.6.2<version structure.
            %
            if isfield(inputs,'version') && (inputs.version == 1) || ...
                    isfield(inputs,'iint')
                inputs = axes_block.convert_old_struct_into_nbins(inputs);
            end
            if isfield(inputs,'one_nb_is_iax')
                inputs.single_bin_defines_iax = inputs.one_nb_is_iax;
                inputs = rmfield(inputs,'one_nb_is_iax');
            end
            if isfield(inputs,'array_dat')
                obj = obj.from_bare_struct(inputs.array_dat);
            else
                obj = obj.from_bare_struct(inputs);
            end
        end
        
    end
end
