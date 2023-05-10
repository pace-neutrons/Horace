classdef ortho_projTester < ortho_proj
    %  Helper class to test protected ortho-proj methods
    %----------------------------------------------------------------------
    properties(Dependent)
        ortho_ortho_transf_mat;
        ortho_ortho_offset;
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
            [rlu_to_ustep, u_to_rlu, ulen] = obj.uv_to_rot(ustep);
        end
        %
        function [u,v,w,type]=uv_from_data_rot_public(obj,u_to_rlu,ustep)
            if nargin == 1
                ustep = [1,1,1];
            end
            [u,v,w,type] = obj.uv_from_data_rot(u_to_rlu,ustep);
        end
        %
        function mat=get.ortho_ortho_transf_mat(obj)
            mat = obj.ortho_ortho_transf_mat_;
        end
        function sh=get.ortho_ortho_offset(obj)
            sh = obj.ortho_ortho_offset_;
        end
        %
    end
end
