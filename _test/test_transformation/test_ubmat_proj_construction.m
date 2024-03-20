classdef test_ubmat_proj_construction<TestCase
    % testing line_proj class constructor
    %
    properties
        tests_folder
    end

    methods
        function this=test_ubmat_proj_construction(varargin)
            if nargin == 0
                name = 'test_ubmat_proj_construction';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
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
            proj = ubmat_proj(data);

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
            ax = line_axes.get_from_old_data(data);
            data.warn_on_legacy_data = false;
            proj = ubmat_proj(data);

            do = DnDBase.dnd(ax,proj);

            proj1=do.proj;
            pp = proj1.transform_pix_to_img([eye(3),[1;1;1]]);
            p_ref =[...
                0.2274   -0.2274    0.0000    0.0000
                -2.4023   -2.4023   -3.1095   -1.6951
                0         0    0.9999    0.9999];
            assertElementsAlmostEqual(pp,p_ref,'absolute',1.e-4);
            opt = line_projTester(proj1);

            [~, ~, ulen] = opt.projaxes_to_rlu_public();
            assertElementsAlmostEqual(data.ulen(1:3),ulen','absolute',1.e-4);
        end
        %
        %
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

            proj = ubmat_proj(data);
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

        function test_unity_transf_from_triclinic(~)

            prj_or = line_projTester('alatt',[3, 4 5], ...
                'angdeg',[85 95 83],'type','ppr');
            [~, u_to_rlu,ulen] = prj_or.projaxes_to_rlu_public();

            b_m = bmatrix([3, 4 5],[85 95 83]);
            assertElementsAlmostEqual(ulen,diag(b_m)');

            pr_rec = ubmat_proj(u_to_rlu,ulen,'alatt',[3,4,5],'angdeg',[85 95 83]);

            tpixr = pr_rec.transform_pix_to_img(eye(3));
            tpixo = prj_or.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(tpixo,tpixr);
        end
        %
        function test_unity_transf_from_cubic(~)

            prj_or = line_projTester('alatt',[3, 4 5], ...
                'angdeg',[90 90 90],'type','ppr');
            [~, u_to_rlu,ulen] = prj_or.projaxes_to_rlu_public();

            b_m = bmatrix([3, 4 5],[90 90 90]);
            assertElementsAlmostEqual(ulen,diag(b_m)');
            pr_rec = ubmat_proj(u_to_rlu,ulen,'alatt',[3,4,5],'angdeg',90);

            tpix_r = pr_rec.transform_pix_to_img(eye(3));
            tpix_o = prj_or.transform_pix_to_img(eye(3));
            assertElementsAlmostEqual(tpix_r ,tpix_o);
        end
        %
        % %
        % function test_get_projection_from_aligned_sqw_data(~)
        %
        %     data = struct();
        %     data.alatt = [2.8449 2.8449 2.8449];
        %     data.angdeg = [90,90,90];
        %     %
        %     data.u_to_rlu = ...
        %         [0.4528,-0.0012, 0.0017,    0;...
        %         00.0012, 0.4527, 0.0056,    0;...
        %         -0.0017,-0.0056, 0.4527,    0;...
        %         0     ,       0,      0,    1.0];
        %     data.uoffset = zeros(1,4);      %(4x1)
        %     data.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
        %     data.ulen = ones(4,1);
        %     data.iax=[];
        %     data.pax=[1,2,3,4];
        %     data.iint=[];
        %     data.p={1:10;1:20;1:30;1:40};
        %     %ax = line_axes.get_from_old_data(data);
        %     proj0 = line_proj.get_from_old_data(data);
        %
        %     %do = data_sqw_dnd(ax,proj);
        %
        %     %opt = line_projTester(proj1);
        %     projr = proj0;
        %     projr.ub_inv_legacy = inv(bmatrix(data.alatt,data.angdeg));
        %
        %     pix_cc = [eye(3),ones(3,1)];
        %     % this is what is what is only important for any transformation
        %     tpixo = proj0.transform_pix_to_img(pix_cc);
        %     tpixr = projr.transform_pix_to_img(pix_cc);
        %     assertElementsAlmostEqual(tpixo,tpixr);
        % end
        %
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
            proj0 = ubmat_proj.get_from_old_data(data);
            proj1 = line_proj.get_from_old_data(data);


            assertEqual(proj0,proj1);
            projr = line_proj('alatt',data.alatt,'angdeg',data.angdeg,...
                'label',{'a','b','c','d'},'type','aaa');

            pix_cc = [eye(3),ones(3,1)];
            % this is what is what is only important for any transformation
            tpixo = proj0.transform_pix_to_img(pix_cc);
            tpixr = projr.transform_pix_to_img(pix_cc);
            assertElementsAlmostEqual(tpixo,tpixr);
        end
        %------------------------------------------------------------------
        function test_transf_get_from_nonorth_proj_cmpl_nonorth_lat_ortho_proj(~)
            line_proj_param = {[-1,1,0],[1,1,1],[],true,...
                'apr',[1,2,3],[120,70,100],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end


        function test_transform_get_from_nonorth_proj_nonorth_lat_ortho_proj(~)
            line_proj_param = {[1,0,0],[0,1,0],[],true,...
                'apr',[1,2,3],[120,70,100],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end

        function test_transform_get_from_nonorth_proj_cmpl_ortho_lat_ortho_proj(~)
            line_proj_param = {[-1,1,0],[1,1,1],[],true,...
                'apr',[1,2,3],[90,90,90],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end

        function test_transform_get_from_nonorth_proj_ortho_lat_ortho_proj(~)
            line_proj_param = {[1,0,0],[0,1,0],[],true,...
                'apr',[1,2,3],[90,90,90],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end

        %------------------------------------------------------------------
        function test_transform_get_from_line_proj_cmpl_nonorth_lat_ortho_proj(~)
            line_proj_param = {[-1,1,0],[1,1,1],[],false,...
                'apr',[1,2,3],[120,70,100],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end


        function test_transform_get_from_line_proj_nonorth_lat_ortho_proj(~)
            line_proj_param = {[1,0,0],[0,1,0],[],false,...
                'apr',[1,2,3],[120,70,100],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end

        function test_transform_get_from_line_proj_cmpl_ortho_lat_ortho_proj(~)
            line_proj_param = {[-1,1,0],[1,1,1],[],false,...
                'apr',[1,2,3],[90,90,90],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end

        function test_transform_get_from_line_proj_ortho_lat_ortho_proj(~)
            line_proj_param = {[1,0,0],[0,1,0],[],false,...
                'apr',[1,2,3],[90,90,90],[1,0,0,0],{'a','b','c','d'},'test_line_proj'};
            lp = line_proj(line_proj_param{:});

            ubp = lp.get_ubmat_proj();
            assertEqualToTol(ubp,lp,1.e-8);

            lpr = ubp.get_line_proj();

            assertEqual(lp,lpr);
        end
        %------------------------------------------------------------------
        function test_default_param_constructor(~)
            param_list = {'u_to_rlu','ulen','alatt','angdeg','offset','label','title'};
            param_values = {[0,1,0,0;1,0,1,0;0,0,2,0;0,0,0,1],[2,2,2,2],[1,2,3],...
                [80,70,120],[1,0,0,1],{'xx','yy','zz','ee'},'Some custom title'};
            lp = ubmat_proj(param_values{:});
            for i=1:numel(param_list)
                assertEqual(lp.(param_list{i}),param_values{i});
            end
        end

        function test_empty_constructor(~)
            param_list = {'u_to_rlu','ulen','alatt','angdeg','offset','label','title'};
            default_values = {eye(4),ones(1,4),[],[],zeros(1,4),{'\zeta','\xi','\eta','E'},''};
            lp = ubmat_proj();
            for i=1:numel(param_list)
                assertEqual(lp.(param_list{i}),default_values{i});
            end
        end
    end
end
