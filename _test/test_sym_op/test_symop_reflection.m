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
            out = SymopReflection('normvec',[1 1 1],'b_matrix',bm,'rlu');
            assertEqualToTol(out.normvec,bm*[1;1;1]/norm(bm*[1;1;1]),'tol',1.e-14);
            assertEqual(out.u, [ -0.3831; 0.8722;-0.0811],'tol',1.e-4)
            assertEqualToTol(out.v, [ 0.0004;0.3275;1.4364],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal111(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[1 1 1],'b_matrix',bm,'cc');
            assertEqual(out.normvec,[1;1;1]/sqrt(3));
            assertEqual(out.u, [-0.3633; 0.5199;-0.5073],'tol',1.e-4)
            assertEqualToTol(out.v, [-0.1789;0.2003;0.8786],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal010(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[0 1 0],'b_matrix',bm,'cc');
            assertEqual(out.normvec,[0;1;0]);
            assertEqualToTol(out.u, [1; 0; 0],'tol',1.e-14);
            assertEqualToTol(out.v, [-0.2213;-0.8719;-3.8240],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal100(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[1 0 0],'b_matrix',bm,'cc');
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u, [0.0563;0.2220;0.9734],'tol',1.e-4)
            assertEqualToTol(out.v, [0.1932;-0.6098; 0],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal001rlu(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[0 0 1],'b_matrix',bm,'rlu');
            assertEqual(out.normvec,bm*[0;0;1]/(norm(bm*[0;0;1])));
            assertEqualToTol(out.u, [-0.3020;0.9533;0.4014],'tol',1.e-4)
            assertEqualToTol(out.v, [-0.3761;-0.1470;-0.6445],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec,'tol',1.e-14);
            assertEqualToTol((bm*out.u)'*out.normvec,0,'tol',1.e-14)
            assertEqualToTol((bm*out.v)'*out.normvec,0,'tol',1.e-14)
        end

        function test_symop_reflection_with_genBM_and_normal001(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            out = SymopReflection('normvec',[0 0 1],'b_matrix',bm,'cc');
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
        function test_symop_reflection_with_genBM_fails_without_descr(~)
            bm = bmatrix([1,2,3],[70,80,120]);
            assertExceptionThrown(@()SymopReflection('normvec',[0 0 1],'b_matrix',bm), ...
                'HORACE:SymopSetPlaneInterface:invalid_argument');
        end
        %==================================================================
        function test_symop_reflection_with_orthoBM_and_normal111_inRlu(~)
            bm = bmatrix([1,2,3],[90,90,90]);
            out = SymopReflection('normvec',[1 1 1],'b_matrix',bm,'rlu');
            % should be the same as cc for orthogonal lattice
            assertEqual(out.normvec,bm*[1;1;1]/norm(bm*[1;1;1]));
            assertEqual(out.u, [-0.0816;-0.0816;0.9184],'tol',1.e-4)
            assertEqualToTol(out.v, [ 0.1429;-0.5714;0],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

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
            assertEqual(out.u, [0.6667;-0.6667;-1.000],'tol',1.e-4)
            assertEqualToTol(out.v, [0;1.1547;-1.7321],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

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
            assertEqual(out.u, [1; 0; 0])
            assertEqualToTol(out.v, [0; 0; -3],'tol',1.e-4)
            assertEqual(out.offset, [0; 0; 0])
            assertFalse(out.input_nrmv_in_rlu)

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
            assertFalse(out.input_nrmv_in_rlu)

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
            assertFalse(out.input_nrmv_in_rlu)

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
            assertTrue(out.input_nrmv_in_rlu)
            disp_res = evalc('disp(out)');
            assertTrue(istext(disp_res));
        end

        function test_symop_reflection_with_normal010(~)
            out = SymopReflection('normvec',[0 1 0]);
            assertEqual(out.normvec,[0;1;0]);
            assertEqual(out.u, [1; 0; 0])
            assertEqual(out.v, [0; 0; -1])
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.input_nrmv_in_rlu)
        end

        function test_symop_reflection_with_normal100(~)
            out = SymopReflection('normvec',[1 0 0]);
            assertEqual(out.normvec,[1;0;0]);
            assertEqual(out.u, [0; 1; 0])
            assertEqual(out.v, [0; 0; 1])
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.input_nrmv_in_rlu)
        end
        %==================================================================
        function test_symop_create_reflection(~)
            out = Symop.create('Refl',[1 0 0], [0 1 0]);
            assertTrue(isa(out, 'SymopReflection'))
            assertEqual(out.u, [1; 0; 0])
            assertEqual(out.v, [0; 1; 0])
            assertEqual(out.offset, [0; 0; 0])
            assertTrue(out.input_nrmv_in_rlu)
            assertEqual(out.normvec,[0;0;1]);
        end

        function test_reflection_constructor_with_bmat(~)
            bm = bmatrix([1,2,3],[70,80,110]);
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3],bm);

            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
            assertFalse(out.input_nrmv_in_rlu)
            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec);
        end

        function test_reflection_constructor_bm_later(~)
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3]);

            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
            assertTrue(out.input_nrmv_in_rlu)
            old_normvec = out.normvec;
            bm = bmatrix([1,2,3],[70,80,110]);
            out.b_matrix = bm;
            assertFalse(out.input_nrmv_in_rlu)
            % check if normvec is orthogonal to uv plane
            c1 = cross(bm*out.u,bm*out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec);
            assertFalse(all(old_normvec == out.normvec));
        end

        function test_reflection_constructor_no_bm(~)
            out = SymopReflection([1 1 0], [0 1 1], [3 3 3]);
            assertEqual(out.u, [1; 1; 0])
            assertEqual(out.v, [0; 1; 1])
            assertEqual(out.offset, [3; 3; 3])
            assertTrue(out.input_nrmv_in_rlu)
            % check if normvec is orthogonal to uv plane
            c1 = cross(out.u,out.v);
            c1 = c1/norm(c1);
            assertEqualToTol(c1,out.normvec);
        end

        function test_set_coord_in_orth_using_normvec_rlu(~)
            out = SymopReflection('norm',[1 0 0],'offset',[3 3 3],'rlu');
            assertEqual(out.normvec,[1;0;0]);
            assertEqual(out.input_nrmv_in_rlu,true);
            assertEqual(out.u,[0;1;0])
            assertEqual(out.v,[0;0;1])
            bm = bmatrix([1,2,3],[90,90,90]);
            out.b_matrix = bm;
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u,[0;1;0],1.e-14)
            assertEqualToTol(out.v,[0;0;1.5],1.e-14)

            out.input_nrmv_in_rlu = true; % now its ignores it
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u,[0;1;0],1.e-14)
            assertEqualToTol(out.v,[0;0;1.5],1.e-14)
        end
        

        function test_set_coord_in_nonorth_using_normvec_cc(~)
            out = SymopReflection('norm',[1 0 0],'offset',[3 3 3],'cc');
            assertEqual(out.normvec,[1;0;0]);
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqual(out.u,[0;1;0])
            assertEqual(out.v,[0;0;1])
            bm = bmatrix([1,2,3],[70,120,80]);
            out.b_matrix = bm;
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u,[-0.1604; 0.2194;0.96240],1.e-4)
            assertEqualToTol(out.v,[-0.1177;-0.6029; 0],1.e-4)

            out.input_nrmv_in_rlu = true; % now its ignores it
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u,[-0.1604; 0.2194;0.96240],1.e-4)
            assertEqualToTol(out.v,[-0.1177;-0.6029; 0],1.e-4)
        end

        function test_set_coord_in_nonorth_using_normvec_rlu(~)
            out = SymopReflection('norm',[1 0 0],'offset',[3 3 3],'rlu');
            assertEqual(out.normvec,[1;0;0]);
            assertEqual(out.input_nrmv_in_rlu,true);
            assertEqual(out.u,[0;1;0])
            assertEqual(out.v,[0;0;1])
            bm = bmatrix([1,2,3],[70,120,80]);
            out.b_matrix = bm;
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u,[-0.1604; 0.2194;0.96240],1.e-4)
            assertEqualToTol(out.v,[-0.1177;-0.6029; 0],1.e-4)

            out.input_nrmv_in_rlu = true; % now its ignores it
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqual(out.normvec,[1;0;0]);
            assertEqualToTol(out.u,[-0.1604; 0.2194;0.96240],1.e-4)
            assertEqualToTol(out.v,[-0.1177;-0.6029; 0],1.e-4)
        end

        function test_set_coord_in_nonorth_using_uv(~)
            out = SymopReflection([0 1 0],[0 0 1],[3 3 3]);
            assertEqual(out.normvec,[1;0;0]);
            assertEqual(out.input_nrmv_in_rlu,true);
            bm = bmatrix([1,2,3],[70,120,80]);
            out.b_matrix = bm;
            assertEqual(out.input_nrmv_in_rlu,false);
            assertEqualToTol(out.normvec,[0.7845;0.3668;-0.5000],1.e-4);
        end

        function test_reflection_construct_normal_fails_on_nonort_without_coord(~)
            out = SymopReflection('norm',[1 1 0],'offset',[3 3 3]);
            bm = bmatrix([1,2,3],[70,90,90]);
            function thrower()
                out.b_matrix = bm;
            end
            assertExceptionThrown(@thrower,'HORACE:SymopSetPlaneInterface:invalid_argument');
            out.input_nrmv_in_rlu = false;

            out.b_matrix = bm;
            assertEqualToTol(out.b_matrix,bm);
        end

        function test_reflection_constructor_fail(~)
            assertExceptionThrown(@() SymopReflection(1), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            assertExceptionThrown(@() SymopReflection([0 1 0]), 'HORACE:SymopReflection:invalid_argument');
            assertExceptionThrown(@() SymopReflection(1, 90), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            assertExceptionThrown(@() SymopReflection([1 0 0], 90), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            assertExceptionThrown(@() SymopReflection(eye(3)), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');
            assertExceptionThrown(@() SymopReflection([0  1 0
                -1 0 0
                0  0 1], 90), 'HORACE:SymopSetPlaneIntrerface:invalid_argument');

            % Test collinear vectors
            assertExceptionThrown(@() SymopReflection([1 0 0], [1 0 0]), 'HORACE:SymopReflection:invalid_argument');
        end
    end
end
