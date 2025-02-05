classdef sphere_proj<CurveProjBase
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts.
    %
    % Usage (with positional parameters):
    %
    % >>sp = sphere_proj(); %default construction
    % >>sp = sphere_proj(u,v);
    % >>sp = sphere_proj(u,v,type);
    % >>sp = sphere_proj(u,v,type,alatt,angdeg);
    % >>sp = sphere_proj(u,v,type,alatt,angdeg,offset,label,title);
    %
    % Where:
    % u  -- [1,3] vector of hkl direction of z-axis of the spherical
    %        coordinate system this projection defines.
    %        The axis to calculate theta angle from.
    % v  -- [1,3] vector of hkl direction of x-axis of the spherical
    %       coordinate system, the axis to calculate Phi angle from.
    %       If u directed along the beam as in gen_sqw, [u,v] defines Horace
    %       rotation plane.
    % type-- 3-letter character array, defining the spherical
    %        coordinate system units (see type property below)
    % alatt-- 3-vector of lattice parameters. Value will be ignored by cut.
    % angdeg- 3-vector of lattice angles. Value will be ignored by cut.
    % offset- 4-vector, defining hkldE value of centre of
    %         coordinates of the spherical coordinate
    %         system.
    % label - 4-element cellarray, which defines axes labels
    % title - character string to title the plots of cuts, obtained
    %         using this projection.
    %
    % all parameters may be provided as 'key',value pairs appearing in
    % arbitrary order after positional parameters
    % e.g.:
    % >>sp = sphere_proj([1,0,0],[0,1,0],'arr','offset',[1,1,0]);
    % >>sp = sphere_proj([1,0,0],'type','arr','v',[0,1,0],'offset',[1,1,0]);
    %
    % Default angular coordinates names and meaning of the coordinate system,
    % defined by sphere_proj are chosen as follows:
    % |Q|     -- coordinate 1 is the modulus of the scattering momentum.
    % theta   -- coordinate 2, the angle between axis u
    %            and the direction of the Q.
    % phi     -- coordinate 3 is the angle between the projection of the
    %            scattering vector to the plane defined by vector v and
    %            perpendicular to u.
    % dE      -- coordinate 4 the energy transfer direction
    %
    % parent's class "type" property describes which scales are avaliable for
    % each direction:
    % for |Q|:
    % 'a' -- Angstrom,
    % 'r' -- scale = max(\vec{u}*\vec{e_h,e_k,e_l}) -- projection of u to
    %                                       unit vectors in hkl directions
    % 'p' -- |u| = 1 -- i.e. scale = |u|
    % 'h','k' or 'l' -- i.e. scale = (a*,b* or c*);
    % for angular units theta, phi:
    % 'd' - degree, 'r' -- radians
    % For energy transfer:
    % 'e'-energy transfer in meV (no other scaling so may be missing)
    %
    properties(Constant,Access = private)
        % cellarray describing what letters are available to assign for
        % projection type property.
        types_available_ = {{'a','p','r','h','k','l'},{'d','r'},{'d','r'}};
    end

    methods
        function obj=sphere_proj(varargin)
            % Constrtuctor for spherical projection
            % See init for the list of input parameters
            %
            obj = obj@CurveProjBase();
            obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_;
            obj.label = {'|Q|','\theta','\phi','En'};
            obj.curve_proj_types_ = obj.types_available_;
            obj.type_ = 'pdd';
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %------------------------------------------------------------------
        % Particular implementation of aProjectionBase abstract interface
        %------------------------------------------------------------------
        function pix_transformed = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in crystal Cartesian coordinate systems
            % into spherical coordinate system defined by the object
            % properties
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system
            %             or instance of PixelDatBase class containing this
            %             information.
            % Returns:
            % pix_out -- [3xNpix or [4xNpix]Array the pixels coordinates
            %            transformed into spherical coordinate system
            %            defined by object properties
            %
            pix_transformed = transform_pix_to_spher_(obj,pix_data);
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (spherical) coordinate system
            % into crystal Cartesian system of pixels
            pix_cc = transform_spher_to_pix_(obj,pix_transformed,varargin{:});
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
            % 'a' -- Angstrom,
            % 'r' -- scale = max(\vec{u}*\vec{e_h,e_k,e_l}) -- projection of u to
            %                                       unit vectors in hkl directions
            % 'p' -- |u| = 1 -- i.e. scale = |u|
            % 'h','k' or 'l' -- i.e. scale = (a*,b* or c*);
            % for angular units theta, phi:
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
        %------------------------------------------------------------------
        function ver  = classVersion(~)
            ver = 2;
        end
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class. Useful for recovering class from a structure
            obj = sphere_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
end
