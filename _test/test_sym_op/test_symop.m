classdef test_symop < TestCase

    properties(Constant)
        refl_op = SymopReflection([1 0 0], [0 0 1]); % Reflection in Y

        rot_op = SymopRotation([1 0 0], 90);      % Rotation 90deg about X
        rot_op_mat = SymopGeneral([ 1  0  0
            0  0 -1
            0  1  0]);

        % rot about Y 90deg Rot about Z 90deg
        mot_op_comp = [SymopRotation([0 1 0], 90), ...
            SymopRotation([0 0 1], 90), ...
            SymopReflection([1 0 0], [0 1 0]), ...
            SymopReflection([0 0 1], [1 0 0])];

        mot_op = SymopGeneral([0  0 -1
            1  0  0
            0 -1  0]);

        proj = line_proj([1 0 0], [0 1 0], ...
            'alatt', [3 3 3], ...
            'angdeg', [90 90 90]);

        nort_proj = line_proj([1 0 0], [0 1 0], ...
            'alatt', [1 2 3], ...
            'angdeg', [80 70 120]);

        points2transform = [eye(3),[1;1;0],[1;0;1],[0;1;1],[1;1;1]];
    end

    methods
        function obj = test_symop(name)
            if nargin<1
                name = 'test_symop';
            end
            obj@TestCase(name)
        end

        function test_symop_transform_projection_eq_symop(~)
            refl = SymopReflection([1,1,0],[0,0,1]);
            lp = line_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);
            lp1 = refl.transform_proj(lp);

            pix = [eye(3),[1;1;0],[0;1;1],[1;0;1]];
            transf_pix = lp1.transform_pix_to_img(pix);
            pix_cc = lp.transform_img_to_pix(transf_pix);

            sym_pix = refl.transform_pix(pix,{},true(1,size(pix,2)),true);
            assertEqual(pix_cc , sym_pix);
        end
        function test_symop_transform_projection_eq_symop_100(~)
            refl = SymopReflection([1,0,0],[0,0,1]);
            lp = line_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);
            lp1 = refl.transform_proj(lp);

            pix = [eye(3),[1;1;0],[0;1;1],[1;0;1]];
            transf_pix = lp1.transform_pix_to_img(pix);
            pix_cc = lp.transform_img_to_pix(transf_pix);

            sym_pix = refl.transform_pix(pix,{},true(1,size(pix,2)),true);
            assertEqual(pix_cc , sym_pix);
        end

        function test_symop_create_identity(~)
            out = Symop.create(eye(3));
            assertTrue(isa(out, 'SymopIdentity'))
        end

        function test_identity_constructor(~)
            out = SymopIdentity();
            assertTrue(isa(out, 'SymopIdentity'))

            out = SymopIdentity(eye(3));
            assertTrue(isa(out, 'SymopIdentity'))

            out = SymopIdentity(eye(3), [0 0 0]);
            assertTrue(isa(out, 'SymopIdentity'))
        end

        function test_identity_constructor_fail(~)
            assertExceptionThrown(@() SymopIdentity(1), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopIdentity([1 0 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopIdentity([1 0 0], 90), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopIdentity([1 0 0], [0 1 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopIdentity([0  1 0
                -1 0 0
                0  0 1]), 'HORACE:symop:invalid_argument');

            % Non-zero offset
            assertExceptionThrown(@() SymopIdentity(eye(3), [1 0 0]), 'HORACE:symop:invalid_argument');
        end

        function test_symop_create_reflection(~)
            out = Symop.create([1 0 0], [0 1 0]);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 0; 0])
            assertEqual(out.v, [0; 1; 0])
            assertEqual(out.offset, [0; 0; 0])
        end

        function test_reflection_constructor(obj)
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3]);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_reflection_constructor_fail(obj)
            assertExceptionThrown(@() SymopReflection(1), 'MATLAB:minrhs');
            assertExceptionThrown(@() SymopReflection([1 0 0]), 'MATLAB:minrhs');
            assertExceptionThrown(@() SymopReflection(1, 90), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopReflection([1 0 0], 90), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopReflection(eye(3)), 'MATLAB:minrhs');
            assertExceptionThrown(@() SymopReflection([0  1 0
                -1 0 0
                0  0 1], 90), 'HORACE:symop:invalid_argument');

            % Test colinear vectors
            assertExceptionThrown(@() SymopReflection([1 0 0], [1 0 0]), 'HORACE:symop:invalid_argument');
        end

        function test_symop_create_rotation(~)
            out = Symop.create([1 0 0], 120);
            assertTrue(isa(out, 'SymopRotation'))
            assertEqual(out.n, [1; 0; 0])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [0; 0; 0])
        end

        function test_rotation_constructor(~)
            out = SymopRotation([1 0 0], 120, [3 3 3]);
            assertTrue(isa(out, 'SymopRotation'))
            assertEqual(out.n, [1; 0; 0])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_rotation_constructor_fail(~)
            assertExceptionThrown(@() SymopRotation(1), 'MATLAB:minrhs');
            assertExceptionThrown(@() SymopRotation([1 0 0]), 'MATLAB:minrhs');
            assertExceptionThrown(@() SymopRotation([1 0 0], [0 1 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopRotation(eye(3), [1 0 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopRotation([0  1 0
                -1 0 0
                0  0 1], [1 1 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopRotation([0  1 0; -1 0 0]), 'MATLAB:minrhs');
        end

        function test_symop_create_matrix(~)
            out = Symop.create([ 0  0 -1
                -1  0  0
                0  1  0]);
            assertTrue(isa(out, 'Symop'))
            assertEqual(out.W,  [0  0 -1
                -1 0  0
                0  1  0])
            assertEqual(out.offset, [0; 0; 0])
        end

        function test_matrix_constructor(~)
            out = Symop.create([ 0  0 -1
                -1  0  0
                0  1  0], [3; 3; 3]);
            assertTrue(isa(out, 'Symop'))
            assertEqual(out.W,  [0  0 -1
                -1 0  0
                0  1  0])
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_apply_vec_indentity(~)
            op = SymopIdentity();
            testvec = [1; 0; 0];
            outvec = op.transform_vec(testvec);
            assertEqualToTol(outvec, testvec)
        end

        function test_apply_vec_rotation(~)
            op = SymopRotation([0 1 0], 90);
            testvec = [1; 0; 0];
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [0; 0; -1], 'abstol', 1e-10);
        end

        function test_apply_matrix_rotation(~)
            op = SymopRotation([0 1 0], 90);
            testvec = eye(3);
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [0  0 1
                0  1 0
                -1 0 0], 'abstol', 1e-10)
        end

        function test_apply_matrix_reflection(obj)
            op = SymopReflection([0 1 0], [0 0 1]);
            testvec = obj.points2transform;
            outvec = op.transform_vec(testvec);

            ref_v = testvec;
            ref_v(1,:) = -ref_v(1,:);
            assertEqualToTol(outvec, ref_v)
        end

        function test_apply_vec_matrix(~)
            op = SymopGeneral([0  0 -1
                -1 0  0
                0  1  0]);
            testvec = [1; 0; 0];
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [0; -1; 0])
        end

        function test_apply_matrix_matrix(~)

            op = SymopGeneral([0  0 -1
                -1 0  0
                0  1  0]);
            testvec = eye(3);
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [ 0 0 -1
                -1 0  0
                0 1  0])
        end

        function test_apply_matrix_comp(obj)
            outvec_comp = obj.mot_op_comp.transform_vec(obj.points2transform);
            outvec = obj.mot_op.transform_vec(obj.points2transform);
            assertEqualToTol(outvec, outvec_comp, 'abstol', 1e-10)
        end

        function test_apply_proj_rotation(obj)
            out_proj  = obj.check_proj_transformation_correct(obj.rot_op,obj.proj);

            out_proj_mat  = obj.check_proj_transformation_correct(obj.rot_op_mat,obj.proj);

            assertEqualToTol(out_proj.sym_transf, out_proj_mat.sym_transf,'abstol',1.e-12)
        end
        %==================================================================

        %==================================================================
        function test_combined_with_shift_works_on_non_orth(obj)
            op = [SymopReflection([1,0,0],[0,0,1],[0,1,0]),SymopRotation([1,0,0],60)];

            out_proj  = obj.check_proj_transformation_correct(op,obj.nort_proj);

            assertFalse(all(out_proj.offset == 0));
        end

        function test_folding_with_shift_works_on_non_orth(obj)
            op = SymopReflection([1,0,0],[0,0,1],[0,1,0]);

            out_proj  = obj.check_proj_transformation_correct(op,obj.nort_proj);

            assertEqual(out_proj.sym_transf,op.R);
            assertFalse(all(out_proj.offset == 0));
        end

        function test_folding_with_shift100_works(obj)
            op = SymopReflection([1,0,0],[0,0,1],[1,0,0]);

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);

            assertEqual(out_proj.sym_transf,op.R);
            assertTrue(all(out_proj.offset == 0));
        end

        function test_folding_with_shift010_works(obj)
            op = SymopReflection([1,0,0],[0,0,1],[0,1,0]);

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);

            assertEqual(out_proj.sym_transf,op.R);
            assertEqual(out_proj.offset,[0,-2,0,0]);
        end

        function test_rotation_with_shift_works_on_non_orth(obj)
            op = SymopRotation([0,1,0],60,[0,1,0]);

            out_proj  = obj.check_proj_transformation_correct(op,obj.nort_proj);

            assertEqual(out_proj.sym_transf,op.R);
            assertFalse(all(out_proj.offset == 0));
        end

        function test_rotation_with_shift_on_proj_100_works(obj)
            op = SymopRotation([0,1,0],90);

            sproj = obj.proj;
            sproj.offset = [1,0,0];

            out_proj  = obj.check_proj_transformation_correct(op,sproj);

            assertEqual(out_proj.sym_transf,op.R);
            assertEqual(out_proj.offset,[1,0,0]);
        end


        function test_rotation_with_shift100_works(obj)
            op = SymopRotation([0,1,0],60,[1,0,0]);

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);

            assertEqual(out_proj.sym_transf,op.R);
            assertFalse(all(out_proj.offset == 0));
        end

        function test_rotation_with_2shifts010_works(obj)
            op = SymopRotation([0,1,0],60,[0,1,0]);

            sproj = obj.proj;
            sproj.offset = [0,1,0];
            out_proj  = obj.check_proj_transformation_correct(op,sproj);

            assertEqual(out_proj.sym_transf,op.R);
            assertEqual(out_proj.offset,[0,1,0,0]);
        end

        function test_rotation_with_shift010_on_proj_works(obj)
            op = SymopRotation([0,1,0],60);

            sproj = obj.proj;
            sproj.offset = [0,1,0];
            out_proj  = obj.check_proj_transformation_correct(op,sproj);

            assertEqual(out_proj.sym_transf,op.R);
            assertEqual(out_proj.offset,[0,1,0,0]);
        end

        function test_rotation_with_shift010_works(obj)
            op = SymopRotation([0,1,0],60,[0,1,0]);

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);

            assertEqual(out_proj.sym_transf,op.R);
            assertEqual(out_proj.offset,[0,0,0,0]);
        end
        %==================================================================
        function test_apply_proj_comp(obj)

            out_proj = obj.mot_op.transform_proj(obj.proj);
            out_proj2 = obj.mot_op_comp.transform_proj(obj.proj);

            assertEqualToTol(out_proj.sym_transf, out_proj2.sym_transf, 'abstol', 1e-12)
        end

        function test_apply_ref_ref_back(obj)
            out_proj  = obj.check_proj_transformation_correct(obj.refl_op,obj.proj);
            ref_transf = eye(3);
            ref_transf(2,2) = -1;
            assertEqualToTol(out_proj.sym_transf, ref_transf, 'abstol', 1e-14);

            out_proj2  = obj.check_proj_transformation_correct(obj.refl_op,out_proj);
            assertTrue(isempty(out_proj2.sym_transf));
        end

        function test_apply_ref_ref_back_comp(obj)
            op = [obj.refl_op, obj.refl_op];

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);
            assertTrue(isempty(out_proj.sym_transf));
        end

        function test_apply_rot_180_180(obj)
            op = [SymopRotation([1 0 0], 180), SymopRotation([1 0 0], 180)];

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);
            assertTrue(isempty(out_proj.sym_transf));
        end

        function test_apply_rot_360(obj)
            op = [SymopRotation([1 0 0], 360)];

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);
            assertTrue(isempty(out_proj.sym_transf));
        end

        function test_apply_rot_60_min_60_nonortho(obj)
            op = [SymopRotation([1 0 0], 60), SymopRotation([1 0 0], -60)];

            out_proj  = obj.check_proj_transformation_correct(op,obj.nort_proj);
            assertTrue(isempty(out_proj.sym_transf));
        end

        function test_apply_rot60_min60_with_symOffset(obj)
            op = [SymopRotation([1 0 0], 60,[1,1,0]), SymopRotation([1 0 0], -60,[1,1,0])];
            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);
            assertTrue(isempty(out_proj.sym_transf));
            assertTrue(all(out_proj.offset == 0));
        end
        function test_apply_rot_60_min_60(obj)
            op = [SymopRotation([1 0 0], 60), SymopRotation([1 0 0], -60)];

            out_proj  = obj.check_proj_transformation_correct(op,obj.proj);
            assertTrue(isempty(out_proj.sym_transf));
        end
    end
    methods(Access=protected)
        function [out_proj,op] = check_proj_transformation_correct(obj,op,proj)
            % here we model transformations used in cut with symop
            % create projection which would
            [out_proj,op] = op.transform_proj(proj);

            % pixels coordinates are expressed in Crystal Cartesian system
            % and symmetry transformed
            sym_pts = op.transform_vec(obj.points2transform);
            % transform modified pixels into image coordinate system to bin
            % them into new image
            sym_img_pts  = proj.transform_pix_to_img(sym_pts);

            % symmetrytransform pixels into image coordinate system
            proj_sym_pts = out_proj.transform_pix_to_img(obj.points2transform);

            assertEqualToTol(sym_img_pts, proj_sym_pts, 'abstol', 1e-14)
            % check if modified projection is invertable and satisfies
            % generic projection requests.
            rev_pts = out_proj.transform_img_to_pix(proj_sym_pts);
            assertEqualToTol(obj.points2transform, rev_pts, 'abstol', 1e-14)
        end
    end
end
