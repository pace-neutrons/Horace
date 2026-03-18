classdef test_symop_rotation < TestCase

    properties
    end

    methods
        function obj = test_symop_rotation(name)
            if nargin<1
                name = 'test_symop_rotation';
            end
            obj@TestCase(name)
        end

        function test_symop_create_rotation(~)
            out = Symop.create('Rot',[1 0 0], 120);
            assertTrue(isa(out, 'SymopRotation'))
            assertEqual(out.n, [1; 0; 0])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [0; 0; 0])
        end

        function test_rot_with_genBM_and_keyvalue_param(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopRotation('normvec',[0 0 1],'theta_deg',90, ...
                'b_matrix',bm,'input_nrmv_in_rlu','cc');
            assertEqual(out.normvec,[0;0;1]);
            assertEqual(out.u, [1; 0; 0])
            assertEqualToTol(out.v, [-0.7588;2.3956; 0],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end


        function test_rotation_constructor_with_uv(~)
            out = SymopRotation([1 0 0],[0,1,0], 120, [3 3 3]);

            assertEqual(out.normvec, [0; 0; 1])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_rotation_constructor_with_bm(~)
            out = SymopRotation([1 0 0], 120, [3 3 3],pi*eye(3));

            assertEqual(out.normvec, [1; 0; 0])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_rotation_constructor(~)
            out = SymopRotation([1 0 0], 120, [3 3 3]);

            assertEqual(out.normvec, [1; 0; 0])
            assertEqual(out.theta_deg, 120)
            assertEqual(out.offset, [3; 3; 3])
        end

        function test_rotation_constructor_fail(~)
            assertExceptionThrown(@() SymopRotation(1), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            assertExceptionThrown(@() SymopRotation([1 0 0]), 'HORACE:SymopRotation:invalid_argument');
            assertExceptionThrown(@() SymopRotation([1 0 0], [0 1 0]), 'HORACE:SymopRotation:invalid_argument');
            assertExceptionThrown(@() SymopRotation(eye(3), [1 0 0]), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            assertExceptionThrown(@() SymopRotation([0  1 0
                -1 0 0
                0  0 1], [1 1 0]), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            assertExceptionThrown(@() SymopRotation([0  1 0; -1 0 0]), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            % non-orthogonal lattice needs coordinates defined
            bm = bmatrix([1,2,3],[70,80,90]);
            assertExceptionThrown(@() SymopRotation([0  1 0],90,[-1 0 0],bm), 'HORACE:SymopSetPlaneInterface:invalid_argument');
        end

    end
end
