classdef test_sphere_proj<TestCase
    % The test class to verify how projection works
    %
    properties
    end

    methods
        function this=test_sphere_proj(name)
            if nargin == 0
                name = 'test_sphere_proj';
            end
            this=this@TestCase(name);
        end

        %------------------------------------------------------------------
        function test_coord_transf_PixData_plus_offset(~)
            proj = sphere_proj('alatt',2*pi,'angdeg',90);
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
            proj = sphere_proj('alatt',2*pi,'angdeg',90);
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
        function test_coord_transf_3D_plus_offset_throw_no_lattice(~)
            proj = sphere_proj('alatt',2*pi);
            proj.offset = [1,2,3,4];
            pix0 = [...
                100,  0, 0 ,1;...
                0  , 10, 0 ,1;...
                0  ,  0, 1 ,1];
            ME=assertExceptionThrown(@()transform_pix_to_img(proj,pix0),...
                'HORACE:aProjectionBase:runtime_error');
            assertTrue(strncmp(ME.message, ...
                'Attempt to use hkl-coordinate transformations',45))
        end


        function test_coord_transf_3D_plus_offset(~)
            proj = sphere_proj('alatt',2*pi,'angdeg',90);
            proj.offset = [1,2,3,4];
            pix0 = [...
                100,  0, 0 ,1;...
                0  , 10, 0 ,1;...
                0  ,  0, 1 ,1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end

        function test_invalid_type_throws(~)
            proj = sphere_proj();
            function type_setter(proj,val)
                proj.type = val;
            end
            assertExceptionThrown(@()type_setter(proj,'a'),...
                'HORACE:sphere_proj:invalid_argument');
            assertExceptionThrown(@()type_setter(proj,20),...
                'HORACE:sphere_proj:invalid_argument');

            assertExceptionThrown(@()type_setter(proj,'abb'),...
                'HORACE:sphere_proj:invalid_argument');

            assertExceptionThrown(@()type_setter(proj,'xrr'),...
                'HORACE:sphere_proj:invalid_argument');
        end

        function test_coord_sphere_ranged_rad(~)
            proj = sphere_proj();
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
            proj = sphere_proj();
            proj.type = "add";
            assertEqual(proj.type,'add')
            pix0 = [100,0,0,1;0,10,0,1;0,0,1,1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end

        function test_coord_transf_3D_radian(~)
            proj = sphere_proj();
            proj.type = "arr";
            assertEqual(proj.type,'arr')
            pix0 = [...
                100, 0, 0, 1;...
                0  ,10, 0, 1;...
                0  , 0, 1, 1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end

        function test_set_direction_110_cub(~)
            proj = sphere_proj([1,-1,0],[1,1,0],'alatt',2*pi,'angdeg',90);
            assertEqual(proj.ez,[1,-1,0])
            assertEqual(proj.ex,[1, 1,0])
            ref_vec = [...
                1. ,   1.,    1.; ... R
                45 , 135.,   90.; ... Theta
                0  ,   0.,   90.; ... phi
                ];
            spher = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,spher);
            pix_cc = proj.transform_img_to_pix(spher);
            assertElementsAlmostEqual(eye(3),pix_cc );
        end



        function test_set_direction_010(~)
            proj = sphere_proj([0,1,0],[1,0,0]);
            assertEqual(proj.ez,[0,1,0])
            assertEqual(proj.ex,[1,0,0])
            ref_vec = [...
                1. ,   1.,    1.; ... R
                90 ,   0.,   90.; ... Theta
                0  ,   0.,  -90.; ... phi
                ];
            spher = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,spher);
        end


        function test_set_direction_001(~)
            proj = sphere_proj([0,0,1],[1,0,0]);
            assertEqual(proj.ez,[0,0,1])
            assertEqual(proj.ex,[1,0,0])
            ref_vec = [...
                1. ,   1.,    1.; ... R
                90 ,  90.,    0.; ... Theta
                0  ,  90.,    0.; ... phi
                ];
            spher = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,spher);
        end

        function test_empty_constructor(~)
            proj = sphere_proj();
            assertEqual(proj.ez,[1,0,0]);
            assertEqual(proj.ex,[0,1,0])

            ref_vec = [...
                1,  1.,  1.; ... R
                0, 90., 90.; ... Theta
                0,  0., 90.; ... phi
                ];
            spher = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,spher);

        end
    end
end
