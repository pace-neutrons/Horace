classdef sphere_proj<CurveProjBase
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts.
    %
    % TODO: #954 NEEDS verification:
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
    %
    properties(Constant,Access = private)
        % cellarray describing what letters are available to assign for
        % type properties.
        % 'a' -- Angstrom, 'd' - degree, 'r' -- radians, e-energy transfer in meV;
        types_available_ = {'a',{'d','r'},{'d','r'}};
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
            if isempty(obj.img_scales_cache_)
                img_scales = ones(1,3);
                if obj.type_(2) == 'r' 
                    img_scales(2) = 1;
                else                  % theta_to_ang
                    img_scales(2) = 180/pi;
                end
                if obj.type_(3) == 'r'
                    img_scales(3) = 1;
                else                  % phi_to_ang
                    img_scales(3) = 180/pi;
                end
                obj.img_scales_cache_ = img_scales;
            else
                img_scales = obj.img_scales_cache_;
            end
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
