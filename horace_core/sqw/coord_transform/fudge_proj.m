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
            % overloadavble accessor for getting value for ub matrix
            % property
            if isempty(obj.spec_to_rlu)
                mat = get_u_to_rlu_mat@ortho_proj(obj);
            else
                mat = obj.spec_to_rlu;
                mat = [mat,[0;0;0];[0,0,0,1]];
            end
        end
    end
end