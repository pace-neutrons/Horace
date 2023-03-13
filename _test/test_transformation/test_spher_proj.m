classdef test_spher_proj<TestCase
    % The test class to verify how projection works
    %
    properties
    end

    methods
        function this=test_spher_proj(name)
            if nargin == 0
                name = 'test_spher_proj';
            end
            this=this@TestCase(name);
        end
        %------------------------------------------------------------------
        function test_coord_transf_PixData_plus_offset(~)
            proj = spher_proj();
            proj.offset = [1,2,3,4];
            qPix0 = [100,0,0,1;0,10,0,1;0,0,1,1;10,10,10,10];
            s_pix = ones(5,4);
            pix0  = [qPix0;s_pix];
            pix = PixelDataMemory(pix0);

            sph  = proj.transform_pix_to_img(pix);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix.coordinates,pix_rec);
        end

        function test_coord_transf_4D_plus_offset(~)
            proj = spher_proj();
            proj.offset = [1,2,3,4];
            pix0 = ...
                [100, 0, 0, 1;...
                0   ,10, 0, 1;...
                0,    0, 1, 1;...
                10 , 10,10,10];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end

        function test_coord_transf_3D_plus_offset(~)
            proj = spher_proj();
            proj.offset = [1,2,3,4];
            pix0 = [100,0,0,1;0,10,0,1;0,0,1,1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end

        function test_invalid_type_throws(~)
            proj = spher_proj();
            function type_setter(proj,val)
                proj.type = val;
            end
            assertExceptionThrown(@()type_setter(proj,'a'),...
                'HORACE:spher_proj:invalid_argument');
            assertExceptionThrown(@()type_setter(proj,20),...
                'HORACE:spher_proj:invalid_argument');

            assertExceptionThrown(@()type_setter(proj,'abb'),...
                'HORACE:spher_proj:invalid_argument');

            assertExceptionThrown(@()type_setter(proj,'xrr'),...
                'HORACE:spher_proj:invalid_argument');
        end

        function test_coord_spher_ranged_rad(~)
            proj = spher_proj();
            proj.type = "arr";

            pix0 = ...
                [10,-10, 0,   0,  0,  0, 0;...
                0 ,  0, 10, -10,  0,  0, -1;...
                0 ,  0,  0,   0, 10,-10, -1];

            sph  = proj.transform_pix_to_img(pix0);

            sam_ranges = ...
                [10,  10,  10,   10,   10, 10 , sqrt(2);...
                0  ,  pi, pi/2,pi/2, pi/2, pi/2, pi/2   ;... % Theta ranges [ 0 : pi]
                0  ,   0,  0,  pi,   pi/2,-pi/2,  -3*pi/4];   % phi ranges   [-pi: pi]
            assertElementsAlmostEqual(sph,sam_ranges);

            pixr  = proj.transform_img_to_pix(sph);
            assertElementsAlmostEqual(pixr,pix0);

        end

        function test_coord_transf_3D_deg(~)
            proj = spher_proj();
            proj.type = "add";
            assertEqual(proj.type,'add')
            pix0 = [100,0,0,1;0,10,0,1;0,0,1,1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end

        function test_coord_transf_3D_radian(~)
            proj = spher_proj();
            proj.type = "arr";
            assertEqual(proj.type,'arr')
            pix0 = [100,0,0,1;0,10,0,1;0,0,1,1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end

        function test_set_get_e(~)
            % TODO: implement #967
            ws = warning('off','HORACE:spher_proj:not_implemented');
            clOb = onCleanup(@()warning(ws));
            proj = spher_proj();
            proj.ez = [1,0,0];
            % not implemented----------------
            assertEqual(proj.ez,[0,0,1])
            [~,lw] = lastwarn;
            assertEqual(lw,'HORACE:spher_proj:not_implemented')
            proj.ey = [0,0,1];
            assertEqual(proj.ey,[0,1,0])
            [~,lw] = lastwarn;
            assertEqual(lw,'HORACE:spher_proj:not_implemented')
            skipTest('Beam axis reorientation have not yet been implemented See #967')
        end

        function test_empty_constructor(~)
            proj = spher_proj();
            assertEqual(proj.ez,[0,0,1]);
            assertEqual(proj.ey,[0,1,0])
        end
    end
end
