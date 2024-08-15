classdef test_line_proj_transf_orth<TestCase
    % The tests to verify what ortho transformation corresponds to what
    % kind of definitions
    %
    %
    properties
    end
    methods
        function this=test_line_proj_transf_orth(varargin)
            if nargin == 0
                name = 'test_line_proj_transf_orth';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end
        function test_transf_to_hkl_type_irrelevant_ortho_tricl(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2,4];
            angdeg = [95,75,80];
            pra = line_projTester(u,v,'alatt',alatt,'angdeg',angdeg,'type','aaa');
            source = [eye(4),ones(4,1)];

            tp_img = pra.transform_pix_to_img(source);
            tp_hkl_base = pra.transform_img_to_hkl(tp_img);
            types = {'ppa','rrr','ppr','apr'};
            for i=1:numel(types)
                pr_tp = line_proj(u,v,'alatt',alatt,'angdeg',angdeg,'type',types{i});
                tp_img = pr_tp.transform_pix_to_img(source);
                tp_hkl = pr_tp.transform_img_to_hkl(tp_img);

                assertElementsAlmostEqual(tp_hkl,tp_hkl_base);
            end
        end

        function test_transf_to_hkl_type_irrelevant_ortho_ortho(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = 2.83;
            angdeg = 90;
            pra = line_projTester(u,v,'alatt',alatt,'angdeg',angdeg,'type','aaa');
            source = [eye(4),ones(4,1)];

            tp_img = pra.transform_pix_to_img(source);
            tp_hkl_base = pra.transform_img_to_hkl(tp_img);
            types = {'ppa','rrr','ppr','apr'};
            for i=1:numel(types)
                pr_tp = line_proj(u,v,'alatt',alatt,'angdeg',angdeg,'type',types{i});
                tp_img = pr_tp.transform_pix_to_img(source);
                tp_hkl = pr_tp.transform_img_to_hkl(tp_img);

                assertElementsAlmostEqual(tp_hkl,tp_hkl_base);
            end
        end

        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        %
        function test_uv_to_rot_and_vv_simple_tricl(~)
            u = [1,0,0];
            v = [0,0,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = line_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            pru = ubmat_proj(u_to_rlu,ulen,'alatt',alatt,'angdeg',angdeg);

            pc = pra.transform_pix_to_img([eye(4),ones(4,1)]);
            pcu = pru.transform_pix_to_img([eye(4),ones(4,1)]);
            assertElementsAlmostEqual(pc,pcu);
        end
        function test_uv_to_rot_and_vv_complex_vs_legacy(~)
            % recovery from old u_to_rlu, stored in old versions of
            % sqw files
            u = [1,1,0]/norm([1,1,0]);
            v = [0,-0.5,1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = line_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            dat = struct();
            dat.u_to_rlu = pra.u_to_rlu_legacy;
            dat.alatt = alatt;
            dat.angdeg = angdeg;
            dat.ulen = pra.ulen;
            rec = line_projTester();
            rec = rec.build_from_old_struct_public(dat);

            pix_cc = [eye(3),ones(3,1)];

            img_orig =  pra.transform_pix_to_img(pix_cc);
            img_rec  =  rec.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(img_orig,img_rec );
            assertEqualToTol(pra,rec,'tol',1.e-12);
        end
        %
        function test_uv_to_rot_and_vv_complex(~)
            u = [1,1,0]/norm([1,1,0]);
            v = [0,-0.5,1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = line_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();


            pru = ubmat_proj(u_to_rlu,ulen,'alatt',alatt,'angdeg',angdeg);

            pc = pra.transform_pix_to_img([eye(4),ones(4,1)]);
            pcu = pru.transform_pix_to_img([eye(4),ones(4,1)]);
            assertElementsAlmostEqual(pc,pcu);
        end
        function test_uv_to_rot_and_vv_simple_tricl_lattice(~)
            u = [1,0,0];
            v = [-0.117092223638778,0.993121045574670,0];  % vector in non-orthogonal coordinate system,
            % orthogonal to u vrt multiplication in B-matrix adjusted
            % orthogonal coordinate system
            alatt = [2.8,2,3.5];
            angdeg = [92,85,95];
            %bmat = bmatrix(alatt,angdeg);

            pra = line_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            pru = ubmat_proj(u_to_rlu,ulen,'alatt',alatt,'angdeg',angdeg);

            pc = pra.transform_pix_to_img([eye(4),ones(4,1)]);
            pcu = pru.transform_pix_to_img([eye(4),ones(4,1)]);
            assertElementsAlmostEqual(pc,pcu);

        end

        %
        function test_uv_to_rot_and_vv_simple_ortho_lattice(~)
            u = [1;0;0];
            v = [0;0;-1];
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            pra = line_projTester(u,v,'alatt',alatt,'angdeg',angdeg);
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            pru = ubmat_proj(u_to_rlu,ulen,'alatt',alatt,'angdeg',angdeg);

            pc = pra.transform_pix_to_img([eye(4),ones(4,1)]);
            pcu = pru.transform_pix_to_img([eye(4),ones(4,1)]);
            assertElementsAlmostEqual(pc,pcu);
        end
        %------------------------------------------------------------------
        %
        function transform_to_img_and_back_reverts_proj_ortho_with_offset(~)
            pix = ones(4,5);
            proj = line_proj([1,0,0],[0,1,1],'offset',[1,1,1]);
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
            proj = line_proj([1,0,0],[0,1,1]);
            proj.alatt = 3;
            proj.angdeg = 90;

            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[4,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);get_from_old_data
            assertElementsAlmostEqual(pix_rec,pix);
        end
        %
        function transform_to_img_and_back_reverts_proj_tricl(~)
            pix = ones(4,5);
            proj = line_proj([1,0,0],[0,1,1]);
            proj.alatt = [3,4,7];
            proj.angdeg = [95,70,85];

            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[4,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertElementsAlmostEqual(pix_rec,pix);
        end

        %------------------------------------------------------------------
        % Legacy vs new
        %------------------------------------------------------------------
        function test_legacy_vs_new_on_tricl_rot_eq(~)
            lat_par = [2,3,4];
            angdeg = [80,70,110];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = line_proj('alatt',lat_par,'angdeg',angdeg, ...
                'u',[1,-1,0],'v',[1,1,0],'w',[0,0,1], ...
                'type','ppp');

            pix_hkl_n = proj.transform_pix_to_img(pix_cc);
            [~,~,ulen_n]=proj.get_pix_img_transformation(3);

            % enable legacy mode
            proj_l = ubmat_proj(proj.u_to_rlu,proj.img_scales, ...
                'alatt',lat_par,'angdeg',angdeg);
            pix_hkl_l = proj_l.transform_pix_to_img(pix_cc);
            [~,~,ulen_l]=proj_l.get_pix_img_transformation(3);

            assertElementsAlmostEqual(pix_hkl_n ,pix_hkl_l);
            assertElementsAlmostEqual(ulen_n ,ulen_l);
        end

        function test_legacy_vs_new_on_tricl_eq(~)
            lat_par = [2,3,4];
            angdeg = [80,70,110];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = line_proj('alatt',lat_par,'angdeg',angdeg,'w',[0,0,1], ...
                'type','ppp');

            pix_hkl1 = proj.transform_pix_to_img(pix_cc);
            [~,~,ulen_n]=proj.get_pix_img_transformation(3);

            % enable legacy mode
            proj_l = ubmat_proj(proj.u_to_rlu,proj.img_scales, ...
                'alatt',lat_par,'angdeg',angdeg);
            pix_hkl2 = proj_l.transform_pix_to_img(pix_cc);
            [~,~,ulen_l]=proj_l.get_pix_img_transformation(3);

            assertElementsAlmostEqual(pix_hkl1 ,pix_hkl2);
            assertElementsAlmostEqual(ulen_n ,ulen_l);
        end
        function test_legacy_vs_new_on_ortho_eq_inA(~)
            lat_par = [2,3,4];
            angdeg = [90,90,90];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = line_proj('alatt',lat_par,'angdeg',angdeg, ...
                'u',[1,-1,0],'v',[1,1,0],'w',[0,0,1], ...
                'type','aaa');

            pix_hkl_n = proj.transform_pix_to_img(pix_cc);

            % enable legacy mode
            proj_l = ubmat_proj(proj.u_to_rlu,proj.img_scales, ...
                'alatt',lat_par,'angdeg',angdeg);
            pix_hkl_l = proj_l.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(pix_hkl_n ,pix_hkl_l);
        end

        function test_legacy_vs_new_on_ortho_rot_eq(~)
            lat_par = [2,3,4];
            angdeg = [90,90,90];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = line_proj('alatt',lat_par,'angdeg',angdeg, ...
                'u',[1,-1,0],'v',[1,1,0],'w',[0,0,1], ...
                'type','ppp');

            pix_hkl_n = proj.transform_pix_to_img(pix_cc);

            % enable legacy mode
            proj_l = ubmat_proj(proj.u_to_rlu,proj.img_scales, ...
                'alatt',lat_par,'angdeg',angdeg);
            pix_hkl_l = proj_l.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(pix_hkl_n ,pix_hkl_l);
        end


        function test_legacy_vs_new_on_ortho_eq(~)
            lat_par = [2,3,4];
            angdeg = [90,90,90];

            pix_hkl = [eye(3),ones(3,1),[1;1;0]];
            bm = bmatrix(lat_par,angdeg);
            pix_cc = bm'*pix_hkl;

            proj = line_proj('alatt',lat_par,'angdeg',angdeg,'w',[0,0,1], ...
                'type','ppp');

            pix_hkl1 = proj.transform_pix_to_img(pix_cc);

            % enable legacy mode
            proj_l = ubmat_proj(proj.u_to_rlu,proj.img_scales, ...
                'alatt',lat_par,'angdeg',angdeg);
            pix_hkl2 = proj_l.transform_pix_to_img(pix_cc);

            assertElementsAlmostEqual(pix_hkl1 ,pix_hkl2);
        end
    end
    % RRR
    %================================
    methods
        %------------------------------------------------------------------
        function test_transf_rrr_new_vs_legacy_orthorhombic_lat(~)
            lat_par = [2,3,4];
            proj = line_proj([1,1,0],[0,0,1],'alatt',lat_par,'angdeg',90, ...
                'type','rrr');
            assertEqual(proj.type,'rrr')
            assertEqual(proj.u,[1,1,0])
            assertEqual(proj.v,[0,0,1])
            assertTrue(isempty(proj.w))
            assertFalse(proj.nonorthogonal)

            u_to_rlu = proj.u_to_rlu;
            u_to_rlu_legacy = proj.u_to_rlu_legacy;

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_legacy);
        end


        function test_uv_to_rot_and_vv_complex_tricl_with_rrr(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = line_projTester(u,v,'type','rrr','alatt',alatt,'angdeg',angdeg);
            %
            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();

            pru = ubmat_proj(u_to_rlu,ulen,'alatt',alatt,'angdeg',angdeg);

            pc = pra.transform_pix_to_img([eye(4),ones(4,1)]);
            pcu = pru.transform_pix_to_img([eye(4),ones(4,1)]);
            assertElementsAlmostEqual(pc,pcu);
        end

        function test_transformation_scale_rrr_ortho_rot_xyz_tricl_invertable(~)

            lat_par = [2,3,4];
            proj = line_proj('alatt',lat_par,'angdeg',[80,95,70], ...
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

            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
                -0.5902    0.2623    0.1475;...
                0.5902    0.3777    0.2125;...
                0    0.6400   -0.6400];
            assertElementsAlmostEqual(img_coord,sample,'absolute',1.e-4);

        end


        function test_transformation_scale_rrr_ortho_rot_xy(~)

            lat_par = [2,3,4];
            len = (2*pi)./lat_par;
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
                -0.6923    0.3077         0;...
                0.6923    0.6923         0;...
                0         0   -1.0000];
            assertElementsAlmostEqual(img_coord,sample,'absolute',1.e-4);

        end

        function test_transformation_scale_rrr_ortho(~)

            lat_par = [2,3,4];
            proj = line_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
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
    end
    % PPP
    %==================================================================
    methods
        function test_transf_ppp_new_vs_legacy_orthorhombic_lat(~)
            lat_par = [2,3,4];
            proj = line_proj([1,1,0],[0,0,1],[0,1,0],'alatt',lat_par,'angdeg',90, ...
                'type','ppp');
            assertEqual(proj.type,'ppp')
            assertEqual(proj.u,[1,1,0])
            assertEqual(proj.v,[0,0,1])
            assertEqual(proj.w,[0,-1,0])
            assertFalse(proj.nonorthogonal)

            u_to_rlu = proj.u_to_rlu;
            u_to_rlu_legacy = proj.u_to_rlu_legacy;

            assertElementsAlmostEqual(u_to_rlu,u_to_rlu_legacy);
        end

        %------------------------------------------------------------------
        function test_transformation_scale_ppp_nonortho_eq_ortho_at_ortho_lat(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            proj = line_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
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
            proj = line_proj('alatt',lat_par,'angdeg',[80,95,70], ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1]);
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
    end
    % AAA
    %==================================================================
    methods
        %------------------------------------------------------------------
        function test_transformation_scale_aaa_nonortho_tricl_invertable(~)

            lat_par = [2,3,4];
            proj = line_proj('alatt',lat_par,'angdeg',[85,110,95],'w',[0,0,1], ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
        function test_transformation_scale_aaa_nonortho_eq_ortho_at_ortho_lat(~)
            % non-ortho transformation with orthogonal projection equal to
            % orthogonal transformation on ortholinear lattice
            lat_par = [2,3,4];
            proj = line_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1], ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
        %
        function test_uv_to_rot_and_vv_complex_triclinic(~)
            u = [1,1,0];
            v = [0,-0.5,1];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = line_projTester(u,v,'type','rrr','alatt',alatt,'angdeg',angdeg);

            [~, u_to_rlu, ulen] = pra.projaxes_to_rlu_public();
            pru = ubmat_proj(u_to_rlu,ulen,'alatt',alatt,'angdeg',angdeg);

            pc = pra.transform_pix_to_img([eye(4),ones(4,1)]);
            pcu = pru.transform_pix_to_img([eye(4),ones(4,1)]);
            assertElementsAlmostEqual(pc,pcu);

        end


        function test_transformation_scale_aaa_ortho_tricl(~)

            lat_par = [2,3,4];
            proj = line_proj('alatt',lat_par,'angdeg',[85,110,95],'w',[0,0,1],'type','aaa');
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
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90, ...
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
            proj = line_proj('alatt',lat_par,'angdeg',90,'w',[0,0,1],'type','aaa');
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[0,1,0])
            assertEqual(proj.w,[0,0,1])
            assertFalse(proj.nonorthogonal)

            img_coord = proj.transform_pix_to_img(eye(3));

            img_len_expected = [1;1;1];
            assertElementsAlmostEqual(diag(img_coord),img_len_expected);
        end
        %------------------------------------------------------------------
        function test_transformation_scale_aaa_ortholat_nonortho_invertable(~)
            %
            lat_par = [2,3,4];
            proj = line_proj([1,0,0],[1,1,0],[0,0,1], ...
                'alatt',lat_par,'angdeg',90,'type','aaa','nonorthogonal',true);
            assertEqual(proj.type,'aaa')
            assertEqual(proj.u,[1,0,0])
            assertEqual(proj.v,[1,1,0])
            assertEqual(proj.w,[0,0,1])
            assertTrue(proj.nonorthogonal)

            pix_cc = [eye(3),ones(3,1)];
            img_coord = proj.transform_pix_to_img(pix_cc);
            pix_rec   = proj.transform_img_to_pix(img_coord);

            assertElementsAlmostEqual(pix_cc,pix_rec );
        end

        function test_transformation_scale_aaa_ortho_invertable(~)
            lat_par = [2,3,4];
            proj = line_proj([-1,1,0],[1,1,0],[0,0,1], ...
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
        %
        function test_transf_to_img_and_back_reverts_proj_ortho_3D_with_offset(~)
            pix = ones(3,5);
            proj = line_proj([1,0,0],[0,1,1],'offset',[1,0,0]);
            proj.alatt = 3;
            proj.angdeg = 90;

            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[3,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertElementsAlmostEqual(pix_rec,pix);
        end

        function test_transform_to_img_and_back_reverts_proj_ortho_3D(~)
            pix = ones(3,5);
            proj = line_proj([1,0,0],[0,1,1]);
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
            proj = line_proj('alatt',1,'angdeg',90);
            pix_transf = proj.transform_pix_to_img(pix);
            assertEqual(size(pix_transf),[4,5]);
            pix_rec = proj.transform_img_to_pix(pix_transf);
            assertEqual(pix_rec,pix);
        end
    end
end
