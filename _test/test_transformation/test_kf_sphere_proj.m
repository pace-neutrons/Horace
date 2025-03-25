classdef test_kf_sphere_proj<TestCase
    % The test class to verify how projection works
    %
    properties
    end

    methods
        function this=test_kf_sphere_proj(name)
            if nargin == 0
                name = 'test_kf_sphere_proj';
            end
            this=this@TestCase(name);
        end
        %------------------------------------------------------------------
        function test_kf_sphere_caption(~)
            sp = kf_sphere_proj();
            ax = sp.get_proj_axes_block(cell(1,4),{[0,10],[0,2,70],[-180,180],[-10,2,50]});

            title = ax.main_title({'\theta','En'},{'kf_integrated','phi_integrated'});

            assertEqual(numel(title),4);
            assertEqual(title{2},'Instument view along beam direction');
        end
        %------------------------------------------------------------------
        function test_coord_transf_PixData_plus_offset_not_implemented(~)
            proj = kf_sphere_proj('alatt',2*pi,'angdeg',90);
            assertExceptionThrown(@()set(proj,'offset',[1,2,3,4]), ...
                'HORACE:kf_sphere_proj:not_implemented');
        end

        function test_coord_kf_sphere_ranged_rad(~)
            proj = kf_sphere_proj();
            proj.type = "arr";
            proj.Ei = 10;
            kimd = proj.ki_mod;
            pix0 = [...
                kimd,-kimd,    0,    0,     0,  0,    0;...
                0   ,    0, kimd,-kimd,     0,  0,   -1;...
                0   ,    0,    0,    0, kimd ,-kimd,  1];
            % disable interdependent properties check
            proj.do_check_combo_arg = false;

            proj.cc_to_spec_mat = {eye(3)};
            proj.run_id_mapper  = fast_map(1,1);
            proj.do_check_combo_arg  = true;
            proj = proj.check_combo_arg();


            sph  = proj.transform_pix_to_img(pix0);

            pixr  = proj.transform_img_to_pix(sph);
            assertElementsAlmostEqual(pixr,pix0);

        end

        function test_empty_constructor(~)
            proj = kf_sphere_proj('type','add');
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0])
        end
    end
end
