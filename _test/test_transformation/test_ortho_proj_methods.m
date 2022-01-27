classdef test_ortho_proj_methods<TestCase
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
        function this=test_ortho_proj_methods(varargin)
            if nargin == 0
                name = 'test_ortho_proj_class';
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
        %------------------------------------------------------------------
        function test_rotation_and_shift_4D(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester([1,0,0],[0, 1,0],'offset',[1,0,0,1],...
                'alatt',alatt,'angdeg',angdeg);
            prb = ortho_projTester([1,1,0],[1,-1,0],'offset',[1,1,1,2],...
                'alatt',alatt,'angdeg',angdeg);
            pra.targ_proj = prb;
            pix = eye(4);
            
            pix_transf_spec = pra.from_this_to_targ_coord(pix);
            
            pra.do_generic = true;
            pix_transf_gen = pra.from_this_to_targ_coord(pix);
            
            assertElementsAlmostEqual(pix_transf_spec,pix_transf_gen);
        end
        
        function test_rotation_and_shift_3D(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester([1,0,0],[0, 1,0],'offset',[1,0,0,0],...
                'alatt',alatt,'angdeg',angdeg);
            prb = ortho_projTester([1,1,0],[1,-1,0],'offset',[1,1,1,0],...
                'alatt',alatt,'angdeg',angdeg);
            pra.targ_proj = prb;
            pix = eye(4);
            
            pix_transf_spec = pra.from_this_to_targ_coord(pix);
            
            pra.do_generic = true;
            pix_transf_gen = pra.from_this_to_targ_coord(pix);
            
            assertElementsAlmostEqual(pix_transf_spec,pix_transf_gen);
        end
        
        function test_rotation_no_shift(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester([1,0,0],[0, 1,0],'alatt',alatt,'angdeg',angdeg);
            prb = ortho_projTester([1,1,0],[1,-1,0],'alatt',alatt,'angdeg',angdeg);
            pra.targ_proj = prb;
            pix = eye(4);
            
            pix_transf_spec = pra.from_this_to_targ_coord(pix);
            
            pra.do_generic = true;
            pix_transf_gen = pra.from_this_to_targ_coord(pix);
            
            assertElementsAlmostEqual(pix_transf_spec,pix_transf_gen);
        end
        
        function test_two_same_proj_define_unit_transf(~)
            u = [1,1,0];
            v = [1,-1,0];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_proj(u,v,'alatt',alatt,'angdeg',angdeg);
            pra.targ_proj = pra;
            pix = eye(4);
            
            pix_transf = pra.from_this_to_targ_coord(pix);
            assertElementsAlmostEqual(pix,pix_transf);
            
        end
        
        function test_from_this_to_targ_throws_no_targ(~)
            u = [1,1,0];
            v = [1,-1,0];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_proj(u,v,'alatt',alatt,'angdeg',angdeg);
            pix = eye(4);
            
            assertExceptionThrown(@()from_this_to_targ_coord(pra,pix),...
                'HORACE:aProjection:runtime_error');
            
        end
        %------------------------------------------------------------------
        function test_binning_range_half_sampe_proj2Drot45(~)
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj1.do_generic = true;
            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = axes_block(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,1];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = axes_block(bin1{:});
            proj2 = ortho_proj([1,1,0],[1,-1,0]);
            proj2.do_generic = true;
            
            
            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_start),numel(bl_size));
            
            assertEqual(numel(bl_start),6);
            assertEqual(bl_start,[10    19    28    40    53    66]);
            assertEqual(bl_size, [2     4     6     5     3     1]);
        end
        %
        function test_binning_range_half_sampe_proj2Drot90(~)
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj1.do_generic = true;
            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = axes_block(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,dbr(2,1)];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = axes_block(bin1{:});
            proj2 = ortho_proj([0,1,0],[1,0,0]);
            proj2.do_generic = true;
            
            
            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_start),numel(bl_size));
            
            sz1 = ab1.dims_as_ssize();
            nd = ab1.n_dims;
            assertEqual(nd,2)
            assertEqual(numel(bl_start),1);
            assertEqual(bl_start,2*sz1(2)+1);
            assertEqual(bl_size,4*sz1(2));
        end
        %
        function test_binning_range_half_sampe_proj2D(~)
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj1.do_generic = true;
            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = axes_block(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,dbr(2,1)];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = axes_block(bin1{:});
            
            
            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj1);
            assertEqual(numel(bl_start),numel(bl_size));
            
            nd = ab1.n_dims;
            sz1 = ab1.dims_as_ssize();
            assertEqual(nd,2)
            assertEqual(bl_start(1),6);
            assertEqual(numel(bl_start),sz1(2));
            assertEqual(bl_size,ones(1,sz1(2))*6);
        end
        %
        function test_binning_range_the_same_1D(~)
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj1.do_generic = true;
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = axes_block(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            
            [bl_start,bl_end] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(bl_start,1);
            assertEqual(bl_end,numel(npix));
        end
        %
        function test_binning_range_the_same_4D(~)
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj1.do_generic = true;
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab0 = axes_block(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            
            [nstart,nend] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(nstart,1);
            assertEqual(nend,numel(npix));
        end
        %------------------------------------------------------------------
        %
        function test_cut_dnd(this)
            skipTest('waits for cut_dnd being refactored')
            hc = hor_config();
            cur_mex = hc.use_mex;
            hc.use_mex = 0;
            clob = onCleanup(@()set(hor_config,'use_mex',cur_mex));
            [w, grid_size, pix_range]=fake_sqw (this.fake_sqw_par{:});
            w = dnd(w{1});
            %w = w{1};
            %wc = cut_dnd(w,0.01,0.01,[-0.1,0.1],2);
        end
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        function test_uv_to_rot_and_vv_complex_nonorth_with_rrr(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester(u,v,'type','rrr','alatt',alatt,'angdeg',angdeg);
            %
            %TODO: This option does not currently work.
            %pra.nonorthogonal = true;            
            % Is it necessary to make it to work?
            %
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            %
            % but recovered the values, correspondent to ppr?
            [u_par,v_par,w,type] = pra.uv_from_data_rot_public(u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par);
            assertEqual(type,'ppr');
            assertTrue(isempty(w));
            % find part of the v vector, orthogonal to u
%             b_mat = bmatrix(alatt,angdeg);
%             u_cc = b_mat*u'; % u-vector in Crystal Cartesian
%             eu = u_cc/norm(u_cc); % unit vector parallel to u in CC
%             % convert to crystal Cartesian
%             v_cc = b_mat*v';  % v-vector in Crystal Cartesian
%             
%             v_along =eu*(eu'*v_cc); % projection of v to eu
%             v_tr = (v'-b_mat\v_along)'; % convert v_along (u) to hkl
%             v_tr = v_tr/norm(v_tr);
%             % orthogonal v-part should be recovered from the u_to_rlu matrix
%             assertElementsAlmostEqual(v_tr,v_par);
            pra = ortho_projTester(u_par,v_par,'alatt',alatt,'angdeg',angdeg,'type',type);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);

        end
        %
        function test_uv_to_rot_and_vv_complex_nonorthogonal(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester(u,v,'type','rrr','alatt',alatt,'angdeg',angdeg);
            
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            
            [u_par,v_par,w,typ] = pra.uv_from_data_rot_public(u_to_rlu, ulen);
            assertElementsAlmostEqual(u,u_par);
            assertTrue(isempty(w));
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
            
            pra = ortho_projTester(u_par,v_par,'alatt',alatt,'angdeg',angdeg,'type',typ);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
            
        end
        %
        function test_uv_to_rot_and_vv_simple_nonorthogonal(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            
            [u_par,v_par,w,typ] = pra.uv_from_data_rot_public(u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par);
            assertTrue(isempty(w));
            
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
            
            pra = ortho_projTester(u_par,v_par,'alatt',alatt,'angdeg',angdeg,'type',typ);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
            
            
        end
        %
        function test_uv_to_rot_and_vv_complex(~)
            u = [1,1,0]/norm([1,1,0]);
            v = [0,-0.5,1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            
            [u_par,v_par,w,type] = pra.uv_from_data_rot_public(u_to_rlu,ulen);

            assertElementsAlmostEqual(u,u_par);
            assertTrue(isempty(w));
            assertEqual(type,'ppr');
            % find part of the v vector, orthogonal to u
%             eu =  u/norm(u);
%             v_along =eu*(eu*v');
%             v_tr = v-v_along;
%             v_tr = v_tr/norm(v_tr);
            
            % this part should be recovered from the u_to_rlu matrix
            %assertElementsAlmostEqual(v_tr,v_par);
            
            pra = ortho_projTester(u_par,v_par,'alatt',alatt,'angdeg',angdeg,'type',type);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
            
        end
        function test_uv_to_rot_and_vv_simple_rect_lattice(~)
            u = [1,0,0];
            v = [-0.117092223638778,0.993121045574670,0];  % vector in non-orthogonal coordinate system,
            % orthogonal to u vrt multiplication in B-matrix adjusted 
            % orthogonal coordinate system
            alatt = [2.8,2,3.5];
            angdeg = [92,85,95];
            %bmat = bmatrix(alatt,angdeg);
            
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            
            [u_par,v_par,w,tpe] = pra.uv_from_data_rot_public(u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par,'absolute',1.e-7);
            assertElementsAlmostEqual(v,v_par,'absolute',1.e-7);
            assertTrue(isempty(w));
            assertEqual(tpe,'ppr');
            
            pra = ortho_projTester(u_par,v_par,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
        end
        
        %
        function test_uv_to_rot_and_vv_simple_ortho_lattice(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            
            [u_par,v_par,w,tpe] = pra.uv_from_data_rot_public(u_to_rlu,ulen);
            assertElementsAlmostEqual(u,u_par);
            assertElementsAlmostEqual(v,v_par);
            assertTrue(isempty(w));
            assertEqual(tpe,'ppr');
            
            pra = ortho_projTester(u_par,v_par,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();
            
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
        end
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        function test_transf_to_img_and_back_reverts_proj_ortho_3D_with_offset(~)
            pix = ones(3,5);
            proj = ortho_proj([1,0,0],[0,1,1],'offset',[1,0,0]);
            proj.alatt = 3;
            proj.angdeg = 90;
            
            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[3,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertElementsAlmostEqual(pix_rec,pix);
        end
        
        function test_transform_to_img_and_back_reverts_proj_ortho_3D(~)
            pix = ones(3,5);
            proj = ortho_proj([1,0,0],[0,1,1]);
            proj.alatt = 3;
            proj.angdeg = 90;
            
            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[3,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertElementsAlmostEqual(pix_rec,pix);
        end
        %
        function test_transform_to_img_and_back_reverts_noprojaxis(~)
            pix = ones(4,5);
            proj = ortho_proj();
            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[4,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertEqual(pix_rec,pix);
        end
        %
        function transform_to_img_and_back_reverts_proj_ortho_with_offset(~)
            pix = ones(4,5);
            proj = ortho_proj([1,0,0],[0,1,1],'offset',[1,1,1]);
            proj.alatt = 3;
            proj.angdeg = 90;
            
            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[4,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertElementsAlmostEqual(pix_rec,pix);
        end
        %
        function transform_to_img_and_back_reverts_proj_ortho(~)
            pix = ones(4,5);
            proj = ortho_proj([1,0,0],[0,1,1]);
            proj.alatt = 3;
            proj.angdeg = 90;
            
            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[4,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertElementsAlmostEqual(pix_rec,pix);
        end
        %
        function transform_to_img_and_back_reverts_proj_nonorth(~)
            pix = ones(4,5);
            proj = ortho_proj([1,0,0],[0,1,1]);
            proj.alatt = [3,4,7];
            proj.angdeg = [95,70,85];
            
            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[4,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertElementsAlmostEqual(pix_rec,pix);
        end
    end
end
