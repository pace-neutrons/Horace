classdef ortho_projTester < ortho_proj
    %  Helper class to test non-abstract aProjection methods
    %----------------------------------------------------------------------
    properties(Access=protected)
    end
    
    methods
        function obj=ortho_projTester(varargin)
            obj = obj@ortho_proj(varargin{:});
        end
        %
        function [rlu_to_ustep, u_to_rlu, ulen]=projaxes_to_rlu_public(obj,ustep)
            if nargin == 1
                ustep = [1,1,1];
            end
            [rlu_to_ustep, u_to_rlu, ulen] = obj.uv_to_rlu(ustep);
        end
        %
        function [u,v]=uv_from_rlu_public(obj,u_to_rlu,ustep)
            if nargin == 1
                ustep = [1,1,1];
            end
            [u,v] = obj.uv_from_rlu(u_to_rlu,ustep);
        end
        %
    end
    %
end
