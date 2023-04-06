classdef test_symop < TestCase

    properties
    end

    methods
        function obj = test_symop(name)
            if nargin<1
                name = 'test_symop';
            end
            obj@TestCase(name)
        end

        function test_symop_create_identity(obj)
            out = symop(eye(3));
            assertTrue(isa(out, 'SymopIdentity'))
        end

        function test_identity_constructor(obj)
            out = SymopIdentity();
            assertTrue(isa(out, 'SymopIdentity'))
        end

        function test_symop_create_reflection(obj)
            out = symop([1 0 0], [0 1 0]);
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

        function test_symop_create_rotation(obj)
            out = symop([1 0 0], 120);
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

        function test_symop_create_motion(obj)
            out = symop([ 0  0 -1
                         -1  0  0
                          0  1  0]);
            assertTrue(isa(out, 'SymopMotion'))
            assertEqual(out.W,  [0  0 -1
                                 -1 0  0
                                 0  1  0])
            assertEqual(out.offset, [0; 0; 0])
        end

        function test_motion_constructor(obj)
            out = SymopMotion([-1  0 0
                               0  -1 0
                               0   0 1], [3  3  3]);
            assertTrue(isa(out, 'SymopMotion'))
            assertEqual(out.W,  [-1  0  0
                                 0  -1  0
                                 0   0  1])
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_apply_indentity(obj)
            out = SymopIdentity();
            testvec = [1; 0; 0];
            outvec = out.transform(testvec);
            assertEqualToTol(outvec, testvec)
        end

        function test_apply_rotation(obj)
            out = SymopRotation([0 1 0], 90);
            testvec = [1; 0; 0];
            outvec = out.transform(testvec);

            assertEqualToTol(outvec, [0; 0; -1], 'abstol', 1e-10);
        end

        function test_apply_reflection(obj)
            out = SymopReflection([0 1 0], [0 0 1]);
            testvec = [1; 0; 0];
            outvec = out.transform(testvec);
            assertEqualToTol(outvec, [-1; 0; 0])
        end

        function test_apply_motion(obj)
            out = SymopMotion([0  0 -1
                               -1 0  0
                               0  1  0]);
            testvec = [1; 0; 0];
            outvec = out.transform(testvec);

            assertEqualToTol(outvec, [0; -1; 0])
        end

    end
end
