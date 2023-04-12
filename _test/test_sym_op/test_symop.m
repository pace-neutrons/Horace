classdef test_symop < TestCase

    properties(Constant)
        ref_op = SymopReflection([1 0 0], [0 0 1]); % Reflection in Y
        ref_op_mat = Symop([ 1  0  0
                             0  -1 0
                             0  0  1]);

        rot_op = SymopRotation([1 0 0], 90);      % Rotation 90deg about X
        rot_op_mat = Symop([ 1  0  0
                             0  0 -1
                             0  1  0]);

        % rot about Y 90deg Rot about Z 90deg
        mot_op_comp = [SymopRotation([0 1 0], 90), ...
                       SymopRotation([0 0 1], 90), ...
                       SymopReflection([1 0 0], [0 1 0]), ...
                       SymopReflection([0 0 1], [1 0 0])];

        mot_op = Symop([0  0 -1
                        1  0  0
                        0 -1  0]);

        binning = {[0 0.1 1], [0 0.1 1], [0 0.1 1]};

        proj = ortho_proj([1 0 0], [0 1 0], ...
                          'alatt', [3 3 3], ...
                          'angdeg', [90 90 90]);

    end

    methods
        function obj = test_symop(name)
            if nargin<1
                name = 'test_symop';
            end
            obj@TestCase(name)
        end

        function test_symop_create_identity(obj)
            out = Symop.create(eye(3));
            assertTrue(isa(out, 'SymopIdentity'))
        end

        function test_identity_constructor(obj)
            out = SymopIdentity();
            assertTrue(isa(out, 'SymopIdentity'))

            out = SymopIdentity(eye(3));
            assertTrue(isa(out, 'SymopIdentity'))

            out = SymopIdentity(eye(3), [0 0 0]);
            assertTrue(isa(out, 'SymopIdentity'))
        end


        function test_identity_constructor_fail(obj)
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

        function test_symop_create_reflection(obj)
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

        function test_symop_create_rotation(obj)
            out = Symop.create([1 0 0], 120);
            assertTrue(isa(out, 'SymopRotation'))
            assertEqual(out.n, [1; 0; 0])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [0; 0; 0])
        end

        function test_rotation_constructor(obj)
            out = SymopRotation([1 0 0], 120, [3 3 3]);
            assertTrue(isa(out, 'SymopRotation'))
            assertEqual(out.n, [1; 0; 0])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_rotation_constructor_fail(obj)
            assertExceptionThrown(@() SymopRotation(1), 'MATLAB:minrhs');
            assertExceptionThrown(@() SymopRotation([1 0 0]), 'MATLAB:minrhs');
            assertExceptionThrown(@() SymopRotation([1 0 0], [0 1 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopRotation(eye(3), [1 0 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopRotation([0  1 0
                                                     -1 0 0
                                                     0  0 1], [1 1 0]), 'HORACE:symop:invalid_argument');
            assertExceptionThrown(@() SymopRotation([0  1 0; -1 0 0]), 'MATLAB:minrhs');
       end

       function test_symop_create_matrix(obj)
            out = Symop.create([ 0  0 -1
                                 -1  0  0
                                 0  1  0]);
            assertTrue(isa(out, 'Symop'))
            assertEqual(out.W,  [0  0 -1
                                 -1 0  0
                                 0  1  0])
            assertEqual(out.offset, [0; 0; 0])
        end

        function test_matrix_constructor(obj)
            out = Symop([-1  0 0
                         0  -1 0
                         0   0 1], [3  3  3]);
            assertTrue(isa(out, 'Symop'))
            assertEqual(out.W,  [-1  0  0
                                 0  -1  0
                                 0   0  1])
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_apply_vec_indentity(obj)
            op = SymopIdentity();
            testvec = [1; 0; 0];
            outvec = op.transform_vec(testvec);
            assertEqualToTol(outvec, testvec)
        end

        function test_apply_vec_rotation(obj)
            op = SymopRotation([0 1 0], 90);
            testvec = [1; 0; 0];
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [0; 0; -1], 'abstol', 1e-10);
        end

        function test_apply_matrix_rotation(obj)
            op = SymopRotation([0 1 0], 90);
            testvec = eye(3);
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [0  0 1
                                      0  1 0
                                      -1 0 0], 'abstol', 1e-10)
        end

        function test_apply_vec_reflection(obj)
            op = SymopReflection([0 1 0], [0 0 1]);
            testvec = [1; 0; 0];
            outvec = op.transform_vec(testvec);
            assertEqualToTol(outvec, [-1; 0; 0])
        end

        function test_apply_matrix_reflection(obj)
            op = SymopReflection([0 1 0], [0 0 1]);
            testvec = eye(3);
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [-1 0 0
                                      0  1 0
                                      0  0 1])

        end

        function test_apply_vec_matrix(obj)
            op = Symop([0  0 -1
                        -1 0  0
                        0  1  0]);
            testvec = [1; 0; 0];
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [0; -1; 0])
        end

        function test_apply_matrix_matrix(obj)
            op = Symop([0  0 -1
                        -1 0  0
                        0  1  0]);
            testvec = eye(3);
            outvec = op.transform_vec(testvec);

            assertEqualToTol(outvec, [ 0 0 -1
                                       -1 0  0
                                       0 1  0])
        end

        function test_apply_matrix_comp(obj)
            testvec = eye(3);
            outvec_comp = obj.mot_op_comp.transform_vec(testvec);
            outvec = obj.mot_op.transform_vec(testvec);
            assertEqualToTol(outvec, outvec_comp, 'abstol', 1e-10)
        end

        function test_apply_proj_rotation(obj)
            [out_proj, out_bin] = obj.rot_op.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, [1, 0, 0], 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, [0, 0, 1], 'abstol', 1e-10)
            assertEqualToTol(out_bin, {[0 0.1 1], [0 0.1 1], [0 0.1 1]})

            [out_proj_mat, out_bin_mat] = obj.rot_op_mat.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, out_proj_mat.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, out_proj_mat.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin, out_bin_mat, 'abstol', 1e-10)
        end

        function test_apply_proj_reflection(obj)
            [out_proj, out_bin] = obj.ref_op.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, [1, 0, 0], 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, [0, -1, 0], 'abstol', 1e-10)
            assertEqualToTol(out_bin, {[0 0.1 1], [0 0.1 1], [-1 -0.1 0]})

            [out_proj_mat, out_bin_mat] = obj.ref_op_mat.transform_proj(obj.proj, obj.binning);
            assertEqualToTol(out_proj.u, out_proj_mat.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, out_proj_mat.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin, out_bin_mat, 'abstol', 1e-10)

        end

        function test_apply_proj_matrix(obj)
            [out_proj, out_bin] = obj.mot_op.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, [0, 1, 0], 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, [0, 0, -1], 'abstol', 1e-10)
            assertEqualToTol(out_bin, {[0 0.1 1], [0 0.1 1], [0 0.1 1]})
        end

        function test_apply_proj_comp(obj)

            [out_proj, out_bin] = obj.mot_op.transform_proj(obj.proj, obj.binning);
            [out_proj2, out_bin2] = obj.mot_op_comp.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, out_proj2.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, out_proj2.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin, out_bin2, 'abstol', 1e-10)
        end

        function test_apply_ref_ref_back(obj)
            [out_proj, out_bin] = obj.ref_op.transform_proj(obj.proj, obj.binning);
            [out_proj2, out_bin2] = obj.ref_op.transform_proj(out_proj, out_bin);

            assertEqualToTol(out_proj2.u, obj.proj.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj2.v, obj.proj.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin2, obj.binning, 'abstol', 1e-10)
        end

        function test_apply_ref_ref_back_comp(obj)
            op = [obj.ref_op, obj.ref_op];
            [out_proj, out_bin] = op.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, obj.proj.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, obj.proj.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin, obj.binning, 'abstol', 1e-10)
        end

        function test_apply_rot_180_180(obj)
            op = [SymopRotation([1 0 0], 180), SymopRotation([1 0 0], 180)];
            [out_proj, out_bin] = op.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, obj.proj.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, obj.proj.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin, obj.binning, 'abstol', 1e-10)
        end

        function test_apply_rot_360(obj)
            op = [SymopRotation([1 0 0], 360)];
            [out_proj, out_bin] = op.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, obj.proj.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, obj.proj.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin, obj.binning, 'abstol', 1e-10)
        end

        function test_apply_rot_60_min_60(obj)
            op = [SymopRotation([1 0 0], 60), SymopRotation([1 0 0], -60)];
            [out_proj, out_bin] = op.transform_proj(obj.proj, obj.binning);

            assertEqualToTol(out_proj.u, obj.proj.u, 'abstol', 1e-10)
            assertEqualToTol(out_proj.v, obj.proj.v, 'abstol', 1e-10)
            assertEqualToTol(out_bin, obj.binning, 'abstol', 1e-10)
        end

    end
end
