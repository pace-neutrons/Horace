classdef test_ortho_proj_transformation<TestCase
    % The tests to verify what ortho transformation corresponds to what
    % kind of detinintions
    %
    %
    properties
    end
    methods
        function this=test_ortho_proj_transformation(varargin)
            if nargin == 0
                name = 'test_ortho_proj_transformation';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
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
            [u_to_img,~,ulen]= pra.get_pix_img_transformation(3);
            %
            % but recovered the values, correspondent to ppr?
            [u_par,v_par,w,type] = pra.uv_from_data_rot_public(u_to_img,ulen);
%            assertElementsAlmostEqual(u',u_par);
%            assertEqual(type,'ppr');
            %assertTrue(isempty(w));
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
            pra = ortho_projTester(u_par,v_par,w, ...
                'alatt',alatt,'angdeg',angdeg,'type',type);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_img,u_to_rlu_rec);
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
%            assertElementsAlmostEqual(u',u_par);
%             %assertTrue(isempty(w));
%             % find part of the v vector, orthogonal to u
%             b_mat = bmatrix(alatt,angdeg);
%             eu_cc = b_mat*u';
%             eu = eu_cc/norm(eu_cc);
%             % convert to crystal Cartesian
%             v_cc = b_mat*v';
%             v_along =eu*(eu'*v_cc);
%             v_tr = (b_mat\(v_cc-v_along))';
            % this part should be recovered from the u_to_rlu matrix
            %assertElementsAlmostEqual(v_tr,v_par);

            pra = ortho_projTester(u_par,v_par,w,'alatt',alatt,'angdeg',angdeg,'type',typ);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);

        end
        %
        function test_uv_to_rot_and_vv_simple_tricl(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            [u_par,v_par,w,typ] = pra.uv_from_data_rot_public(u_to_rlu,ulen);
%            assertElementsAlmostEqual(u',u_par);
            %assertElementsAlmostEqual(w',[0,1,0]);

            % find part of the v vector, orthogonal to u

            pra = ortho_projTester(u_par,v_par,w,'alatt',alatt,'angdeg',angdeg,'type',typ);
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

            [u_par,v_par,~,type] = pra.uv_from_data_rot_public(u_to_rlu,ulen);

            assertElementsAlmostEqual(u',u_par);
            assertEqual(type,'ppr');

            pra = ortho_projTester(u_par,v_par,'alatt',alatt,'angdeg',angdeg,'type',type);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);

        end
        function test_uv_to_rot_and_vv_simple_tricl_lattice(~)
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
%            assertElementsAlmostEqual(u',u_par,'absolute',1.e-7);
            %assertElementsAlmostEqual(v',v_par,'absolute',1.e-7);
%            assertElementsAlmostEqual(w,[0;0;1],'absolute',1.e-7);
            %assertTrue(isempty(w));
%            assertEqual(tpe,'ppp');

            pra = ortho_projTester(u_par,v_par,w,'alatt',alatt,'angdeg',angdeg, ...
                'type',tpe);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
        end

        %
        function test_uv_to_rot_and_vv_simple_ortho_lattice(~)
            u = [1;0;0];
            v = [0;0;-1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = ortho_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            [u_par,v_par,w,tpe] = pra.uv_from_data_rot_public(u_to_rlu,ulen);
%             assertElementsAlmostEqual(u,u_par);
%             assertElementsAlmostEqual(v,v_par);
%             assertElementsAlmostEqual(w,[0;1;0]);
%             assertEqual(tpe,'ppp');

            pra = ortho_projTester(u_par,v_par,w,'alatt',alatt,'angdeg', ...
                angdeg,'type',tpe);
            [~, u_to_rlu_rec, ulen_rec] = pra.projaxes_to_rlu_public();

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_rec);
            assertElementsAlmostEqual(ulen,ulen_rec);
        end
        %------------------------------------------------------------------
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
        % Legacy vs new
        %------------------------------------------------------------------
        function test_legacy_vs_new_on_tricl_rot_eq(~)
            lat_par = [2,3,4];
            angdeg = [80,70,110];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = ortho_proj('alatt',lat_par,'angdeg',angdeg, ...
                'u',[1,-1,0],'v',[1,1,0],'w',[0,0,1], ...
                'type','ppp');

            pix_hkl_n = proj.transform_pix_to_img(pix_cc);
            [~,~,ulen_n]=proj.get_pix_img_transformation(3);

            % enable legacy mode
            proj.ub_inv_legacy = inv(bm);
            pix_hkl_l = proj.transform_pix_to_img(pix_cc);
            [~,~,ulen_l]=proj.get_pix_img_transformation(3);

            assertElementsAlmostEqual(pix_hkl_n ,pix_hkl_l);
            assertElementsAlmostEqual(ulen_n ,ulen_l);
        end

        function test_legacy_vs_new_on_tricl_eq(~)
            lat_par = [2,3,4];
            angdeg = [80,70,110];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = ortho_proj('alatt',lat_par,'angdeg',angdeg,'w',[0,0,1], ...
                'type','ppp');

            pix_hkl1 = proj.transform_pix_to_img(pix_cc);
            [~,~,ulen_n]=proj.get_pix_img_transformation(3);

            % enable legacy mode
            proj.ub_inv_legacy = inv(bm);
            pix_hkl2 = proj.transform_pix_to_img(pix_cc);
            [~,~,ulen_l]=proj.get_pix_img_transformation(3);

            assertElementsAlmostEqual(pix_hkl1 ,pix_hkl2);
            assertElementsAlmostEqual(ulen_n ,ulen_l);
        end
        function test_legacy_vs_new_on_ortho_eq_inA(~)
            lat_par = [2,3,4];
            angdeg = [90,90,90];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = ortho_proj('alatt',lat_par,'angdeg',angdeg, ...
                'u',[1,-1,0],'v',[1,1,0],'w',[0,0,1], ...
                'type','aaa');

            pix_hkl_n = proj.transform_pix_to_img(pix_cc);

            % enable legacy mode
            proj.ub_inv_legacy = inv(bm);
            pix_hkl_l = proj.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(pix_hkl_n ,pix_hkl_l);
        end

        function test_legacy_vs_new_on_ortho_rot_eq(~)
            lat_par = [2,3,4];
            angdeg = [90,90,90];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = ortho_proj('alatt',lat_par,'angdeg',angdeg, ...
                'u',[1,-1,0],'v',[1,1,0],'w',[0,0,1], ...
                'type','ppp');

            pix_hkl_n = proj.transform_pix_to_img(pix_cc);

            % enable legacy mode
            proj.ub_inv_legacy = inv(bm);
            pix_hkl_l = proj.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(pix_hkl_n ,pix_hkl_l);
        end


        function test_legacy_vs_new_on_ortho_eq(~)
            lat_par = [2,3,4];
            angdeg = [90,90,90];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = ortho_proj('alatt',lat_par,'angdeg',angdeg,'w',[0,0,1], ...
                'type','ppp');

            pix_hkl1 = proj.transform_pix_to_img(pix_cc);

            % enable legacy mode
            proj.ub_inv_legacy = inv(bm);
            pix_hkl2 = proj.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(pix_hkl1 ,pix_hkl2);
        end

        % RRR
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
        function test_transformation_scale_rrr_ortho_rot_xyz_tricl_invertable(~)

            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',[80,95,70], ...
                'u',[-1,1,1],'v',[1,0,0],'w',[0,1,0],'type','rrr');

            assertEqual(proj.type,'rrr')
            assertEqual(proj.u,[-1,1,1])
            assertEqual(proj.v,[1,0,0])

            assertFalse(proj.nonorthogonal)


            pix_cc = [eye(3),eye(3)];
            img_coord = proj.transform_pix_to_img(pix_cc );
            pix_rec   = proj.transform_img_to_pix(img_coord );


            assertElementsAlmostEqual(pix_rec,pix_rec);
        end


        function test_transformation_scale_rrr_ortho_rot_xyz(~)

            lat_par = [2,3,4];
            len = (2*pi)./lat_par;

            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[-1,1,1],'v',[1,0,0],'w',[0,1,0],'type','rrr');

            assertEqual(proj.type,'rrr')
            assertEqual(proj.u,[-1,1,1])
            assertEqual(proj.v,[1,0,0])

            assertFalse(proj.nonorthogonal)


            pix_coord = eye(3).*len;
            img_coord = proj.transform_pix_to_img(pix_coord);

            % can not find a way to calculate the resulting transformation
            % except the use the proj altogithm itself, though have some
            % ideas
            sample = [...
                -1.0000    0.4444    0.2500;...
                1.5625    1.0000    0.5625;...
                -0.0000    1.0000   -1.0000];
            assertElementsAlmostEqual(img_coord,sample,'absolute',1.e-4);

        end


        function test_transformation_scale_rrr_ortho_rot_xy(~)

            lat_par = [2,3,4];
            len = (2*pi)./lat_par;
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[-1,1,0],'v',[1,1,0],'w',[0,0,1],'type','rrr');

            assertEqual(proj.type,'rrr')
            assertEqual(proj.u,[-1,1,0])
            assertEqual(proj.v,[1,1,0])
            assertEqual(proj.w,[0,0,-1])
            assertFalse(proj.nonorthogonal)

            pix_coord = eye(3).*len;
            img_coord = proj.transform_pix_to_img(pix_coord);

            % can not find a way to calculate the resulting transformation
            % except the use the proj altogithm itself, though have some
            % ideas
            sample = [...
                -1.0000    0.4444         0;...
                1.0000     1.0000         0;...
                0          0       -1.0000];
            assertElementsAlmostEqual(img_coord,sample,'absolute',1.e-4);

        end

        function test_transformation_scale_rrr_ortho(~)

            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','rrr');
            assertEqual(proj.type,'rrr')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)

            len = (2*pi)./lat_par;
            pix_coord = eye(3).*len;
            img_coord = proj.transform_pix_to_img(pix_coord);

            assertElementsAlmostEqual(img_coord,eye(3));
        end
        % PPP
        %------------------------------------------------------------------
        function test_transformation_scale_ppp_nonortho_eq_ortho_at_ortho_lat(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','ppp','nonorthogonal',true);
            assertEqual(proj.type,'ppp')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertTrue(proj.nonorthogonal)

            img_coord = proj.transform_pix_to_img(eye(3));

            len = (2*pi)./lat_par;
            exp_coord = eye(3)./len;
            assertElementsAlmostEqual(img_coord,exp_coord);
        end
        function test_transformation_scale_ppp_ortho_rot_xyz_tricl_invertable(~)

            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',[80,95,70], ...
                'u',[-1,1,1],'v',[1,0,0],'w',[0,1,0],'type','ppp');

            assertEqual(proj.type,'ppp')
            assertEqual(proj.u,[-1,1,1])
            assertEqual(proj.v,[1,0,0])

            assertFalse(proj.nonorthogonal)


            pix_cc = [eye(3),eye(3)];
            img_coord = proj.transform_pix_to_img(pix_cc );
            pix_rec   = proj.transform_img_to_pix(img_coord );


            assertElementsAlmostEqual(pix_rec,pix_rec);
        end


        function test_transformation_scale_ppp_ortho_rot_xyz(~)

            lat_par = [1,2,3];
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[-1,1,1],'v',[1,1,0],'w',[0,1,0],'type','ppp');

            assertEqual(proj.type,'ppp')
            assertEqual(proj.u,[-1,1,1])
            assertEqual(proj.v,[1,1,0])

            assertFalse(proj.nonorthogonal)


            img_coord = proj.transform_pix_to_img(eye(3));

            % can not find a way to calculate the resulting transformation
            % except the use the proj altogithm itself
            sample = [...
                -0.1169    0.0585    0.0390;...
                0.0854    0.1475    0.0349;...
                -0.1592    0.3183   -0.9549];

            assertElementsAlmostEqual(img_coord,sample,'absolute',1.e-4);
        end


        function test_transformation_scale_ppp_ortho_rot_xy(~)

            lat_par = [1,2,3];
            len = (2*pi)./lat_par;
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[-1,1,0],'v',[1,1,0],'w',[0,0,1]);

            assertEqual(proj.type,'ppp')
            assertEqual(proj.u,[-1,1,0])
            assertEqual(proj.v,[1,1,0])
            assertEqual(proj.w,[0,0,-1])
            assertFalse(proj.nonorthogonal)


            pix_coord = [eye(3).*len,eye(3).*len];
            img_coord = proj.transform_pix_to_img(pix_coord);
            pix_rec = proj.transform_img_to_pix(img_coord);
            assertElementsAlmostEqual(pix_coord,pix_rec);


            assertElementsAlmostEqual(img_coord(:,1), [-0.8;0.5; 0]);
            assertElementsAlmostEqual(img_coord(:,2), [ 0.2;0.5; 0]);
            assertElementsAlmostEqual(img_coord(:,3), [ 0;  0;  -1]);

        end
        function test_transformation_scale_ppp_ortho_rot_xy_qubic(~)

            lat_par = 3;
            len = (2*pi)./lat_par;
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[-1,1,0],'v',[1,1,0],'w',[0,0,1]);

            assertEqual(proj.type,'ppp')
            assertEqual(proj.u,[-1,1,0])
            assertEqual(proj.v,[1,1,0])
            assertEqual(proj.w,[0,0,-1])
            assertFalse(proj.nonorthogonal)


            pix_coord = [eye(3).*len',eye(3).*len'];
            img_coord = proj.transform_pix_to_img(pix_coord);
            pix_rec = proj.transform_img_to_pix(img_coord);
            assertElementsAlmostEqual(pix_coord,pix_rec);


            assertElementsAlmostEqual(norm(img_coord(:,1)),1/sqrt(2));
            assertElementsAlmostEqual(norm(img_coord(:,2)),1/sqrt(2));
            assertElementsAlmostEqual(norm(img_coord(:,3)),1);
        end

        function test_transformation_scale_ppp_ortho(~)

            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1]);
            assertEqual(proj.type,'ppp')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)

            len = (2*pi)./lat_par;
            rlu_exp = [eye(3),ones(3,1)];
            pix_coord = [eye(3).*len',ones(3,1).*len'];
            img_coord = proj.transform_pix_to_img(pix_coord);

            assertElementsAlmostEqual(img_coord,rlu_exp);
        end
        % AAA
        %------------------------------------------------------------------
        function test_transformation_scale_aaa_nonortho_tricl_invertable(~)

            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',[85,110,95],'w',[0,0,1], ...
                'type','aaa','nonorthogonal',true);
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertTrue(proj.nonorthogonal)
            pix = [eye(3),[1;1;1]];
            img_coord = proj.transform_pix_to_img(pix);
            pix_coord = proj.transform_img_to_pix(img_coord);

            assertElementsAlmostEqual(pix_coord,pix);
        end


        function test_transformation_scale_aaa_nonotrho_invertable(~)
            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[1,-1,-1],'v',[1,1,-1],'w',[0,0,1], ...
                'type','aaa','nonorthogonal',true,'offset',[1,1,0,1]);
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,-1,-1])
            assertEqual(proj.v,[1,1,-1])
            assertEqual(proj.w,[0,0,1])
            assertEqual(proj.offset,[1,1,0,1])
            assertTrue(proj.nonorthogonal)

            pix = [eye(3),[1;1;1]];
            img_coord = proj.transform_pix_to_img(pix);
            pix_coord = proj.transform_img_to_pix(img_coord);

            assertElementsAlmostEqual(pix_coord,pix);
            %TODO: what check should be here, of course the image projections
            % are pretty complex?
            %    assertElementsAlmostEqual(norm(img_coord(:,1)),1);
            %    assertElementsAlmostEqual(norm(img_coord(:,2)),1);
            %    assertElementsAlmostEqual(norm(img_coord(:,3)),1);
        end
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


        function test_transformation_scale_aaa_nonortho_eq_ortho_at_ortho_lat(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
                'type','aaa','nonorthogonal',true);
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertTrue(proj.nonorthogonal)

            img_coord = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(img_coord,eye(3));
        end

        function test_transformation_scale_aaa_ortho_tricl_rot(~)

            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[1,-1,-1],'v',[1,1,-1],'w',[0,0,1],'type','aaa');
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,-1,-1])
            assertEqual(proj.v,[1,1,-1])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)


            img_coord = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(norm(img_coord(:,1)),1);
            assertElementsAlmostEqual(norm(img_coord(:,2)),1);
            assertElementsAlmostEqual(norm(img_coord(:,3)),1);

        end


        function test_transformation_scale_aaa_ortho_tricl(~)

            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',[85,110,95],'w',[0,0,1],'type','aaa');
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)

            img_coord = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(norm(img_coord(:,1)),1);
            assertElementsAlmostEqual(norm(img_coord(:,2)),1);
            assertElementsAlmostEqual(norm(img_coord(:,3)),1);
        end

        function test_transformation_scale_aaa_ortho_rot_xyz(~)
            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[1,-1,-1],'v',[1,1,-1],'w',[0,0,1],'type','aaa');
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,-1,-1])
            assertEqual(proj.v,[1,1,-1])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)

            img_coord = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(norm(img_coord(:,1)),1);
            assertElementsAlmostEqual(norm(img_coord(:,2)),1);
            assertElementsAlmostEqual(norm(img_coord(:,3)),1);
        end

        function test_transformation_scale_aaa_ortho_rot_xy(~)
            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90, ...
                'u',[1,-1,0],'v',[1,1,0],'w',[0,0,1],'type','aaa');
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,-1,0])
            assertEqual(proj.v,[1,1,0])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)

            img_coord = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(norm(img_coord(:,1)),1);
            assertElementsAlmostEqual(norm(img_coord(:,2)),1);
            assertElementsAlmostEqual(norm(img_coord(:,3)),1);
        end

        function test_transformation_scale_aaa_ortho(~)
            lat_par = [2,3,4];
            proj = ortho_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1],'type','aaa');
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)

            img_coord = proj.transform_pix_to_img(eye(3));

            img_len_expected = [1;1;1];
            assertElementsAlmostEqual(diag(img_coord),img_len_expected);
        end
        %
        function test_transformation_scale_aaa_ortho_invertable(~)
            lat_par = [2,3,4];
            proj = ortho_proj([-1,1,0],[1,1,0],[0,0,1], ...
                'alatt',lat_par,'angdeg',90, 'type','aaa','offset',[1,1,0,1]);
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[-1,1,0])
            assertEqual(proj.v,[1,1,0])
            assertEqual(proj.w,[0,0,-1]) % projection modified to define rhs
            assertEqual(proj.offset,[1,1,0,1]) % projection modified to define rhs
            assertFalse(proj.nonorthogonal)

            pix_coord = [eye(4),ones(4,1)];
            img_coord = proj.transform_pix_to_img(pix_coord);
            pix_rec   = proj.transform_img_to_pix(img_coord);

            assertElementsAlmostEqual(pix_coord,pix_rec );
        end


    end
end
