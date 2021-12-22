classdef test_ortho_proj_construction<TestCase
    % The test class to verify how projection works
    %
    properties
        tests_folder
    end
    
    methods
        function this=test_ortho_proj_construction(varargin)
            if nargin == 0
                name = 'test_ortho_proj_construction';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end
        %------------------------------------------------------------------
        function test_default_constructor(~)
            proj = ortho_proj();
            assertElementsAlmostEqual(proj.u,[0.5/pi,0,0])
            assertElementsAlmostEqual(proj.v,[0,0.5/pi,0])
            assertElementsAlmostEqual(proj.w,[0,0,0.5/pi])
            assertElementsAlmostEqual(proj.offset,[0,0,0,0])
            assertEqual(proj.type,'ppp')
            full_box = expand_box([0,0,0,0],[1,1,1,1]);
            pixi = proj.transform_pix_to_img(full_box );
            assertElementsAlmostEqual(full_box,pixi);
            pixi = proj.transform_img_to_pix(full_box );
            assertElementsAlmostEqual(full_box,pixi);
        end
        %
        function test_invalid_constructor_throw(~)
            f = @()ortho_proj([0,1,0]);
            assertExceptionThrown(f,'HORACE:ortho_proj:invalid_argument');
        end
        %
        function test_uv_set_in_constructor(~)
            proj = ortho_proj([0,1,0],[1,0,0]);
            assertElementsAlmostEqual(proj.u,[0,1,0])
            assertElementsAlmostEqual(proj.v,[1,0,0])
            assertTrue(isempty(proj.w))
        end
        %
        function test_uvw_set_in_constructor(~)
            proj = ortho_proj([1,0,0],[0,1,1],[0,-1,1]);
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,1])
            assertElementsAlmostEqual(proj.w,[0,-1,1])
        end
        %
        function test_set_u_transf(~)

            data = struct();
            data.alatt = [2,3,4];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = eye(4); %(4x4)
            data.uoffset = zeros(1,4);      %(4x1)
            data.ulabel = {'a','b','c','d'};
            data.ulen = ones(4,1);
            data.iax=[];
            data.pax=[1,2,3,4];
            data.iint=[];
            data.p={1:10;1:20;1:30;1:40};
            do = data_sqw_dnd(data);
            
            proj = ortho_proj('alatt',data.alatt,'angdeg',data.angdeg,...
                'lab',{'a','b','c','d'});
            
            proj1=do.get_projection();
            assertEqual(proj,proj1)
        end
        %------------------------------------------------------------------
        function test_set_can_mex_keep(~)
            proj = ortho_proj();
            assertTrue(proj.can_mex_cut);
        end
    end
end
