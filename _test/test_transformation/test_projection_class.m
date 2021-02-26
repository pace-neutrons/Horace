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
            this.par_file=fullfile( this.tests_folder,'common_data','gen_sqw_96dets.nxspe');
            
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
            [w, grid_size, pix_range]=fake_sqw (this.fake_sqw_par{:});
            w = dnd(w{1});
            %w = w{1};
            %wc = cut_dnd(w,0.01,0.01,[-0.1,0.1],2);
        end
        function test_uv_to_rlu_and_vv_complex_nonorth_with_rrr(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = projaxes(u,v,'type','rrr');
            %pra.nonorthogonal = true;
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu(...
                alatt,angdeg);
            %
            % but recovered the values, correspontent to ppr?
            [u_par,v_par] = projection.uv_from_rlu_mat(alatt,angdeg,u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par);
            % find part of the v vector, orthogonal to u
            b_mat = bmatrix(alatt,angdeg);
            eu_cc = b_mat*u';
            eu = eu_cc/norm(eu_cc);
            % convert to crystal Cartesian
            v_cc = b_mat*v';
            
            v_along =eu*(eu'*v_cc);
            v_tr = (b_mat\(v_cc-v_along))';
            % this part should be recovered from the u_to_rlu matrix
            assertElementsAlmostEqual(v_tr,v_par);
        end
        
        %
        function test_uv_to_rlu_and_vv_complex_nonorthogonal(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = projaxes(u,v);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu(...
                alatt,angdeg);
            
            [u_par,v_par] = projection.uv_from_rlu_mat(alatt,angdeg,u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par);
            % find part of the v vector, orthogonal to u
            b_mat = bmatrix(alatt,angdeg);
            eu_cc = b_mat*u';
            eu = eu_cc/norm(eu_cc);
            % convert to crystal Cartesian
            v_cc = b_mat*v';
            
            v_along =eu*(eu'*v_cc);
            v_tr = (b_mat\(v_cc-v_along))';
            % this part should be recovered from the u_to_rlu matrix
            assertElementsAlmostEqual(v_tr,v_par);
        end
        %
        function test_uv_to_rlu_and_vv_simple_nonorthogonal(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = projaxes(u,v);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu(...
                alatt,angdeg);
            
            [u_par,v_par] = projection.uv_from_rlu_mat(alatt,angdeg,u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par);
            
            % find part of the v vector, orthogonal to u
            b_mat = bmatrix(alatt,angdeg);
            eu_cc = b_mat*u';
            eu = eu_cc/norm(eu_cc);
            % convert to crystal Cartesian
            v_cc = b_mat*v';
            
            v_along =eu*(eu'*v_cc);
            v_tr = (b_mat\(v_cc-v_along))';
            
            % this part should be recovered from the u_to_rlu matrix
            assertElementsAlmostEqual(v_tr,v_par);
            
        end
        %
        function test_uv_to_rlu_and_vv_complex(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = projaxes(u,v);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu(...
                alatt,angdeg);
            
            [u_par,v_par] = projection.uv_from_rlu_mat(alatt,angdeg,u_to_rlu,ulen);

            assertElementsAlmostEqual(u,u_par);
            % find part of the v vector, orthogonal to u
            eu =  u/norm(u);            
            v_along =eu*(eu*v');
            v_tr = v-v_along;

            % this part should be recovered from the u_to_rlu matrix
            assertElementsAlmostEqual(v_tr,sign(v_tr).*abs(v_par));
            
            pra = projaxes(u_par,v_par);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu(alatt,angdeg);
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
            
        end
        %
        function test_uv_to_rlu_and_vv_simple(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = projaxes(u,v);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu(...
                alatt,angdeg);
            
            [u_par,v_par] = projection.uv_from_rlu_mat(alatt,angdeg,u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par);
            assertElementsAlmostEqual(v,v_par);
            
            pra = projaxes(u_par,v_par);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu(alatt,angdeg);
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
        end
        %
        function test_alatt_column_gives_row(~)
            proj = projection();
            proj.alatt = [3;4;5];
            assertEqual(proj.alatt,[3,4,5]);
        end
        
        function test_alatt_row_gives_row(~)
            proj = projection();
            proj.alatt = [3,4,5];
            assertEqual(proj.alatt,[3,4,5]);
        end
        
        function test_alatt_single_gives3(~)
            proj = projection();
            proj.alatt = 3;
            assertEqual(proj.alatt,[3,3,3]);
        end
        
        function test_alatt_invalid_throw(~)
            proj = projection();
            pass = false;
            try
                proj.alatt = [1,1,1,1];
                pass = true;
            catch ERR
                assertEqual(ERR.identifier,'aPROJECTION:invalid_argument');
            end
            assertFalse(pass,'invalid alatt value should throw an error')
        end
        function test_angdeg_column_gives_row(~)
            proj = projection();
            proj.angdeg = [90;95;80];
            assertEqual(proj.angdeg,[90,95,80]);
        end
        
        function test_angdeg_row_gives_row(~)
            proj = projection();
            proj.angdeg = [90,95,80];
            assertEqual(proj.angdeg,[90,95,80]);
        end
        
        function test_angdeg_single_gives3(~)
            proj = projection();
            proj.angdeg = 30;
            assertEqual(proj.angdeg,[30,30,30]);
        end
        
        function test_angdeg_invalid_length_throw(~)
            proj = projection();
            pass = false;
            try
                proj.angdeg = [1,1,1,1];
                pass = true;
            catch ERR
                assertEqual(ERR.identifier,'aPROJECTION:invalid_argument');
            end
            assertFalse(pass,'invalid angdeg vector length should throw an error')
        end
        function test_angdeg_invalid_angle_throw(~)
            proj = projection();
            pass = false;
            try
                proj.angdeg = [200,10,30];
                pass = true;
            catch ERR
                assertEqual(ERR.identifier,'aPROJECTION:invalid_argument');
            end
            assertFalse(pass,'invalid angdeg value should throw an error')
        end
        
        
        
    end
end
