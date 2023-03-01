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
        % expressed in Anstrom, radian, degree, mEv
        capt_units = containers.Map({'a','r','d','e'}, ...
            {[char(197),'^{-1}'],'rad','^{o}','mEv'})
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
            obj.label = {'|Q|','\theta','\phi','En'};
            obj.changes_aspect_ratio_ = false;
        end
        function [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis] =...
                data_plot_titles(obj,dnd_obj)
            % Get titling and caption information for the sqw data
            % structure containing spherical projection
            proj = dnd_obj.proj;
            [title_main, title_pax, title_iax, display_pax, display_iax,energy_axis]=...
                data_plot_titles_(obj,proj);
        end

    end
    %----------------------------------------------------------------------
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
        end
        %
    end
end
