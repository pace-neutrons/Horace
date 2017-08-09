classdef test_projection_class<TestCase
    % The test class to verify how projection works
    %
    properties
        tests_folder
        par_file
        %en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs
        fake_sqw_par = {[],'','',35.5,1,[4.4,5.5,6.6],[100,105,110],...
            [1.02,0.99,0.02],[0.025,-0.01,1.04],...
            90,10.5,0.2,3-1/6,2.4+1/7};                
    end
    
    methods
        function this=test_projection_class(varargin)
            if nargin == 0
                name = 'test_projection_class';
            else
                name = varargin{1};
            end            
            this=this@TestCase(name);
            this.tests_folder = fileparts(fileparts(mfilename('fullpath')));
            this.par_file=fullfile( this.tests_folder,'test_sqw','gen_sqw_96dets.nxspe');
            
            efix = this.fake_sqw_par{4};
            en = 0.05*efix:0.2+1/50:0.95*efix;
            this.fake_sqw_par{1} = en;
            this.fake_sqw_par{2} = this.par_file;            
        end
        function test_constructor(this)
            proj = projection();
            assertEqual(proj.u,'dnd-X-aligned')
            assertEqual(proj.v,'dnd-Y-aligned')
            assertElementsAlmostEqual(proj.uoffset,[0;0;0;0])
            assertEqual(proj.type,'aaa')
            assertTrue(isempty(proj.w))
            
            f = @()projection([0,1,0]);
            assertExceptionThrown(f,'PROJAXES:invalid_argument');
            
            proj = projection([0,1,0],[1,0,0]);
            assertElementsAlmostEqual(proj.u,[0,1,0])
            assertElementsAlmostEqual(proj.v,[1,0,0])
            assertTrue(isempty(proj.w))
            
            prja = projaxes([1,0,0],[0,1,1],[0,-1,1]);
            proj = projection(prja);
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,1])
            assertElementsAlmostEqual(proj.w,[0,-1,1])
        end
        function test_set_u_transf(this)
            proj = projection();
            data = struct();
            data.alatt = [2,3,4];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = eye(4); %(4x4)
            data.uoffset = zeros(1,4);      %(4x1)
            upix_to_rlu = eye(3);
            upix_offset = zeros(4,1);
            data.ulabel = {'a','b','c','d'};
            data.ulen = ones(4,1);
            data.iax=[];
            data.pax=[1,2,3,4];
            data.iint=[];
            data.p={1:10;1:20;1:30;1:40};
            
            
            proj=proj.retrieve_existing_tranf(data,upix_to_rlu,upix_offset);
        end
        function test_set_can_mex_keep(this)
            proj = projection();
            assertTrue(proj.can_mex_cut);
        end
        function test_cut(this)
            hc = hor_config();
            cur_mex = hc.use_mex;
            hc.use_mex = 0;
            clob = onCleanup(@()set(hor_config,'use_mex',cur_mex));
            [w, grid_size, urange]=fake_sqw (this.fake_sqw_par{:});
            w = dnd(w{1});
            %w = w{1};
            %wc = cut_dnd(w,0.01,0.01,[-0.1,0.1],2);
        end
        
    end
end
