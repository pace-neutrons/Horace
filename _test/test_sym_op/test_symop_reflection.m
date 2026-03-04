classdef test_symop_reflection < TestCase

    properties(Constant)
        points2transform = [eye(3),[1;1;0],[1;0;1],[0;1;1],[1;1;1]];
    end

    methods
        function obj = test_symop_reflection(name)
            if nargin<1
                name = 'test_symop_reflection';
            end
            obj@TestCase(name)
        end
        %==================================================================        
        function test_symop_reflection_with_genBM_and_normal111_inRlu(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[1 1 1],'b_matrix',bm,'nrmv_in_rlu',true);
            assertEqualToTol(out.normvec,[0.9439;0.2563;0.2080],'tol',1.e-4);
            assertEqual(out.u, [-0.3230;0.6770;-0.3230],'tol',1.e-4)
            assertEqualToTol(out.v, [-0.0676;0.4306; 1.1963],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end        

        function test_symop_reflection_with_genBM_and_normal111(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[1 1 1],'b_matrix',bm);
            assertEqual(out.normvec,[1;1;1]/sqrt(3));
            assertEqual(out.u, [-0.1132; 0.2004;-0.9358],'tol',1.e-4)
            assertEqualToTol(out.v, [-0.3669;0.4888;0.2223],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal010(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[0 1 0],'b_matrix',bm);
            assertEqual(out.normvec,[0;1;0]);
            assertEqualToTol(out.u, [-0.0722; 0.2280;1.00000],'tol',1.e-4);
            assertEqualToTol(out.v, [0.2903;0.1134;0.49750],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal100(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[1 0 0],'b_matrix',bm);
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u, [-0.3167;1.0; 0],'tol',1.e-4)
            assertEqualToTol(out.v, [0.0924; 0.3640;1.5963],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal001(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[0 0 1],'b_matrix',bm);
            assertEqual(out.normvec,[0;0;1]);
            assertEqual(out.u, [1; 0; 0])
            assertEqualToTol(out.v, [-0.7588;2.3956; 0],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end        
        %==================================================================
        function test_symop_reflection_with_orthoBM_and_normal111_inRlu(~)
            bm = bmatrix([1,2,3],[90,90,90]);
            out = SymopReflection('normvec',[1 1 1],'b_matrix',bm,'nrmv_in_rlu',true);
            assertEqualToTol(out.normvec,[0.8571; 0.4286; 0.2857],'tol',1.e-4);
            assertEqual(out.u, [ -0.1837; 0.8163; -0.1837],'tol',1.e-4)
            assertEqualToTol(out.v, [-0.1429; 0;1.2857],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end        

        function test_symop_reflection_with_orthoBM_and_normal111(~)
            bm = bmatrix([1,2,3],[90,90,90]);
            out = SymopReflection('normvec',[1 1 1],'b_matrix',bm);
            assertEqual(out.normvec,[1;1;1]/sqrt(3));
            assertEqual(out.u, [-0.1667;0.6667;-0.5000],'tol',1.e-4)
            assertEqualToTol(out.v, [-0.2887; 0; 0.8660],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_orthoBM_and_normal010(~)
            bm = bmatrix([1,2,3],[90,90,90]);
            out = SymopReflection('normvec',[0 1 0],'b_matrix',bm);
            assertEqual(out.normvec,[0;1;0]);
            assertEqual(out.u, [0; 0; 1])
            assertEqualToTol(out.v, [0.3333; 0; 0],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_orthoBM_and_normal100(~)
            bm = bmatrix([1,2,3],[90,90,90]);
            out = SymopReflection('normvec',[1 0 0],'b_matrix',bm);
            assertEqual(out.normvec,[1;0;0]);
            assertEqual(out.u, [0; 1; 0])
            assertEqual(out.v, [0; 0; 1.5])
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_orthoBM_and_normal001(~)
            bm = bmatrix([1,2,3],[90,90,90]);
            out = SymopReflection('normvec',[0 0 1],'b_matrix',bm);
            assertEqual(out.normvec,[0;0;1]);
            assertEqual(out.u, [1; 0; 0])
            assertEqual(out.v, [0; 2; 0])
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end
        %==================================================================
        function test_symop_reflection_with_normal001(~)
            out = SymopReflection('normvec',[0 0 1]);
            assertEqual(out.normvec,[0;0;1]);
            assertEqual(out.u, [1; 0; 0])
            assertEqual(out.v, [0; 1; 0])
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.nrmv_in_rlu)
        end

        function test_symop_reflection_with_normal010(~)
            out = SymopReflection('normvec',[0 1 0]);
            assertEqual(out.normvec,[0;1;0]);
            assertEqual(out.u, [0; 0; 1])
            assertEqual(out.v, [1; 0; 0])
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.nrmv_in_rlu)
        end

        function test_symop_reflection_with_normal100(~)
            out = SymopReflection('normvec',[1 0 0]);
            assertEqual(out.normvec,[1;0;0]);
            assertEqual(out.u, [0; 1; 0])
            assertEqual(out.v, [0; 0; 1])
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.nrmv_in_rlu)
        end
        %==================================================================
        function test_symop_create_reflection(~)
            out = Symop.create('Refl',[1 0 0], [0 1 0]);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 0; 0])
            assertEqual(out.v, [0; 1; 0])
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.nrmv_in_rlu)
            assertEqual(out.normvec,[0;0;1]);
        end

        function test_reflection_constructor_with_bmat_rlu_true_ignored(~)
            bm = bmatrix([1,2,3],[70,80,110]);
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3],bm,true);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
            assertFalse(out.nrmv_in_rlu)
            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec);
        end

        function test_reflection_constructor_with_bmat(~)
            bm = bmatrix([1,2,3],[70,80,110]);
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3],bm);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
            assertFalse(out.nrmv_in_rlu)
            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec);
        end

        function test_reflection_constructor_bm_later(~)
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3]);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
            assertTrue(out.nrmv_in_rlu)
            old_normvec = out.normvec;
            bm = bmatrix([1,2,3],[70,80,110]);
            out.b_matrix = bm;
            assertFalse(out.nrmv_in_rlu)
            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec);
            assertFalse(all(old_normvec == out.normvec));
        end


        function test_reflection_constructor_no_bm(~)
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3]);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
            assertTrue(out.nrmv_in_rlu)
            % check if normvec is orthogonal to uv plane
            c1 = cross(out.u,out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec);
        end

        function test_reflection_constructor_fail(~)
            assertExceptionThrown(@() SymopReflection(1), 'HORACE:SymopReflection:invalid_argument');
            assertExceptionThrown(@() SymopReflection([0 1 0]), 'HORACE:SymopReflection:invalid_argument');
            assertExceptionThrown(@() SymopReflection(1, 90), 'HORACE:SymopReflection:invalid_argument');
            assertExceptionThrown(@() SymopReflection([1 0 0], 90), 'HORACE:SymopReflection:invalid_argument');
            assertExceptionThrown(@() SymopReflection(eye(3)), 'HORACE:SymopReflection:invalid_argument');
            assertExceptionThrown(@() SymopReflection([0  1 0
                -1 0 0
                0  0 1], 90), 'HORACE:SymopReflection:invalid_argument');

            % Test collinear vectors
            assertExceptionThrown(@() SymopReflection([1 0 0], [1 0 0]), 'HORACE:SymopReflection:invalid_argument');
        end
    end
end
