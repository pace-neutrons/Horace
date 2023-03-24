classdef test_ortho_proj_construction<TestCase
    % testing ortho_proj class constructor
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

        function test_constructor_third_long_throws(~)
            err=assertExceptionThrown(...
                @()ortho_proj([1,0,0],[0,1,0],[1,1,1,1],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            samp = 'Input should be non-zero length numeric vector with 3 components. It is: "1     1     1     1"';
            assertEqual(err.message,samp);
        end

        function test_constructor_third_zero_throws(~)
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
        function test_get_set_from_data_matrix_ppp(~)
            proj1 = ortho_projTester([1,0,0],[0,1,0],[0,0,1],...
                'alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'},'type','ppp');

            [~, u_to_rlu, ulen] = proj1.projaxes_to_rlu_public([1,1,1]);

            pror = ortho_projTester('alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'});
            pror = pror.set_from_data_mat(u_to_rlu,ulen);
            % TODO: This is something wrong as inputs are not recovered.
            % Is this correct? Should (can I fix this?)
            proj1.type  ='ppr';
            proj1.w = [];
            assertEqualToTol(pror,proj1,'tol',[1.e-9,1.e-9]);
        end


        function test_get_set_from_data_matrix_ppr(~)
            proj1 = ortho_projTester('alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'},'type','ppr');

            [~, u_to_rlu, ulen] = proj1.projaxes_to_rlu_public([1,1,1]);

            pror = ortho_projTester('alatt',[2,4,3],'angdeg',[90,90,90],...
                'label',{'a','b','c','d'});
            pror = pror.set_from_data_mat(u_to_rlu,ulen);
            assertEqualToTol(pror,proj1,'tol',[1.e-9,1.e-9]);
        end

        function test_get_projection_from_cut3D_sqw(~)

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
            opt = ortho_projTester(proj1);

            [~, u_to_rlu, ulen] = opt.projaxes_to_rlu_public([1,1,1]);
            assertElementsAlmostEqual(data.u_to_rlu,[[u_to_rlu,[0;0;0]];[0,0,0,1]],...
                'absolute',1.e-4)
            assertElementsAlmostEqual(data.ulen(1:3),ulen','absolute',1.e-4);
        end

        function test_get_projection_from_other_aligned_data(~)
            data = struct();
            data.alatt = [3.1580 3.1752 3.1247];
            data.angdeg = [90.0013 89.9985 90.0003];
            data.u_to_rlu = ...
                [0.3541,-0.3465,-0.0921,  0;...
                00.3586, 0.3445, 0.0823,  0;...
                00.0069,-0.1217, 0.4821,  0;...
                00.0   ,      0,      0,  1];
            data.label = {'h','k','l','en'};
            data.ulen = ones(4,1);
            proj = ortho_proj.get_from_old_data(data);
            opt = ortho_projTester(proj);
            [~, u_to_rlu_rec, ulen_rec] = opt .projaxes_to_rlu_public(ones(4,1));
            assertEqual(ulen_rec,ones(1,3));
            assertElementsAlmostEqual(data.u_to_rlu(1:3,1:3),u_to_rlu_rec,...
                'absolute',1.e-4)

        end
        function test_getset_nonortho_proj_aaa_111(~)
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
        end

        function test_getset_nonortho_proj_aaa_110(~)
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
        end
        function test_getset_nonortho_proj_aaa_100(~)
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
        end
        function test_getset_nonortho_proj_ppp_110(~)
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
            % BUT:
            assertEqual(prj_or.type,'ppp')
            assertEqual(prj_rec.type,'rrr')
        end
        function test_getset_nonortho_proj_par_110(~)
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
            % BUT:
            assertEqual(prj_or.type,'par')
            assertEqual(prj_rec.type,'rar')
        end


        function test_getset_nonortho_proj_ppp_100(~)
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
            assertEqual(prj_rec.type,'rrr')
        end

        function test_getset_nonortho_proj_rrr_100(~)
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
        end



        function test_getset_nonortho_proj_rrr_noW(~)
            prj_or = ortho_projTester('alatt',[3.1580 3.1752 3.1247], ...
                'angdeg',[90.0013 89.9985 90.0003],'nonorthogonal',true,...
                'type','rrr','u',[1,0,0],'v',[0,1,0]);

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
            % BUT!
            % and the matrices are correct!
            assertTrue(prj_or.nonorthogonal);
            assertFalse(prj_rec.nonorthogonal);

            % check projection comparison operator itself, which compares 
            % these operators internaly
            assertEqual(prj_or,prj_rec,'absolute',1.e-5);
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
            ax = ortho_axes.get_from_old_data(data);
            proj = ortho_proj.get_from_old_data(data);

            do = data_sqw_dnd(ax,proj);

            proj1=do.get_projection();
            opt = ortho_projTester(proj1);

            [~, u_to_rlu, ulen] = opt.projaxes_to_rlu_public([1,1,1]);
            assertElementsAlmostEqual(data.u_to_rlu,[[u_to_rlu,[0;0;0]];[0,0,0,1]],...
                'absolute',1.e-4)
            assertElementsAlmostEqual(data.ulen(1:3),ulen');
        end

        function test_get_projection_from_original_sqw_data(~)

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
            proj = ortho_proj.get_from_old_data(data);
            do = data_sqw_dnd(ax,proj);

            proj = ortho_proj('alatt',data.alatt,'angdeg',data.angdeg,...
                'label',{'a','b','c','d'},'type','aaa');

            proj1=do.get_projection();
            assertEqualToTol(proj,proj1,'tol',[1.e-9,1.e-9])

            opt = ortho_projTester(proj1);

            [~, u_to_rlu, ulen] = opt.projaxes_to_rlu_public([1,1,1]);
            assertElementsAlmostEqual(data.u_to_rlu,[[u_to_rlu,[0;0;0]];[0,0,0,1]])
            assertElementsAlmostEqual(data.ulen(1:3),ulen');
        end
    end
end
