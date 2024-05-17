classdef sphere_proj<CurveProjBase
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts.
    %
    % Default angular coordinates names and meanings are chosen according
    % to the conventions of inelastic spectrometry, i.e.:
    % |Q|     -- coordinate 1 is the module of the scattering momentum,
    % theta   -- coordinate 2, the angle between the beam direction (k_i)
    %            and the direction of the Q,
    % phi     -- coordinate 3 is the angle between the projection of the
    %            scattering vector to the instrument plane (perpendicular
    %            to k_i) and the crystal rotation plane.
    % dE      -- coordinate 4 the energy transfer direction
    %
    % paten class "type" property describes which scales are avaliable for
    % each direction:
    % for |Q|:
    % 'a' -- Angstrom,
    % 'r' -- max(\vec{u}*\vec{h,k,l}) = 1
    % 'p' -- |u| = 1
    % 'h','k' or 'l' -- \vec{Q}/(a*,b* or c*) = 1;
    % for angular units theta, phi:
    % 'd' - degree, 'r' -- radians
    % For energy transfer:
    % 'e'-energy transfer in meV (no other scaling so may be missing)
    %
    properties(Constant,Access = private)
        % cellarray describing what letters are available to assign for
        % type properties.
        types_available_ = {{'a','p','h','k','l'},{'d','r'},{'d','r'}};
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
            obj.type_ = 'add';
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
            % 'r' -- max(\vec{u}*\vec{h,k,l}) = 1
            % 'p' -- |u| = 1
            % 'h','k' or 'l' -- \vec{Q}/(a*,b* or c*) = 1;
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
