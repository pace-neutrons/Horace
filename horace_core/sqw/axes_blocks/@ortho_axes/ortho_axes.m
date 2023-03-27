classdef ortho_axes < AxesBlockBase
    % The class contains information about axes and scales used for
    % displaying sqw/dnd object and provides scales for neutron image data.
    %
    % It also contains main methods, used to produce physical image of the
    % sqw/dnd object
    %
    % Construction:
    %1) ab = ortho_axes(num) where num belongs to [0,1,2,3,4];
    %2) ab = ortho_axes([min1,step1,max1],...,[min4,step4,max4]); - 4 binning
    %                                          parameters
    %        or
    %   ab = ortho_axes([min1,max1],...,[min4,max4]); - 4 binning
    %                                          parameters
    %        or any combination of ranges [min,step,max] or [min,max]
    %3) ab = ortho_axes(structure) where structure contains any fields
    %                              returned by savebleFields method
    %4) ab = ortho_axes(param1,param2,param3,'key1',value1,'key2',value2....)
    %        where param(1-n) are the values of the fields in the order
    %        fields are returned by saveableFields function.
    %5) ab = ortho_axes('img_range',img_range,'nbins_all_dims',nbins_all_dims)
    %    -- particularly frequent case of building axes block (case 4)
    %       from the image range and number of bins in all directions.
    properties(Dependent)
        nonorthogonal % true, if the coordinate system described by
        %             % this axes block is non-orthogonal

        unit_cell     % four-vector describing primary unit cell of the
        % lattice. eye(4) in nonorthogonal == false and
        % four-vector of the cell vectors for non-orthogonal
    end
    properties(Dependent,Hidden)
        % old interface to label
        ulabel
    end
    properties(Access=protected)
        %
        nonorthogonal_ = false
        %
        unit_cell_ = [];
    end

    methods
        function obj = ortho_axes(varargin)
            % constructor
            %
            %>>obj = ortho_axes() % return empty axis block
            %>>obj = ortho_axes(ndim) % return unit block with ndim
            %                           dimensions
            %>>obj = ortho_axes(p1,p2,p3,p4) % build axis block from axis
            %                                  arrays
            %>>obj = ortho_axes(pbin1,pbin2,pbin3,pbin4) % build axis block
            %                                       from binning parameters
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
            [obj,offset,remains] = init@AxesBlockBase(obj,varargin{:});
        end

        function [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis] =...
                data_plot_titles(~,dnd_obj)
            % Get titling and caption information for an sqw data structure
            data = dnd_obj.head();
            [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis]=...
                data_plot_titles(data);
        end

        function cell = get.unit_cell(obj)
            if isempty(obj.unit_cell_)
                cell = eye(4);
            else
                cell = obj.unit_cell_;
            end
        end
        function obj = set.unit_cell(obj,val)
            obj = check_and_set_unit_cell_(obj,val);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %------------------------------------------------------------------
        % old interface
        function obj = set.ulabel(obj,val)
            obj.label = val;
        end
        function lab = get.ulabel(obj)
            lab  = obj.label_;
        end
        function non = get.nonorthogonal(obj)
            non = obj.nonorthogonal_;
        end
        function obj = set.nonorthogonal(obj,val)
            obj.nonorthogonal_ = logical(val);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function input = convert_old_struct_into_nbins(input)
            % the function, used to convert old v1 ortho_axes structure,
            % containing axes information, into the v2 structure,
            % containing only range and bin numbers
            input = convert_old_struct_into_nbins_(input);
        end
        function img_range = calc_img_db_range(ax_data)
            % LEGACY FUNCTION, left for compatibility with old binary sqw
            % files for transforming the data, stored there into modern
            % ortho_axes form
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
    %----------------------------------------------------------------------
    methods(Access=protected)
        function  volume = calc_bin_volume(obj,axis_cell)
            % calculate bin volume from the  axes of the axes block or input
            % axis organized in cellarray of 4 axis.
            volume = calc_bin_volume_(obj,axis_cell);
        end

        function  obj = check_and_set_img_range(obj,val)
            % main setter for orthogonal image range.
            obj = check_and_set_img_range_(obj,val);
        end
        function pbin = default_pbin(~,ndim)
            % method is called when default constructor with dimensions is invoked
            % and defines default binning in this situation
            rest = arrayfun(@(x)zeros(1,0),1:4-ndim,'UniformOutput',false);
            pbin=[repmat({[0,1]},1,ndim),rest];
        end
        function  [range,nbin]=pbin_parse(obj,p,p_defines_bin_centers,i)
            % take binning parameters and converts them into axes bin ranges
            % and number of bins defining this axes block
            [range,nbin]=pbin_parse_(obj,p,p_defines_bin_centers,i);
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function ax = get_from_old_data(input)
            % supports getting axes block from the data, stored in binary
            % Horace files versions 3 and lower.
            ax = ortho_axes();
            ax = ax.from_old_struct(input);
        end
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class
            obj = ortho_axes();
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
            ver = 6;
        end
        %
        function flds = saveableFields(obj,varargin)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = saveableFields@AxesBlockBase(obj);
            if nargin>1 || obj.nonorthogonal
                flds = [flds(:);'nonorthogonal';'unit_cell'];
            else
                flds = [flds(:);'nonorthogonal'];
            end
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Throw
            % 'HORACE:AxesBlockBase:invalid_argument' if object is invalid.
            obj = check_combo_arg@AxesBlockBase(obj);
            if obj.nonorthogonal_ && isempty(obj.unit_cell_)
                error('HORACE:ortho_axes:invalid_argument',...
                    ['Unit cell have to be set for non-orthogonal ortho_axes.\n', ...
                    ' Set up non-orthogonal unit cell before setting nonorthogonal property to true\n']);
            end
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
                inputs = ortho_axes.convert_old_struct_into_nbins(inputs);
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
