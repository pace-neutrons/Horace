classdef cylinder_proj<CurveProjBase
    % Class defines cylindical coordinate projection, used by cut_sqw
    % to make cylindical cuts.
    %
    % Default angular coordinates names and meanings are chosen as follows:
    % Q_tr    -- coordinate 1  is the module of the component of the momentum
    %            transfer orthogonal to the direction, selected by property
    %            e_z  of this class. e_z property is expressed in hkl and
    %            defines direction of e_z axis of cylindrical coordinate
    %            system. Horace has default beam direction along axis
    %            [1,0,0] so default crystalographic direction of e_z axis is
    %            [1,0,0] because the secondary symmetry of the instrument
    %            image would be cylindrical symmetry around beam direction
    % Q_||    -- coordinate 2 is the component of the momentum Q, (Q_||)
    %            directed along the selected e_z axis.
    % phi     -- coordinate 3 is the angle between x-axis of the cylindrical
    %            coordinate system and the projection of the momentum transfer
    %            (Q_tr) to the xy plain of the cylindircal coordinate
    %            system
    % dE      -- coordinate 4 the energy transfer direction
    %
    %
    properties(Constant,Access = private)
        % cellarray describing what letters are available to assign for
        % type properties.
        % 'a' -- Angstrom, 'd' - degree, 'r' -- radians, e-energy transfer in meV;
        types_available_ = {'a','a',{'d','r'}};
    end

    methods
        function obj=cylinder_proj(varargin)
            % Constrtuctor for spherical projection
            % See init for the list of input parameters
            %
            obj = obj@CurveProjBase();
            % Default projection type: A^{-1}, A^{-1}, degree
            obj.type_ = 'aad';
            obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_;
            obj.label = {'Q_{tr}','\Q_{||}','\phi','En'};
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
            pix_transformed = transform_pix_to_cylinder_(obj,pix_data);
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (spherical) coordinate system
            % into crystal Cartesian system of pixels
            pix_cc = transform_cylinder_to_pix_(obj,pix_transformed,varargin{:});
        end
    end
    methods(Access=protected)
        function [img_scales,obj] = get_img_scales(obj)
            if isempty(obj.img_scales_cache_)
                img_scales = ones(1,3);
                if obj.type_(3) == 'r'
                    img_scales(3) = 1;
                else
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
        function ver  = classVersion(~)
            ver = 1;
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
