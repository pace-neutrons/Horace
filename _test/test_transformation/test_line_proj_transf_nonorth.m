classdef test_line_proj_transf_nonorth<TestCase
    % The tests to verify what ortho transformation corresponds to what
    % kind of detinintions
    %
    %
    properties
    end
    methods
        function this=test_line_proj_transf_nonorth(varargin)
            if nargin == 0
                name = 'test_line_proj_transf_nonorth';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end

        function test_getset_nonortho_proj_ppp_100(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 90],'nonorthogonal',true,...
                'type','ppp','u',[1,0,0],'v',[0,1,0],'w',[1,1,1]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = prj_or.u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(ulen,ulen_rec)

            % and the matrices are correct!
            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);
            % BUT:
            assertEqual(prj_or.type,'ppp')
            assertEqual(prj_rec.type,'rrp')

            % this is what is what is only important for any transformation
            pix_cc = [eye(3),ones(3,1)];
            tpixo = prj_or.transform_pix_to_img(pix_cc);
            tpixr = prj_rec.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(tpixo,tpixr);

        end


        function test_getset_nonortho_proj_rrr_100(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 90],'nonorthogonal',true,...
                'type','rrr','u',[1,0,0],'v',[0,1,0],'w',[1,1,1]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = prj_or.u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(ulen,ulen_rec)

            % and the matrices are correct!
            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);

            % this is what is what is only important for any transformation
            tpixo = prj_or.transform_pix_to_img(eye(3));
            tpixr = prj_rec.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);

        end
        %
        function test_getset_nonortho_proj_ppp_110(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 90],'nonorthogonal',true,...
                'type','ppp','u',[1,1,0],'v',[0,1,0],'w',[1,1,1]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = prj_or.u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(ulen,ulen_rec)

            % and the matrices are correct!
            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);

            assertEqualToTol(prj_or,prj_rec,1.e-9);

        end

        function test_getset_nonortho_proj_rrr_noW(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3.1580 3.1752 3.1247], ...
                'angdeg',[90.0013 89.9985 90.0003],'nonorthogonal',true,...
                'type','rrr','u',[1,0,0],'v',[0,1,0]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-5)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',2.e-5)
            assertElementsAlmostEqual(ulen,ulen_rec)

            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);

            % this is what is what is only important for any transformation
            tpixo = prj_or.transform_pix_to_img(eye(3));
            tpixr = prj_rec.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr,'absolute',2.e-5);

        end

        function test_getset_nonortho_proj_par_110(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 90],'nonorthogonal',true,...
                'type','par','u',[1,1,0],'v',[0,1,0],'w',[1,1,1]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = prj_or.u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(ulen,ulen_rec)

            % and the matrices are correct!
            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);

            assertEqualToTol(prj_or,prj_rec,1.e-9);
        end


        function test_getset_nonortho_proj_aaa_110(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 90],'nonorthogonal',true,...
                'type','aaa','u',[1,1,0],'v',[1,0,0],'w',[1,1,1]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = prj_or.u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(ulen,ulen_rec)

            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);

            % this is what is what is only important for any transformation
            tpixo = prj_or.transform_pix_to_img(eye(3));
            tpixr = prj_rec.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);

        end

        function test_getset_nonortho_proj_aaa_100(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 90],'nonorthogonal',true,...
                'type','aaa','u',[1,0,0],'v',[1,1,0],'w',[1,1,1]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = prj_or.u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(ulen,ulen_rec)

            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);

            % this is what is what is only important for any transformation
            tpixo = prj_or.transform_pix_to_img(eye(3));
            tpixr = prj_rec.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);

        end

        function test_getset_nonortho_proj_aaa_111(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 90],'nonorthogonal',true,...
                'type','aaa','u',[1,1,1],'v',[1,1,0],'w',[0,-1,1]);

            [rlu_to_ustep, u_to_rlu, ulen] = prj_or.projaxes_to_rlu_public();

            data = struct();
            data.alatt = prj_or.alatt;
            data.angdeg =prj_or.angdeg;
            data.u_to_rlu = prj_or.u_to_rlu;
            data.label = prj_or.label;
            data.ulen = ulen;

            prj_rec = ortho_proj.get_from_old_data(data);
            prj_rec = ortho_projTester(prj_rec);
            [rlu_to_ustep_rec, u_to_rlu_rec,ulen_rec] = prj_rec.projaxes_to_rlu_public();

            assertElementsAlmostEqual(rlu_to_ustep,rlu_to_ustep_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec,'absolute',6.e-6)
            assertElementsAlmostEqual(ulen,ulen_rec)

            assertTrue(prj_or.nonorthogonal);
            assertTrue(prj_rec.nonorthogonal);

            % this is what is what is only important for any transformation
            tpixo = prj_or.transform_pix_to_img(eye(3));
            tpixr = prj_rec.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);

        end


        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        function test_uv_to_rot_and_vv_complex_nonorth_with_rrr_nonortho(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible

            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester(u,v,'type','rrr','alatt',alatt,'angdeg',angdeg, ...
                'nonortho',true);
            %
            %TODO: This option does not currently work.
            %pra.nonorthogonal = true;
            % Is it necessary to make it to work?
            %
            [u_to_img,~,ulen]= pra.get_pix_img_transformation(3);
            %
            [u_par,v_par,w,type] = pra.uv_from_data_rot_public(u_to_img,ulen);

            pra = ortho_projTester(u_par,v_par,w, ...
                'alatt',alatt,'angdeg',angdeg,'type',type, 'nonortho',true);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_img,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);

        end
        %
        function test_uv_to_rot_and_vv_complex_tricl_nonortho(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester(u,v,'type','rrr','alatt',alatt,'angdeg',angdeg, ...
                'nonortho',true);

            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            [u_par,v_par,w,typ] = pra.uv_from_data_rot_public(u_to_rlu, ulen);

            pra = ortho_projTester(u_par,v_par,w,'alatt',alatt, ...
                'angdeg',angdeg,'type',typ, 'nonortho',true);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);

        end
        %
        function test_uv_to_rot_and_vv_simple_tricl_nonortho(~)
            % this test does not work. Should it? With current
            % nonorthogonal lattice definition, such recovery is impossible
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg, ...
                'nonortho',true);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            [u_par,v_par,w,typ] = pra.uv_from_data_rot_public(u_to_rlu,ulen);
            %            assertElementsAlmostEqual(u',u_par);
            %assertElementsAlmostEqual(w',[0,1,0]);

            % find part of the v vector, orthogonal to u

            pra = ortho_projTester(u_par,v_par,w,'alatt',alatt, ...
                'angdeg',angdeg,'type',typ, 'nonortho',true);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);


        end
        %
        function test_uv_to_rot_and_vv_complex_nonortho(~)

            u = [1,1,0]/norm([1,1,0]);
            v = [0,-0.5,1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pro = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg, ...
                'nonortho',true);
            [~, q_to_rlu, ulen] = pro.projaxes_to_rlu_public();

            [u_par,v_par,w,type] = pro.uv_from_data_rot_public(q_to_rlu,ulen);

            prr = ortho_projTester(u_par,v_par,w,'alatt',alatt, ...
                'angdeg',angdeg,'type',type, 'nonortho',true);
            assertEqualToTol(pro,prr,1.e-12)
        end
        %
        function test_uv_to_rot_and_back_simple_ortho_lattice(~)
            % nonorthogonal lattice definition, such recovery is impossible
            u = [1;1;0];
            v = [0;0.1;-1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg, ...
                'nonortho',true);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            [u_par,v_par,w,tpe] = pra.uv_from_data_rot_public(u_to_rlu,ulen);

            prb = ortho_projTester(u_par,v_par,w,'alatt',alatt,'angdeg', ...
                angdeg,'type',tpe,'nonortho',true);
            [~, ~, ulen_rec] = pra.projaxes_to_rlu_public();

            pix_cc = [eye(3),ones(3,1)];
            img_or = pra.transform_pix_to_img(pix_cc);
            img_rc = prb.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(img_or ,img_rc);
            assertElementsAlmostEqual(ulen,ulen_rec);
        end
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        %
        function test_transf_scale_aaa_nonortho_eq_ortho_at_ortho_cub_rot(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice except
            % lattices are rotated wrt each other by 90^o
            lat_par = 3;

            u = [1, -1,0]/sqrt(2);
            v = [1,  1,0]/sqrt(2);
            w = [0,0,1];
            pic_cc = [eye(3),[1;1;1]];

            proj = ortho_proj(u,v,w, ...
                'alatt',lat_par,'angdeg',90, ...
                'type','aaa','nonorthogonal',true);


            img_nonor = proj.transform_pix_to_img(pic_cc);
            proj = ortho_proj(u,v,w, ...
                'alatt',lat_par,'angdeg',90, ...
                'type','aaa','nonorthogonal',false);
            img_or = proj.transform_pix_to_img(pic_cc);

            %flipmat = [0,-1,0;1,0,0;0,0,1];
            %img_nonor  = flipmat*img_nonor;
            assertElementsAlmostEqual(img_nonor ,  img_or);
        end
        %------------------------------------------------------------------
        function test_transf_ppp_nonortho_at_tricl_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            angdeg = [70,60,110];
            projn = ortho_proj([1,0,0],[1,1,0],[0,1,1], ...
                'alatt',lat_par,'angdeg',angdeg,'type','ppp','nonorthogonal',true);
            assertEqual(projn.type,'ppp')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[1,1,0])
            assertEqual(projn.w,[0,1,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        function test_transf_aaa_nonortho_at_tricl_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            angdeg = [70,60,110];
            projn = ortho_proj([1,0,0],[1,1,0],[0,1,1], ...
                'alatt',lat_par,'angdeg',angdeg,'type','aaa','nonorthogonal',true);
            assertEqual(projn.type,'aaa')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[1,1,0])
            assertEqual(projn.w,[0,1,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        function test_transf_rrr_nonortho_at_tricl_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            angdeg = [70,60,110];
            projn = ortho_proj([1,0,0],[1,1,0],[0,1,1], ...
                'alatt',lat_par,'angdeg',angdeg,'type','rrr','nonorthogonal',true);
            assertEqual(projn.type,'rrr')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[1,1,0])
            assertEqual(projn.w,[0,1,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        %------------------------------------------------------------------
        function test_transf_ppp_nonorthoR_at_ortho_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            projn = ortho_proj([1,0,0],[1,1,0],[0,1,1], ...
                'alatt',lat_par,'angdeg',90,'type','ppp','nonorthogonal',true);
            assertEqual(projn.type,'ppp')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[1,1,0])
            assertEqual(projn.w,[0,1,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        function test_transf_aaa_nonorthoR_at_ortho_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            projn = ortho_proj([1,0,0],[1,1,0],[0,1,1], ...
                'alatt',lat_par,'angdeg',90,'type','aaa','nonorthogonal',true);
            assertEqual(projn.type,'aaa')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[1,1,0])
            assertEqual(projn.w,[0,1,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        function test_transf_rrr_nonorthoR_at_ortho_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            projn = ortho_proj([1,0,0],[1,1,0],[0,1,1], ...
                'alatt',lat_par,'angdeg',90,'type','rrr','nonorthogonal',true);
            assertEqual(projn.type,'rrr')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[1,1,0])
            assertEqual(projn.w,[0,1,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        %------------------------------------------------------------------
        function test_transf_ppp_nonortho_at_ortho_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            projn = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','ppp','nonorthogonal',true);
            assertEqual(projn.type,'ppp')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[0,1,0])
            assertEqual(projn.w,[0,0,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        function test_transf_aaa_nonortho_at_ortho_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            projn = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','aaa','nonorthogonal',true);
            assertEqual(projn.type,'aaa')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[0,1,0])
            assertEqual(projn.w,[0,0,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        function test_transf_rrr_nonortho_at_ortho_lat_eq_legacy(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            projn = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','rrr','nonorthogonal',true);
            assertEqual(projn.type,'rrr')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[0,1,0])
            assertEqual(projn.w,[0,0,1])
            assertTrue(projn.nonorthogonal)

            % compate with legacy transformation
            %
            assertElementsAlmostEqual(projn.u_to_rlu,projn.u_to_rlu_legacy)

            [q_to_img_n,shift_n,ulen_n,]=projn.get_pix_img_transformation(3);
            projn.ub_inv_legacy = inv(projn.bmatrix());
            [q_to_img_l,shift_l,ulen_l]=projn.get_pix_img_transformation(3);

            assertElementsAlmostEqual(q_to_img_n,q_to_img_l);
            assertElementsAlmostEqual(shift_n,shift_l);
            assertElementsAlmostEqual(ulen_n,ulen_l);
        end
        %------------------------------------------------------------------
        function test_transformation_scale_rrr_nonortho_eq_ortho_at_ortho_lat(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            len = (2*pi)./lat_par;
            projn = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','rrr','nonorthogonal',true);
            assertEqual(projn.type,'rrr')
            assertEqual(projn.u,[1,0,0])
            assertEqual(projn.v,[0,1,0])
            assertEqual(projn.w,[0,0,1])
            assertTrue(projn.nonorthogonal)

            pix_cc = eye(3).*len;

            imgn_coord = projn.transform_pix_to_img(pix_cc);
            projo = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','rrr','nonorthogonal',false);
            assertEqual(projo.type,'rrr')
            assertEqual(projo.u,[1,0,0])
            assertEqual(projo.v,[0,1,0])
            assertEqual(projo.w,[0,0,1])
            assertFalse(projo.nonorthogonal)
            imgo_coord = projo.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(imgn_coord,imgo_coord);

            assertElementsAlmostEqual(imgn_coord,eye(3));

        end
    end
end