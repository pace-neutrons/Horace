classdef cylinder_proj<CurveProjBase
    % Class defines cylindical coordinate projection, used by cut_sqw
    % to make cylindical cuts.
    %
    % Usage (with positional parameters):
    %
    % >>sp = cylinder_proj(); %default construction
    % >>sp = cylinder_proj(u,v);
    % >>sp = cylinder_proj(u,v,type);
    % >>sp = cylinder_proj(u,v,type,alatt,angdeg);
    % >>sp = cylinder_proj(u,v,type,alatt,angdeg,offset,label,title);
    %
    % Where:
    % u  -- [1,3] vector of hkl direction of z-axis of the cylindrical
    %       coordinate system this projection defines.
    %       Defines direction of z-axis of cylindrical projection.
    % v  -- [1,3] vector of hkl direction of x-axis of the cylindrical
    %       coordinate system, the axis to calculate Phi angle from.
    %       If u directed along the beam as in gen_sqw, [u,v] defines Horace
    %       rotation plane.
    % type-- 3-letter character array, defining the cylindrical
    %        coordinate system units (see type property below)
    % alatt-- 3-vector of lattice parameters. Value will be ignored by cut.
    % angdeg- 3-vector of lattice angles. Value will be ignored by cut.
    % offset- 4-vector, defining hkldE value of centre of
    %         coordinates of the cylindrical coordinate
    %         system.
    % label - 4-element cellarray, which defines axes labels
    % title - character string to title the plots of cuts, obtained
    %         using this projection.
    %
    % all parameters may be provided as 'key',value  pairs appearing in
    % arbitrary order after positional parameters.
    % e.g.:
    % >>sp = cylinder_proj([1,0,0],[0,1,0],'aar','offset',[1,1,0]);
    % >>sp = cylinder_proj([1,0,0],'type','aar','v',[0,1,0],'offset',[1,1,0]);
    %
    % Default angular coordinates names and meaning of the coordinate system,
    % defined by cylinder_proj are chosen as follows:
    % Q_{\perp}-- coordinate 1  is the modulus of the component of the momentum
    %             transfer orthogonal to the direction defined by property
    %             u of this class. u property is expressed in hkl and
    %             defines direction of e_z axis of cylindrical coordinate
    %             system.
    %             Horace has default beam direction along axis [1,0,0]
    %             so default crystalographic direction of e_z axis is
    %             [1,0,0] because the secondary symmetry of the instrument
    %             image would be cylindrical symmetry around beam direction
    % Q_||    --  coordinate 2 is the component of the momentum Q, (Q_||)
    %             directed along the selected by property u axis (e_z axis
    %             of cylindrical coordinates).
    % phi     --  coordinate 3 is the angle between x-axis of the cylindrical
    %             coordinate system and the projection of the momentum transfer
    %             (Q_{\perp}) to the plane of the cylindircal coordinate
    %             system defined by vector v and perpendicular to u.
    % dE      --  coordinate 4 the energy transfer direction
    %
    % parent's class "type" property describes which scales are avaliable for
    % each direction:
    % for |Q|:
    % 'a' -- Angstrom,
    % 'r' -- max(\vec{u}*\vec{e_h,e_k,e_l}) = 1 -- projection of u or v to
    %                                       unit vectors in hkl directions
    % 'p' -- scale == length of vector u or v
    %  (depending on settings type(1)== 'p' or type(2)=='p')
    % 'h','k' or 'l' -- scale in selected direction (1 or 2) == (a*,b* or c*);
    % for angular units theta, phi:
    % 'd' - degree, 'r' -- radians
    % For energy transfer:
    % 'e'-energy transfer in meV (no other scaling so may be missing)
    %
    properties(Constant,Access = private)
        % cellarray describing what letters are available to assign for
        % projection type property.
        types_available_ = {{'a','p','r','h','k','l'},{'a','p','r','h','k','l'},{'d','r'}};
    end

    methods
        function obj=cylinder_proj(varargin)
            % Constrtuctor for spherical projection
            % See init for the list of input parameters
            %
            obj = obj@CurveProjBase();
            % Default projection type: A^{-1}, A^{-1}, degree
            obj.type_ = 'ppd';
            obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_;
            obj.label = {'Q_{\perp}','Q_{||}','\phi','En'};
            obj.curve_proj_types_ = obj.types_available_;
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        %------------------------------------------------------------------
        function pix_transformed = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in crystal Cartesian coordinate systems
            % into cylindrical coordinate system defined by the object
            % properties
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in Crystal Cartesian coordinate system
            %             or instance of PixelDatBase class containing this
            %             information.
            % Returns:
            % pix_out -- [3xNpix or [4xNpix] array of the pixels coordinates
            %            transformed into cylindrical coordinate system
            %            defined by the object properties
            %
            pix_transformed = transform_pix_to_cylinder_(obj,pix_data);
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (cylindrical) coordinate system
            % into Crystal Cartesian system of pixels
            pix_cc = transform_cylinder_to_pix_(obj,pix_transformed,varargin{:});
        end
    end

    methods(Access=protected)
        function [img_scales,obj] = get_img_scales(obj)
            % Calculate image scales using projection type
            % input:
            % obj -- initialized sphere_proj object with defined lattice
            %        and "type" - property containing acceptable 3-letter
            %        type code.
            % Returns:
            % img_scales  -- 1x3 elements array, containing scaling factors
            %                for every scaled direction, namely:
            % for |Q|:
            % 'r' -- max(\vec{u}*\vec{e_h,e_k,e_l}) = 1 -- projection of u or v to
            %                                       unit vectors in hkl directions
            % 'p' -- scale == length of vector u or v
            %  (depending on settings type(1)== 'p' or type(2)=='p')
            % 'h','k' or 'l' -- scale in selected direction (1 or 2) == (a*,b* or c*);
            % 'd' - degree, 'r' -- radians
            % For energy transfer:
            % 'e'-energy transfer in meV (no other scaling so may be missing)

            [img_scales,obj] = get_img_scales_(obj);
        end
    end
    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    methods
        function ver  = classVersion(~)
            ver = 2;
        end
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class. Useful for recovering class from a structure
            obj = cylinder_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
end
