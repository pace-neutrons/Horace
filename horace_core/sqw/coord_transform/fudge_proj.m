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
    end
end