classdef test_line_proj_construction<TestCase
    % testing ortho_proj class constructor
    %
    properties
        tests_folder
    end

    methods
        function this=test_line_proj_construction(varargin)
            if nargin == 0
                name = 'test_line_proj_construction';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end

        function test_constructor_keys_overrides_positional(~)
            proj = ortho_proj([1,0,0],[0,1,0],...
                'alatt',[2,3,4],'type','aaa','nonorthogonal',true,...
                'w',[0,0,1]);
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0]);
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

        function test_constructor_third_long_argument_throws(~)
            err=assertExceptionThrown(...
                @()ortho_proj([1,0,0],[0,1,0],[1,1,1,1],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            samp = 'Input should be non-zero length numeric vector with 3 components. It is: "1     1     1     1"';
            assertEqual(err.message,samp);
        end

        function test_constructor_third_zero_argument_throws(~)
            err=assertExceptionThrown(...
                @()ortho_proj([1,0,0],[0,1,0],[0,0,0],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            assertEqual(err.message,...
                'Input can not be a 0-vector: [0,0,0] with all components smaller then tol = 1e-12');
        end

        function test_incorrect_constructor_throws_on_positional_zero(~)
            err = assertExceptionThrown(...
                @()ortho_proj([0,0,0],1,'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            assertEqual(err.message, ...
                'Input can not be a 0-vector: [0,0,0] with all components smaller then tol = 1e-12')
        end

        function test_incorrect_constructor_throws_on_positional(~)
            err= assertExceptionThrown(...
                @()ortho_proj([1,0,0],1,'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            assertEqual(err.message, ...
                'Input should be non-zero length numeric vector with 3 components. It is: "1"')
        end

        function test_incorrect_constructor_throws_on_combo(~)
            assertExceptionThrown(...
                @()ortho_proj([1,0,0],[1,0,0],'alatt',[2,3,4],'angdeg',[80,70,85]),...
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


        function test_set_wrong_u(~)
            proj = ortho_proj([1,0,0],[0,1,0],'alatt',[2,3,4],'angdeg',[80,70,85]);
            function test_wrong()
                proj.u = [0,1,0];
            end

            assertExceptionThrown(@()test_wrong, ...
                'HORACE:ortho_proj:invalid_argument');
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
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,0])
            assertTrue(isempty(proj.w))
            assertElementsAlmostEqual(proj.offset,[0,0,0,0])
            assertEqual(proj.type,'aaa')
            full_box = expand_box([0,0,0,0],[1,1,1,1]);
            pixi = proj.transform_pix_to_img(full_box );
            assertElementsAlmostEqual(full_box,pixi);
            pixp = proj.transform_img_to_pix(pixi);
            assertElementsAlmostEqual(full_box,pixp);
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
            assertEqual(proj.type,'ppr')
        end
        %
        function test_uvw_set_in_constructor(~)
            proj = ortho_proj([1,0,0],[0,1,1],[0,-1,1]);
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,1])
            assertElementsAlmostEqual(proj.w,[0,-1,1])
        end


        function test_get_set_from_data_matrix_ppp_not90(~)
            proj1 = ortho_projTester([1,0,0],[0,1,0],[0,0,1],...
                'alatt',[2,4,3],'angdeg',[85,91,92],...
                'label',{'a','b','c','d'},'type','ppp');

            [~, u_to_rlu, ulen] = proj1.projaxes_to_rlu_public([1,1,1]);

            pror = ortho_projTester('alatt',[2,4,3],'angdeg',[85,91,92],...
                'label',{'a','b','c','d'});
            pror = pror.set_from_data_mat(u_to_rlu,ulen);

            tpixo = proj1.transform_pix_to_img(eye(3));
            tpixr = pror.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);
        end


        function test_get_set_from_data_matrix_ppr_not90(~)
            proj1 = ortho_projTester('alatt',[2,4,3],'angdeg',[92,87,98],...
                'label',{'a','b','c','d'},'type','ppr');

            [~, u_to_rlu, ulen] = proj1.projaxes_to_rlu_public([1,1,1]);

            pror = ortho_projTester('alatt',[2,4,3],'angdeg',[92,87,98],...
                'label',{'a','b','c','d'});
            pror = pror.set_from_data_mat(u_to_rlu,ulen);


            tpixo = proj1.transform_pix_to_img(eye(3));
            tpixr = pror.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);

        end

        function test_get_set_from_data_matrix_ppp(~)
            proj1 = ortho_projTester([1,0,0],[0,1,0],[0,0,1],...
                'alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'},'type','ppp');

            [~, u_to_rlu, ulen] = proj1.projaxes_to_rlu_public([1,1,1]);

            pror = ortho_projTester('alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'});
            pror = pror.set_from_data_mat(u_to_rlu,ulen);

            tpixo = proj1.transform_pix_to_img(eye(3));
            tpixr = pror.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);
        end


        function test_get_set_from_data_matrix_ppr(~)
            proj1 = ortho_projTester('alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'},'type','ppr');

            [~, u_to_rlu, ulen] = proj1.projaxes_to_rlu_public([1,1,1]);

            pror = ortho_projTester('alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'});
            pror = pror.set_from_data_mat(u_to_rlu,ulen);
            %assertEqualToTol(pror,proj1,'tol',[1.e-9,1.e-9]);

            tpixo = proj1.transform_pix_to_img(eye(3));
            tpixr = pror.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpixo,tpixr);

        end

        function test_get_projection_from_cut3D_sqw_no_offset(~)

            data = struct();
            data.alatt = [2.8580 2.8580 2.8580];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = ...
                [1, 0.3216,      0, 0;...
                -1, 0.3216,      0, 0;...
                00,      0, 0.4549, 0;...
                00,      0,      0, 1];

            data.uoffset = [0,0,0,0];
            data.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
            data.ulen = [3.1091;1;1;1];
            data.iax=3;
            data.pax=[1,2,4];
            data.iint=[1;30];
            data.p={1:10;1:20;1:40};
            ax = ortho_axes.get_from_old_data(data);
            proj = ortho_proj.get_from_old_data(data);

            do = DnDBase.dnd(ax,proj);

            proj1=do.proj;
            pp = proj1.transform_pix_to_img([eye(3),[1;1;1]]);
            p_ref =[...
                0.2274   -0.2274    0.0000    0.0000;...
                0.7071    0.7071   -0.0000    1.4142;...
                0         0         1.0000    1.0000];
            assertElementsAlmostEqual(pp,p_ref,'absolute',1.e-4);
            opt = ortho_projTester(proj1);

            [~, ~, ulen] = opt.projaxes_to_rlu_public();
            assertElementsAlmostEqual(data.ulen(1:3),ulen','absolute',1.e-4);
        end
        function test_get_projection_from_cut3D_sqw_offset(~)

            data = struct();
            data.alatt = [2.8580 2.8580 2.8580];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = ...
                [1, 0.3216,      0, 0;...
                -1, 0.3216,      0, 0;...
                00,      0, 0.4549, 0;...
                00,      0,      0, 1];
            data.uoffset = [1,1,0,0];      %(4x1)
            data.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
            data.ulen = [3.1091;1;1;1];
            data.iax=3;
            data.pax=[1,2,4];
            data.iint=[1;30];
            data.p={1:10;1:20;1:40};
            ax = ortho_axes.get_from_old_data(data);
            proj = ortho_proj.get_from_old_data(data);

            do = DnDBase.dnd(ax,proj);

            proj1=do.proj;
            pp = proj1.transform_pix_to_img([eye(3),[1;1;1]]);
            p_ref =[...
                -0.7726   -1.2274   -1.0000   -1.0000;...
                -0.2929   -0.2929   -1.0000    0.4142;...
                +     0         0    1.0000    1.0000];
            assertElementsAlmostEqual(pp,p_ref,'absolute',1.e-4);
            opt = ortho_projTester(proj1);

            [~, ~, ulen] = opt.projaxes_to_rlu_public();
            assertElementsAlmostEqual(data.ulen(1:3),ulen','absolute',1.e-4);
        end


        function test_get_projection_from_other_aligned_data(~)
            data = struct();
            data.alatt = [3.1580 3.1752 3.1247];
            data.angdeg = [90.0013 89.9985 90.0003];
            data.u_to_rlu = [...
                0.3541,-0.3465,-0.0921,  0;...
                0.3586, 0.3445, 0.0823,  0;...
                0.0069,-0.1217, 0.4821,  0;...
                0.0   ,      0,      0,  1];
            data.label = {'h','k','l','en'};
            data.ulen = ones(4,1);

            proj = ortho_proj.get_from_old_data(data);
            pc_ref = [...
                0.7027   -0.6876   -0.1828   -0.1677;...
                0.7115    0.6835    0.1633    1.5583;...
                0.0139   -0.2447    0.9695    0.7386];
            proj = proj.set_ub_inv_compat(inv(bmatrix(data.alatt,data.angdeg)));
            pc = proj.transform_pix_to_img([eye(3),[1;1;1]]);

            assertElementsAlmostEqual(pc_ref,pc,'absolute',1.e-4);

            opt = ortho_projTester(proj);
            [~, ~, ulen_rec] = opt .projaxes_to_rlu_public(ones(4,1));
            assertEqual(ulen_rec,ones(1,3));
        end

        function test_unity_transf_from_triclinic(~)

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 83],'type','ppr');
            [~, u_to_rlu,ulen] = prj_or.projaxes_to_rlu_public();

            b_m = bmatrix([3, 4 5],[85 95 83]);
            assertElementsAlmostEqual(ulen,diag(b_m)');

            pr_rec = prj_or.set_from_data_mat(u_to_rlu,ulen);

            tpixr = pr_rec.transform_pix_to_img(eye(3));
            tpixo = prj_or.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(tpixo,tpixr);
        end


        function test_unitu_transf_from_cubic(~)

            prj_or = ortho_projTester('alatt',[3, 4 5], ...
                'angdeg',[90 90 90],'type','ppr');
            [~, u_to_rlu,ulen] = prj_or.projaxes_to_rlu_public();

            b_m = bmatrix([3, 4 5],[90 90 90]);
            assertElementsAlmostEqual(ulen,diag(b_m)');
            pr_rec = prj_or.set_from_data_mat(u_to_rlu,ulen);

            tpix_r = pr_rec.transform_pix_to_img(eye(3));
            tpix_o = prj_or.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpix_r ,tpix_o);
        end

        %
        function test_get_projection_from_aligned_sqw_data(~)

            data = struct();
            data.alatt = [2.8449 2.8449 2.8449];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = ...
                [0.4528,-0.0012, 0.0017,    0;...
                00.0012, 0.4527, 0.0056,    0;...
                -0.0017,-0.0056, 0.4527,    0;...
                0     ,       0,      0,    1.0];
            data.uoffset = zeros(1,4);      %(4x1)
            data.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
            data.ulen = ones(4,1);
            data.iax=[];
            data.pax=[1,2,3,4];
            data.iint=[];
            data.p={1:10;1:20;1:30;1:40};
            %ax = ortho_axes.get_from_old_data(data);
            proj0 = ortho_proj.get_from_old_data(data);

            %do = data_sqw_dnd(ax,proj);

            %opt = ortho_projTester(proj1);
            projr = proj0;
            projr.ub_inv_legacy = inv(bmatrix(data.alatt,data.angdeg));

            pix_cc = [eye(3),ones(3,1)];
            % this is what is what is only important for any transformation
            tpixo = proj0.transform_pix_to_img(pix_cc);
            tpixr = projr.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(tpixo,tpixr);


        end

        function test_get_projection_from_legacy_sqw_data(~)

            data = struct();
            data.alatt = [2,3,4];
            data.angdeg = [90,90,90];
            %
            data.u_to_rlu = eye(4).*[1/pi;1.5/pi;2/pi;1]; %(4x4)
            data.uoffset = zeros(1,4);      %(4x1)
            data.ulabel = {'a','b','c','d'};
            data.ulen = ones(4,1);
            data.iax=[];
            data.pax=[1,2,3,4];
            data.iint=[];
            data.p={1:10;1:20;1:30;1:40};
            ax = ortho_axes.get_from_old_data(data);
            proj0 = ortho_proj.get_from_old_data(data);


            projr = ortho_proj('alatt',data.alatt,'angdeg',data.angdeg,...
                'label',{'a','b','c','d'},'type','aaa');

            pix_cc = [eye(3),ones(3,1)];
            % this is what is what is only important for any transformation
            tpixo = proj0.transform_pix_to_img(pix_cc);
            tpixr = projr.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(tpixo,tpixr);

        end
    end
end
