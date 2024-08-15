classdef test_line_proj_construction<TestCase
    % testing line_proj class constructor
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
        function test_old_interface(~)
            proj = line_proj([0,1,0],[1,0,0],[],'uoffset',[1,1,0,0], ...
                'alatt',[1,2,3],'angdeg',90);
            assertEqual(proj.u,[0,1,0]);
            assertEqual(proj.v,[1,0,0]);
            assertTrue(isempty(proj.w));
            assertEqual(proj.type,'ppr');
            assertElementsAlmostEqual(proj.offset,[1,1,0,0]);
        end
        function test_no_lattice_throws_on_acces_to_transf(~)
            proj = line_proj([1,0,0],[0,1,0],...
                'alatt',[2,3,4],'type','aaa',...
                'w',[0,0,1]);
            assertExceptionThrown(@()transform_pix_to_img(proj,ones(4,1)), ...
                'HORACE:line_proj:runtime_error');
        end

        function test_no_lattice_throws_on_b_matrix(~)
            proj = line_proj([1,0,0],[0,1,0],...
                'alatt',[2,3,4],'type','aaa',...
                'w',[0,0,1]);
            assertExceptionThrown(@()bmatrix(proj), ...
                'HORACE:aProjectionBase:runtime_error');
        end

        function test_constructor_keys_overrides_positional_argument(~)
            proj = line_proj([1,0,0],[0,1,0],...
                'alatt',[2,3,4],'type','aaa','nonorthogonal',true,...
                'w',[0,0,1]);
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0]);
            assertEqual(proj.w,[0,0,1]);
            assertEqual(proj.alatt,[2,3,4]);
            assertTrue(isempty(proj.angdeg));
            assertEqual(proj.type,'aaa');
            assertEqual(proj.nonorthogonal,true);
        end

        function test_constructor_type(~)
            proj = line_proj([1,0,0],[0,1,0],[0,0,1],...
                'alatt',[2,3,4],'type','aaa');
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0]);
            assertEqual(proj.w,[0,0,1]);
            assertEqual(proj.alatt,[2,3,4]);
            assertTrue(isempty(proj.angdeg));
            assertEqual(proj.type,'aaa');
        end

        function test_constructor_third_long_argument_throws(~)
            err=assertExceptionThrown(...
                @()line_proj([1,0,0],[0,1,0],[1,1,1,1],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            samp = 'Input should be non-zero length numeric vector with 3 components. It is: "1     1     1     1"';
            assertEqual(err.message,samp);
        end

        function test_constructor_third_zero_argument_throws(~)
            err=assertExceptionThrown(...
                @()line_proj([1,0,0],[0,1,0],[0,0,0],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            assertEqual(err.message,...
                'Input can not be a 0-vector: [0,0,0] with all components smaller then tol = 1e-12');
        end

        function test_incorrect_constructor_throws_on_positional_zero(~)
            err = assertExceptionThrown(...
                @()line_proj([0,0,0],1,'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            assertEqual(err.message, ...
                'Input can not be a 0-vector: [0,0,0] with all components smaller then tol = 1e-12')
        end

        function test_incorrect_constructor_throws_on_positional_argument(~)
            err= assertExceptionThrown(...
                @()line_proj([1,0,0],1,'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:aProjectionBase:invalid_argument');
            assertEqual(err.message, ...
                'Input should be non-zero length numeric vector with 3 components. It is: "1"')
        end

        function test_incorrect_constructor_throws_on_combo_check(~)
            assertExceptionThrown(...
                @()line_proj([1,0,0],[1,0,0],'alatt',[2,3,4],'angdeg',[80,70,85]),...
                'HORACE:line_proj:invalid_argument');
        end

        function test_three_vector_constructor(~)
            proj = line_proj([1,0,0],[0,1,0],[0,0,1],...
                'alatt',[2,3,4],'angdeg',[80,70,85]);
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0]);
            assertEqual(proj.w,[0,0,1]);
            assertEqual(proj.alatt,[2,3,4]);
            assertEqual(proj.angdeg,[80,70,85]);
        end


        function test_set_collinear_u_throws(~)
            proj = line_proj([1,0,0],[0,1,0],'alatt',[2,3,4],'angdeg',[80,70,85]);
            function test_wrong()
                proj.u = [0,1,0];
            end

            assertExceptionThrown(@()test_wrong, ...
                'HORACE:line_proj:invalid_argument');
        end
        function test_serialization(~)
            proj = line_proj([1,0,0],[0,1,0],'alatt',[2,3,4],'angdeg',[80,70,85]);

            ser = proj.serialize();
            rec = serializable.deserialize(ser);

            assertEqual(proj,rec);
        end

        %------------------------------------------------------------------
        function test_default_constructor(~)
            proj = line_proj();
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,0])
            assertTrue(isempty(proj.w))
            assertElementsAlmostEqual(proj.offset,[0,0,0,0])
            assertEqual(proj.type,'ppr')
            full_box = expand_box([0,0,0],[1,1,1]);
            proj.alatt = 1;
            proj.angdeg = 90;
            pixi = proj.transform_pix_to_img(full_box );
            assertElementsAlmostEqual(full_box/(2*pi),pixi);
            pixp = proj.transform_img_to_pix(pixi);
            assertElementsAlmostEqual(full_box,pixp);
        end
        %
        function test_invalid_constructor_throws(~)
            f = @()line_proj([0,1,0]);
            assertExceptionThrown(f,'HORACE:line_proj:invalid_argument');
        end
        %
        function test_uv_set_in_constructor(~)
            proj = line_proj([0,1,0],[1,0,0]);
            assertElementsAlmostEqual(proj.u,[0,1,0])
            assertElementsAlmostEqual(proj.v,[1,0,0])
            assertTrue(isempty(proj.w))
            assertEqual(proj.type,'ppr')
        end
        %
        function test_uvw_set_in_constructor(~)
            proj = line_proj([1,0,0],[0,1,1],[0,-1,1]);
            assertElementsAlmostEqual(proj.u,[1,0,0])
            assertElementsAlmostEqual(proj.v,[0,1,1])
            assertElementsAlmostEqual(proj.w,[0,-1,1])
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
            ax = line_axes.get_from_old_data(data);
            proj = line_proj.get_from_old_data(data);

            dobj = DnDBase.dnd(ax,proj);

            proj1=dobj.proj;
            pp = proj1.transform_pix_to_img([eye(3),[1;1;1]]);
            p_ref =[...
                0.2274   -0.2274    0.0000    0.0000
                0.7072    0.7072    0.0000    1.4144
                0         0    0.9999    0.9999];
            assertElementsAlmostEqual(pp,p_ref,'absolute',1.e-4);
            opt = line_projTester(proj1);

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
                +0,      0, 0.4549, 0;...
                +0,      0,      0, 1];
            data.uoffset = [1,1,0,0];      %(4x1)
            data.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
            data.ulen = [3.1091;1;1;1];
            data.iax=3;
            data.pax=[1,2,4];
            data.iint=[1;30];
            data.p={1:10;1:20;1:40};
            ax   = line_axes.get_from_old_data(data);
            proj = line_proj.get_from_old_data(data);

            do = DnDBase.dnd(ax,proj);

            proj1=do.proj;
            pp = proj1.transform_pix_to_img([eye(3),[1;1;1]]);
            p_ref =[...
                0.2274   -0.2274    0.0000    0.0000
                -2.4023   -2.4023   -3.1095   -1.6951
                0         0    0.9999    0.9999];
            assertElementsAlmostEqual(pp,p_ref,'absolute',1.e-4);
            opt = line_projTester(proj1);

            ulen = opt.ulen;
            assertElementsAlmostEqual(data.ulen,ulen','absolute',1.e-4);

            pcl = opt.transform_pix_to_img([eye(3),[1;1;1]]);
            assertElementsAlmostEqual(pp,pcl,'absolute',4.e-4);
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

            proj = line_proj.get_from_old_data(data);
            pc_ref = [...
                0.7008    0.7133    0.0126    1.4267;...
                -0.6857    0.6855   -0.2448   -0.2449;...
                -0.1831    0.1628    0.9695    0.9492];

            pc = proj.transform_pix_to_img([eye(3),[1;1;1]]);

            assertElementsAlmostEqual(pc_ref,pc,'absolute',1.e-4);

            opt = line_projTester(proj);
            [~, ~, ulen_rec] = opt .projaxes_to_rlu_public(ones(4,1));
            assertEqual(ulen_rec,ones(1,3));
            pcl = opt.transform_pix_to_img([eye(3),[1;1;1]]);
            assertElementsAlmostEqual(pc,pcl,'absolute',1.e-4);
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
            ax = line_axes.get_from_old_data(data);
            proj0 = line_proj.get_from_old_data(data);


            projr = line_proj('alatt',data.alatt,'angdeg',data.angdeg,...
                'label',{'a','b','c','d'},'type','aaa');

            pix_cc = [eye(3),ones(3,1)];
            % this is what is what is only important for any transformation
            tpixo = proj0.transform_pix_to_img(pix_cc);
            tpixr = projr.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(tpixo,tpixr);
        end

        function test_default_param_constructor(~)
            param_list = {'u','v','w','nonorthogonal','type','alatt','angdeg',...
                'offset','label','title'};
            param_values = {[1,0,0],[0,1,0],[0,0,1],true,'aaa',[1,2,3],...
                [80,70,120],[1,0,0,1],{'xx','yy','zz','ee'},'Some custom title'};
            lp = line_proj(param_values{:});
            for i=1:numel(param_list)
                assertEqual(lp.(param_list{i}),param_values{i});
            end
        end
    end
end
