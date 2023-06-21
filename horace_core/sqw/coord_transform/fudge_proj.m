classdef fudge_proj < ortho_proj
    % Fudge projection introuduced as fudge to fix resolution plot.
    %
    % TODO: clarify and make it the proper projection. Ticket #840
    properties
        spec_to_rlu;
    end

    methods
        function obj = fudge_proj(varargin)
            obj = obj@ortho_proj(varargin{:})
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

    end
end