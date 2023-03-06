classdef spher_axes < AxesBlockBase
    % The class contains information about axes and scales used for
    % displaying sqw/dnd object and provides scales for neutron image data
    % when the data are analyzed in spherical coordinate system
    %
    % It also contains main methods, used to produce physical image of the
    % sqw/dnd object
    %
    % Construction:
    %1) ab = spher_axes(num) where num belongs to [0,1,2,3,4];
    %2) ab = spher_axes([min1,step1,max1],...,[min4,step4,max4]); - 4 binning
    %                                          parameters
    %        or
    %   ab = spher_axes([min1,max1],...,[min4,max4]); - 4 binning
    %                                          parameters
    %        or any combination of ranges [min,step,max] or [min,max]
    %3) ab = spher_axes(structure) where structure contains any fields
    %                              returned by savebleFields method
    %4) ab = spher_axes(param1,param2,param3,'key1',value1,'key2',value2....)
    %        where param(1-n) are the values of the fields in the order
    %        fields are returned by saveableFields function.
    %5) ab = spher_axes('img_range',img_range,'nbins_all_dims',nbins_all_dims)
    %    -- particularly frequent case of building axes block (case 4)
    %       from the image range and number of bins in all directions.
    properties(Constant,Access = private)
        % What units each possible dimension type of the spherical projection
        % have:  Currently momentum, angle, and energy transfer may be
        % expressed in Anstrom, radian, degree, mEv. The key is the type
        % letter present in spher_projection and the value is the unit
        % caption.
        capt_units = containers.Map({'a','r','d','e'}, ...
            {[char(197),'^{-1}'],'rad','^{o}','mEv'})
        default_img_range_ = ...
            [0,  0,-180,0;...  % the range, a object defined with dimensions
            1 ,180, 180,1];    % only would have

    end
    properties(Dependent)
        % if angular dimensions of the axes are expressed in radians or degrees
        angular_unit_is_rad
    end
    properties(Dependent,Hidden)
        % if angular dimensions of the axes are expressed in radians or degrees
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
        function obj = spher_axes(varargin)
            % constructor
            %
            %>>obj = spher_axes() % return empty axis block
            %>>obj = spher_axes(ndim) % return unit block with ndim
            %                           dimensions
            %>>obj = spher_axes(p1,p2,p3,p4) % build axis block from axis
            %                                  arrays
            %>>obj = spher_axes(pbin1,pbin2,pbin3,pbin4) % build axis block
            %                                       from binning parameters
            %

            obj.max_img_range_ = ...
                [0 ,  0,-180,-inf;...
                inf,180, 180, inf];
            % empty spherical range:
            obj.img_range_ = [obj.max_img_range_(2,:);obj.max_img_range_(1,:)];

            obj.label = {'|Q|','\theta','\phi','En'};
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
                data_plot_titles(obj,dnd_obj)
            % Get titling and caption information for the sqw data
            % structure containing spherical projection
            proj = dnd_obj.proj;
            [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis]=...
                data_plot_titles_(obj,proj);
        end
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
        function range = get.default_img_range(obj)
            range  = obj.default_img_range_;
            for i=1:2
                if obj.angular_unit_is_rad_(i)
                    range(:,1+i) = deg2rad(range(:,1+i));
                end
            end
        end
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
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
        function  [range,nbin]=pbin_parse(obj,p,p_defines_bin_centers,i)
            % takes binning parameters and converts it into axis binning
            % for the given axiss
            [range,nbin]=pbin_parse_(obj,p,p_defines_bin_centers,i);
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class
            obj = spher_axes();
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
            ver = 1;
        end
        %
        function flds = saveableFields(obj)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = saveableFields@AxesBlockBase(obj);
            flds = [flds(:);'angular_unit_is_rad'];
        end
        %
    end
end
