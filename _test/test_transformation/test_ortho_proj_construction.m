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
        function test_constructor_keys_override_defaults(~)
            proj = ortho_proj([1,0,0],[0,1,0],...
                'alatt',[2,3,4],'type','aaa','nonorthogonal',true,...
                'u',[0,1,0],'v',[1,0,0],'w',[0,0,1]);
            assertEqual(proj.u,[0,1,0]);
            assertEqual(proj.v,[1,0,0]);
            assertEqual(proj.w,[0,0,1]);
            assertEqual(proj.alatt,[2,3,4]);
            assertEqual(proj.angdeg,[90,90,90]);
            assertEqual(proj.type,'aaa');
            assertEqual(proj.nonorthogonal,true);
        end
        
        function test_constructor_type(~)
            proj = ortho_proj([1,0,0],[0,1,0],[0,0,1],...
                'alatt',[2,3,4],'type','aaa');
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0]);
            assertEqual(proj.w,[0,0,1]);
            assertEqual(proj.alatt,[2,3,4]);
            assertEqual(proj.angdeg,[90,90,90]);
            assertEqual(proj.type,'aaa');
        end
        
        
        function test_constructor_third_long_throws(~)
            assertExceptionThrown(...
                @()ortho_proj([1,0,0],[0,1,0],[1,1,1,1],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:ortho_proj:invalid_argument');
        end
        
        function test_constructor_third_zero_throws(~)
            assertExceptionThrown(...
                @()ortho_proj([1,0,0],[0,1,0],[0,0,0],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:ortho_proj:invalid_argument');
        end
        
        function test_three_vector_constructor(~)
            proj = ortho_proj([1,0,0],[0,1,0],[0,0,1],...
                'alatt',[2,3,4],'angdeg',[80,70,85]);
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0]);
            assertEqual(proj.w,[0,0,1]);
            assertEqual(proj.alatt,[2,3,4]);
            assertEqual(proj.angdeg,[80,70,85]);
        end
        
        function test_incorrect_constructor_throws_on_positional_zero(~)
            assertExceptionThrown(...
                @()ortho_proj([0,0,0],1,'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:ortho_proj:invalid_argument');
        end
        
        function test_incorrect_constructor_throws_on_positional(~)
            assertExceptionThrown(...
                @()ortho_proj([1,0,0],1,'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:ortho_proj:invalid_argument');
        end
        
        function test_incorrect_constructor_throws_on_combo(~)
            assertExceptionThrown(...
                @()ortho_proj([1,0,0],[1,0,0],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:ortho_proj:invalid_argument');
        end
        
        function test_set_wrong_u(~)
            proj = ortho_proj([1,0,0],[0,1,0],'alatt',[2,3,4],'angdeg',[80,70,85]);
            proj.u = [0,1,0];
            assertTrue(ischar(proj.u));
            assertExceptionThrown(@()isvalid(proj),'HORACE:ortho_proj:runtime_error');
        end
        function test_serialization(~)
            proj = ortho_proj([1,0,0],[0,1,0],'alatt',[2,3,4],'angdeg',[80,70,85]);
            
            ser = proj.serialize();
            rec = serializable.deserialize(ser);
            
            assertEqual(proj,rec);
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
        function test_get_projection(~)
            
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
