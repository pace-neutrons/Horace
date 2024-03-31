classdef cylinder_axes < AxesBlockBase
    properties(Constant,Access = private)
        % What units each possible dimension type of the spherical projection
        % have:  Currently momentum, angle, and energy transfer may be
        % expressed in Anstrom, radian, degree, meV. The key is the type
        % letter present in cylinder_projection and the value is the unit
        % caption.
        capt_units = containers.Map({'a','r','d','e'}, ...
            {[char(197),'^{-1}'],'rad','^{o}','meV'})
        default_img_range_ =[ ...
            0,-1,-180,-1;...  % the range, a object defined with dimensions
            1  1, 180, 1];    % only would have
        % what symbols axes_units can have
        types_available_ = {'a','a',{'d','r'},'e'};

    end
    properties(Dependent)
        % what each axes units are
        axes_units
        % if angular dimensions of the axes are expressed in radians or degrees
        angular_unit_is_rad

    end
    properties(Dependent,Hidden)
        % the range used for cylinder_axes by default
        default_img_range
    end

    properties(Access = protected)
        % if angular dimensions of the axes are expressed in radians or degrees
        angular_unit_is_rad_ = false;
        axes_units_ = 'aade';
    end
    properties(Access=private)
        % helper properties used in setting angular units image range and
        % the meaning of the angular units. If both image_range and
        % old_angular_unit_is_rad changed, you have set up the range
        % and its meaning.
        % If only angular_unit_is_rad have changed, the image range have to
        % be recalculated from degree to radians of v.v..
        old_angular_unit_is_rad_  = [];
        img_range_set_            = false;
    end

    methods
        %
        function obj = cylinder_axes(varargin)
            % constructor
            %
            %>>obj = cylinder_axes() % return empty axis block
            %>>obj = cylinder_axes(ndim) % return unit block with ndim
            %                           dimensions
            %>>obj = cylinder_axes(p1,p2,p3,p4) % build axis block from axis
            %                                  arrays
            %>>obj = cylinder_axes(pbin1,pbin2,pbin3,pbin4) % build axis block
            %                                       from binning parameters
            %

            obj.max_img_range_ = [...
                0  ,-inf,-180, -inf;...
                inf, inf, 180,  inf];
            % empty spherical range:
            obj.img_range_ = obj.default_img_range_;

            obj.label = {'Q_{tr}','\Q_{||}','\phi','En'};
            obj.changes_aspect_ratio_ = false;
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
            [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis]=...
                data_plot_titles_(obj);
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
        function val = get.axes_units(obj)
            val = obj.axes_units_;
        end
        function obj = set.axes_units(obj,val)
            obj = set_axes_units_(obj,val);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function range = get.default_img_range(obj)
            range  = obj.default_img_range_;
            if obj.angular_unit_is_rad_
                range(:,3) = deg2rad(range(:,3));
            end
        end
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        function  volume = calc_bin_volume(obj,axis_cell)
            % calculate bin volume from the  axes of the axes block or input
            % axis organized in cellarray of 4 axis. Will return array of
            % bin volumes
            volume = calc_bin_volume_(obj,axis_cell);
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
            obj = cylinder_axes();
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
                ax_unit = {'a','a','d','e'};
                if inputs.angular_unit_is_rad
                    ax_unit{3} = 'r';
                end
                inputs.axes_units = [ax_unit{:}];
            end
            obj = obj.from_bare_struct(inputs);
        end
    end
end
