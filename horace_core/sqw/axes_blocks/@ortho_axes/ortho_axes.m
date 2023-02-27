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
        %
        %TODO: Its here temporary, until full projection is stored in sqw obj
        nonorthogonal % if the coordinate system is non-orthogonal.
    end
    properties(Dependent,Hidden)
        % old interface to label
        ulabel
    end
    properties(Access=protected)
        % handle to function calculating axes captions
        caption_calc_func_;
        %
        nonorthogonal_ = false
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

        %------------------------------------------------------------------
        % old interface
        function obj = set.ulabel(obj,val)
            obj.label = val;
        end
        function lab = get.ulabel(obj)
            lab  = obj.label_;
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
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=private)
        % fields which fully represent the state of the class and allow to
        % recover it state by setting properties through public interface
        fields_to_save_ = {'nonorthogonal'};
    end
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
        function flds = saveableFields(obj)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = saveableFields@AxesBlockBase(obj);
            flds = [flds(:);ortho_axes.fields_to_save_(:)];
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
