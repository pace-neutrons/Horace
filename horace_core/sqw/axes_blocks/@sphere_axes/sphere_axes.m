classdef sphere_axes < AxesBlockBase
    % The class contains information about axes and scales used for
    % displaying sqw/dnd object and provides scales for neutron image data
    % when the data are analysed in spherical coordinate system
    %
    % It also contains main methods, used to produce physical image of the
    % sqw/dnd object
    %
    % Construction:
    %1) ab = sphere_axes(num) where num belongs to [0,1,2,3,4];
    %2) ab = sphere_axes([min1,step1,max1],...,[min4,step4,max4]); - 4 binning
    %                                          parameters
    %        or
    %   ab = sphere_axes([min1,max1],...,[min4,max4]); - 4 binning
    %                                          parameters
    %        or any combination of ranges [min,step,max] or [min,max]
    %3) ab = sphere_axes(structure) where structure contains any fields
    %                              returned by savebleFields method
    %4) ab = sphere_axes(param1,param2,param3,'key1',value1,'key2',value2....)
    %        where param(1-n) are the values of the fields in the order
    %        fields are returned by saveableFields function.
    %5) ab = sphere_axes('img_range',img_range,'nbins_all_dims',nbins_all_dims)
    %    -- particularly frequent case of building axes block (case 4)
    %       from the image range and number of bins in all directions.
    %Note:
    %       Unlike line_axes, the img_range in the case of
    %       spherical axes should lie within alowed limits (0-inf for rho
    %       [0,pi] for theta and [-pi, pi] for phi.
    properties(Constant,Access = private)
        % What units each possible dimension type of the spherical projection
        % have:  Currently momentum, angle, and energy transfer may be
        % expressed in Anstrom, radian, degree, meV. The key is the type
        % letter present in sphere_projection and the value is the unit
        % caption.
        capt_units = containers.Map({'a','p','r','h','k','l','r','d','e'},{...
            [char(197),'^{-1}'],[char(197),'^{-1}'],[char(197),'^{-1}'], ...
            [char(197),'^{-1}'],[char(197),'^{-1}'],[char(197),'^{-1}'], ...
            'rad','^{o}','meV'})
        default_img_range_ =[ ...
            0,   0, -180, -1;...  % the range, a object defined with dimensions
            1 ,180,  180,  1];    % only would have
        % what symbols axes_units can have
        types_available_ = {{'a','p','r','h','k','l'},{'d','r'},{'d','r'},'e'};

    end
    properties(Dependent)
        % if angular dimensions of the axes are expressed in radians or degrees
        angular_unit_is_rad
    end
    properties(Dependent,Hidden)
        % the range used for cylinder_axes by default
        default_img_range
    end

    properties(Access = protected)
        % if angular dimensions of the axes are expressed in radians or degrees
        angular_unit_is_rad_ = [false,false];
    end
    properties(Access=private)
        % helper properties used in setting angular units image range and
        % the meaning of the angular units. If both image_range and
        % old_angular_unit_is_rad changed, you have set up the range
        % and its meaning.
        % If only angular_unit_is_rad have changed, the image range have to
        % be recalculated from degree to radians of v.v..
        old_angular_unit_is_rad_  = [];
        img_range_set_        = false;
    end

    methods
        %
        function obj = sphere_axes(varargin)
            % constructor
            %
            %>>obj = sphere_axes() % return empty axis block
            %>>obj = sphere_axes(ndim) % return unit block with ndim
            %                           dimensions
            %>>obj = sphere_axes(p1,p2,p3,p4) % build axis block from axis
            %                                  arrays
            %>>obj = sphere_axes(pbin1,pbin2,pbin3,pbin4) % build axis block
            %                                       from binning parameters
            %
            % Maximal possible img_range to check against:
            obj.max_img_range_ = [...
                0  ,  0, -180, -inf;...
                inf,180,  180,  inf];
            %
            obj.img_range_ = obj.default_img_range_;
            %
            obj.label = {'|Q|','\theta','\phi','En'};
            obj.type_ = 'adde';
            obj.changes_aspect_ratio_ = false;
            obj = obj.add_proj_description_function(...
                @(x)sprintf('Spherical projection at centre: %s(hklE)',mat2str(x.offset)));            
            if nargin == 0
                return;
            end

            obj = obj.init(varargin{:});
        end
        %
        function [obj,offset,remains] = init(obj,varargin)
            % initialize object with axis parameters.
            %
            % The parameters are defined as in constructor
            % and accepts range of positional variables or key-value pairs
            % as defined by saveableFields function.
            %
            % Returns:
            % obj    -- initialized by inputs axis_block object
            % offset -- the offset for axis box from the origin of the
            %            coordinate system
            % remains -- the arguments, not used in initialization if any
            %            were provided as input
            %
            if nargin == 1
                return;
            end
            [is_changed,new_value] = check_angular_units_changed_(obj,varargin{:});
            if is_changed
                obj.angular_unit_is_rad =new_value;
            end
            [obj,offset,remains] = init@AxesBlockBase(obj,varargin{:});

        end
        function [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis] =...
                data_plot_titles(obj)
            % Get titling and caption information for the sqw data
            % structure containing spherical projection
            [title_pax, title_iax,title_main_pax,title_main_iax, display_pax, display_iax,energy_axis]=...
                data_plot_titles_(obj);
            % Main title
            title_main = obj.main_title(title_main_pax,title_main_iax);
            
        end
        %
        function anr = get.angular_unit_is_rad(obj)
            anr = obj.angular_unit_is_rad_;
        end
        function obj = set.angular_unit_is_rad(obj,val)
            obj = set_angles_in_rad_(obj,val);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        %
        function range = get.default_img_range(obj)
            range  = obj.default_img_range_;
            for i=1:2
                if obj.angular_unit_is_rad_(i)
                    range(:,1+i) = deg2rad(range(:,1+i));
                end
            end
        end
    end
    % s
    methods
        function [in,in_details] = in_range(obj,coord)
            %IN_RANGE identifies if the input coordinates lie within the
            %image data range.
            [in,in_details] = in_range@AxesBlockBase(obj,coord);
            % check if some coord have radius 0 and range have radius 0.
            % these coordinates are in range regardless of angles range
            if any(in~=1) && obj.img_range(1,1)==0
                r_eq_0 = coord(1,:) == 0;
                if any(r_eq_0)
                    in_details(1:3,r_eq_0) = 0;
                    equal = in_details == 0;
                    in(any(equal,1))   = 0;
                end
            end
        end
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        function  volume = calc_bin_volume(obj,grid_info,varargin)
            %calculate the volume of a lattice cell defined by the
            %cellarray of grid axes or array of coordinates of the grid nodes.
            %
            % The volume is either single value if all axes bins are the same or the
            % 1D array of size of total number of bins in the lattice if some cell
            % volumes differ or prod(grid_size-1) array of volumes if nodes_info is
            % array
            %
            % Inputs:
            % nodes_info   --
            %       either:   4-element cellarray containing grid axes coordinates
            %       or    :   3xN-elememts or 4xN-elements array of grid nodes
            %                 produced by ndgrid function and combined into single
            %                 array
            % grid_size    -- if nodes_info is provided as array, 3 or 4 elements array
            %                 containing sizes of the grid for the grid nodes in this
            %                 array. Ignored if nodes_info contains axes.
            % Output:
            % volume       -- depending on input, single value or array of grid volumes
            %                 measured in A^-3*mEv
            volume = calc_bin_volume_(obj,grid_info,varargin{:});
        end
        function vol_scale = get_volume_scale(obj)
            % retrieve the bin volume scale so that bin volume of any image
            % based on this axes be expessed in A^-3*mEv
            vol_scale = obj.img_scales(1).^3;
        end
        function  obj = check_and_set_img_range(obj,val)
            % main setter for spherical image range.
            obj = check_and_set_img_range_(obj,val);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function pbin = default_pbin(obj,ndim)
            % method is called when default constructor with dimensions is invoked
            % and defines default empty binning for dimension-only
            % construction
            pbin = default_pbin_(obj,ndim);
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class
            obj = sphere_axes();
            obj = loadobj@serializable(S,obj);
        end
    end
    %----------------------------------------------------------------------
    methods
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            obj = check_combo_arg@AxesBlockBase(obj);
            %
            obj = check_angular_units_consistency_(obj);
        end

        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw/sqw data format. Each new version would presumably
            % read the older version, so version substitution is based on
            % this number
            ver = 3;
        end
        %
        function flds = saveableFields(obj,varargin)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = saveableFields@AxesBlockBase(obj);
            flds = [flds(:);'axes_units'];
        end
        %
    end
    methods(Access=protected)
        function obj = from_old_struct(obj,inputs)
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain a version or the version, stored
            % in the structure does not correspond to the current version
            % of the class.
            if isfield(inputs,'angular_unit_is_rad')
                ax_unit = {'a','d','d','e'};
                if inputs.angular_unit_is_rad(1)
                    ax_unit{2} = 'r';
                end
                if inputs.angular_unit_is_rad(2)
                    ax_unit{3} = 'r';
                end
                inputs.axes_units = [ax_unit{:}];
            end
            obj = obj.from_bare_struct(inputs);
        end
    end
end
