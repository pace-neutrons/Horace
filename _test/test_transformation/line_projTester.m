classdef line_projTester < line_proj
    %  Helper class to test protected ortho-proj methods
    %----------------------------------------------------------------------
    properties(Dependent)
        ortho_ortho_transf_mat;
        ortho_ortho_offset;
    end
    
    methods
        function obj=line_projTester(varargin)
            obj = obj@line_proj(varargin{:});
        end
        %
        function [rlu_to_u, u_to_rlu, ulen]=projaxes_to_rlu_public(obj,varargin)
            [rlu_to_u, u_to_rlu, ulen] = u_to_rlu_legacy_from_uvw(obj,obj.u,obj.v,obj.w,obj.type,obj.nonorthogonal);
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
        function obj = build_from_old_struct_public(obj,inputs,varargin)
            % Restore object from the legacy structure, stored in old sqw
            % files
            obj = obj.from_old_struct(inputs,varargin{:});
        end
    end
end
