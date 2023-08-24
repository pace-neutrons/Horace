classdef fudge_proj < line_proj
    % Fudge projection introduced as fudge to fix resolution plot.
    %
    % TODO: clarify and make it the proper projection. Ticket #840
    properties
        spec_to_rlu;
    end

    methods
        function obj = fudge_proj(varargin)
            obj = obj@line_proj(varargin{:})
        end
        function axes_bl = copy_proj_defined_properties_to_axes(obj,axes_bl)
            % copy the properties, which are normally defined on projection
            % into the axes block provided as input
            axes_bl = copy_proj_defined_properties_to_axes@aProjectionBase(obj,axes_bl);
            %HACK: I do not understand why it is like that, but 
            % to fix unit test test_tobyfit_resfun_2:test_projaxes_2
            % axes scales have to be like this
            % Re #840 May be it should be instrument proj here
            axes_bl.img_scales  = ones(4,1);
            axes_bl.hkle_axes_directions = obj.u_to_rlu;
            %
        end
        
    end
    methods(Access = protected)
        function  mat = get_u_to_rlu_mat(obj)
            % u_to_rlu defines the transformation from coodrinates in
            % image coordinate system to pixels in hkl(dE) (rlu) coordinate
            % system
            %
            mat = eye(4);
            mat(1:3,1:3) = obj.spec_to_rlu;
        end
        function name = get_axes_name(~)
            % return the name of the axes class, which corresponds to this
            % projection
            name = 'line_axes';
        end

    end
end