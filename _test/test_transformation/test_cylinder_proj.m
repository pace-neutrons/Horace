classdef test_cylinder_proj<TestCase
    % The test class to verify how projection works
    %
    properties
    end

    methods
        function this=test_cylinder_proj(name)
            if nargin == 0
                name = 'test_cylinder_proj';
            end
            this=this@TestCase(name);
        end

        %------------------------------------------------------------------
        function test_coord_transf_PixData_plus_offset(~)
            proj = cylinder_proj('alatt',2*pi,'angdeg',90);
            proj.offset = [1,2,3,4];
            qPix0 = [100,0,0,1;0,10,0,1;0,0,1,1;10,10,10,10];
            s_pix = ones(5,4);
            pix0  = [qPix0;s_pix];
            pix = PixelDataMemory(pix0);

            cyl  = proj.transform_pix_to_img(pix);
            pix_rec = proj.transform_img_to_pix(cyl);

            assertElementsAlmostEqual(pix.coordinates,pix_rec);
        end
        %
        function test_coord_transf_4D_plus_offset(~)
            proj = cylinder_proj('alatt',[2,3,4],'angdeg',[110,80,95]);
            proj.offset = [1,2,3,4];
            pix0 = ...
                [100, 0, 0, 1;...
                0   ,10, 0, 1;...
                0,    0, 1, 1;...
                10 , 10,10,10];

            cyl  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(cyl);

            assertElementsAlmostEqual(pix0,pix_rec);
        end
        function test_coord_transf_3D_plus_offset_throw_no_lattice(~)
            proj = cylinder_proj('alatt',2*pi);
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
            proj = cylinder_proj('alatt',2*pi,'angdeg',90);
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
            proj = cylinder_proj();
            function type_setter(proj,val)
                proj.type = val;
            end
            assertExceptionThrown(@()type_setter(proj,'a'),...
                'HORACE:CurveProjBase:invalid_argument');
            assertExceptionThrown(@()type_setter(proj,20),...
                'HORACE:CurveProjBase:invalid_argument');

            assertExceptionThrown(@()type_setter(proj,'abb'),...
                'HORACE:CurveProjBase:invalid_argument');

            assertExceptionThrown(@()type_setter(proj,'xrr'),...
                'HORACE:CurveProjBase:invalid_argument');
        end
        %
        function test_coord_sphere_ranged_rad(~)
            proj = cylinder_proj();
            proj.type = "aar";

            pix0 = ...
                [10,-10, 0,   0,  0,  0, 0;...
                0 ,  0, 10, -10,  0,  0, -1;...
                0 ,  0,  0,   0, 10,-10, -1];

            cyl  = proj.transform_pix_to_img(pix0);

            sam_cyl = [...
                0 ,  0, 10, 10,   10,   10, sqrt(2); ... Q_tr
                10,-10,  0,  0,    0,    0,       0; ... Q_||
                0 ,  0,  0, pi, pi/2,-pi/2,  -3*pi/4 ... phi ranges [-pi: pi]
                ];
            assertElementsAlmostEqual(cyl,sam_cyl);

            pixr  = proj.transform_img_to_pix(cyl);
            assertElementsAlmostEqual(pixr,pix0);

        end
        %
        function test_coord_transf_3D_deg(~)
            proj = cylinder_proj();
            proj.type = "aad";
            assertEqual(proj.type,'aad')
            pix0 = [100,0,0,1;0,10,0,1;0,0,1,1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end
        function test_coord_transf_3D_radian(~)
            proj = cylinder_proj();
            proj.type = "aar";
            assertEqual(proj.type,'aar')
            pix0 = [...
                100, 0, 0, 1;...
                0  ,10, 0, 1;...
                0  , 0, 1, 1];

            sph  = proj.transform_pix_to_img(pix0);
            pix_rec = proj.transform_img_to_pix(sph);

            assertElementsAlmostEqual(pix0,pix_rec);
        end
        %
        function test_set_direction_110_cub(~)
            proj = cylinder_proj([1,-1,0],[1,1,0],'alatt',2*pi,'angdeg',90);
            assertEqual(proj.u,[1,-1,0])
            assertEqual(proj.v,[1, 1,0])
            ref_vec = [...
                1/sqrt(2) ,   1/sqrt(2),    1.; ... Q_tr
                1/sqrt(2) ,  -1/sqrt(2),    0.; ... Q_||
                0  ,   0.,                 90.; ... phi
                ];
            cyl = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,cyl);
            pix_cc = proj.transform_img_to_pix(cyl);
            assertElementsAlmostEqual(eye(3),pix_cc );
        end
        %
        function test_set_direction_010(~)
            proj = cylinder_proj([0,1,0],[1,0,0]);
            assertEqual(proj.u,[0,1,0])
            assertEqual(proj.v,[1,0,0])
            ref_vec = [...
                1.,   0.,    1.; ... Q_tr
                0 ,   1.,    0.; ... Q_||
                0 ,   0.,  -90.; ... phi
                ];
            cyl = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,cyl);
        end
        %
        function test_set_direction_001(~)
            proj = cylinder_proj([0,0,1],[1,0,0]);
            assertEqual(proj.u,[0,0,1])
            assertEqual(proj.v,[1,0,0])
            ref_vec = [...
                1,  1., 0.; ... Q_tr
                0,  0., 1.; ... Q_||
                0, 90., 0.  ... Phi
                ];
            spher = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,spher);
        end

        function test_empty_constructor(~)
            proj = cylinder_proj();
            assertEqual(proj.u,[1,0,0]);
            assertEqual(proj.v,[0,1,0])

            ref_vec = [...
                0,  1., 1.; ... Q_tr
                1,  0., 0.; ... Q_||
                0,  0.,90.  ... Phi
                ];
            cyl = proj.transform_pix_to_img(eye(3));

            assertElementsAlmostEqual(ref_vec,cyl);

        end
    end
end
