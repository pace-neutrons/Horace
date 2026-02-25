classdef test_cut_sym_cube < TestCase

    properties
        ref_samp
    end
    properties(Constant)
        nil = [0 0 0];

        % Old style vector pairs (DEPRECATED)
        ref_x = {[0 1 0], [0 0 1]};
        ref_y = {[0 0 1], [1 0 0]};
        ref_z = {[1 0 0], [0 1 0]};
        ref_xy = {[0 0 1], [1 -1 0]};

        % New style Symops
        ref_x_op = SymopReflection([0 1 0], [0 0 1]);
        ref_y_op = SymopReflection([1 0 0], [0 0 1]);
        ref_z_op = SymopReflection([1 0 0], [0 1 0]);
        ref_xy_op = SymopReflection([0 0 1], [1 -1 0]);
    end

    methods
        function obj = test_cut_sym_cube(name)
            if nargin<1
                name = 'test_cut_sym_cube';
            end
            obj@TestCase(name)
            proj = line_proj([1,0,0],[0,1,0],'alatt',2*pi,'angdeg',90);
            ab   = line_axes('img_range',[-1,-1,-1,0;1,1,1,10],'nbins_all_dims',[100,100,1,100]);
            function weight = build_img(h,k,~,e,varargin)
                weight = zeros(size(h));
                left = h<0;
                h(left) = -h(left);
                left = k<0;                
                k(left) = -k(left);
                r = (h-0.5).^2+(k-0.5).^2;
                width = 0.9-(0.9/10)*(10-e);
                is_signal = r<width & r>=width-0.2;
                weight(is_signal)=1;
            end
            obj.ref_samp = sqw.generate_cube_sqw(ab,proj,@build_img);
        end

        function test_cut_sym_identity_stripped(~)
            tsqw = sqw.generate_cube_sqw(10);

            res_sqw = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], '-nopix');
            res_sqw2 = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                {SymopIdentity()}, '-nopix');
            res_sqw3 = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                SymopIdentity(), '-nopix');
            res_sqw4 = cut_sqw(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                SymopIdentity(), '-nopix');

            assertEqual(res_sqw, res_sqw2)
            assertEqual(res_sqw, res_sqw3)
            assertEqual(res_sqw, res_sqw4)

        end

        function test_cut_sym_no_dup_2_identity(obj)
            % Test that symmetrisation does not duplicate pixels in overlap region
            % Cut identity twice (full overlap)
            % `id` is defined as 2 identical reflections because
            % `SymopIdentity`s are filtered from ops.


            id = [obj.ref_x_op, obj.ref_x_op]; % Reflect -> reflect back
            tsqw = sqw.generate_cube_sqw(10);

            res_sqw = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], '-nopix');
            res_sqw2 = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                {id}, '-nopix');
            res_sqw3 = cut_sqw(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                {id}, '-nopix');

            assertEqual(res_sqw, res_sqw2)
            assertEqual(res_sqw, res_sqw3)

        end

        function test_cut_sym_nonorthog_identity(obj)
            % Test that symmetrisation works with non-orthogonal lattice

            id = [obj.ref_x_op, obj.ref_x_op]; % Reflect -> reflect back
            tsqw = sqw.generate_cube_sqw(10);
            tsqw.data.angdeg = [90, 90, 120];

            res_sqw = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], '-nopix');
            res_sqw2 = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                {id}, '-nopix');

            assertEqual(res_sqw, res_sqw2)

        end

        function test_cut_sym_nonorthog_rot(~)
            % Test that symmetrisation works with non-orthogonal lattice

            tsqw = sqw.generate_cube_sqw(10);
            tsqw.data.angdeg = [90, 90, 120];
            % define rotation axis as the one, orthogonal to
            % [1,0,0],[0,1,0] plane
            % TODO: Re #1908; #1668. Regularize input according to these
            % tickets.
            uv_cc = tsqw.data.proj.transform_hkl_to_pix([[1,0,0]',[0,1,0]']);
            ort = cross(uv_cc(:,1),uv_cc(:,2));
            rot_axis = tsqw.data.proj.transform_pix_to_hkl(ort);

            wtmp = symmetrise_sqw(tsqw, SymopRotation.fold(2, rot_axis));
            res_sqw = cut(wtmp, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5]);

            res_sqw2 = cut(tsqw, line_proj([1 0 0], [0 1 0]), ...
                [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                SymopRotation.fold(2, [0,0,1]));

            assertEqual(res_sqw.data, res_sqw2.data)

        end

        function test_cut_sym_reflect(obj)
            % Test with basic reflection
            data = sqw.generate_cube_sqw(10);

            proj = line_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 1.5];
            all_data = {[-5 5] [-5 5] [-5 5]};

            clOb = set_temporary_warning('off','HORACE:symmetrise_sqw:deprecated');
            wtmp = symmetrise_sqw(data, obj.ref_x{:}, obj.nil);
            w1sym = cut(wtmp, proj, ubin_half, all_data{:}, '-nopix');

            w2sym = cut(data, proj, ubin_half, all_data{:}, obj.ref_x_op, '-nopix');
            w3sym = cut_sqw(data, proj, ubin_half, all_data{:}, obj.ref_x_op, '-nopix');

            assertEqualToTol(w1sym, w2sym);
            assertEqualToTol(w1sym, w3sym);
        end

        function test_cut_sym_reflect_xy(obj)
            % test with reflection in x=-y (into positive quadrant)
            data = sqw.generate_cube_sqw(2);

            proj = line_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 1.5];
            all_data = {[-5 5] [-5 5] [-5 5]};
            x = cut(data, proj, ubin_half, all_data{:});

            clOb = set_temporary_warning('off','HORACE:symmetrise_sqw:deprecated');
            wtmp = symmetrise_sqw(data, obj.ref_xy{:}, obj.nil);

            w1sym = cut(wtmp, proj, ubin_half, all_data{:}, '-nopix');
            w2sym = cut(data, proj, ubin_half, all_data{:}, obj.ref_xy_op, '-nopix');

            assertEqualToTol(w1sym, w2sym);
        end

        function test_cut_sym_reflect_offset(obj)
            % test with reflection in x offset by 0.5
            data = sqw.generate_cube_sqw(10);

            proj = line_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 1.5];
            all_data = {[-5 5] [-5 5] [-5 5]};
            offset = [0.5 0 0];

            clOb = set_temporary_warning('off','HORACE:symmetrise_sqw:deprecated');
            wtmp = symmetrise_sqw(data, obj.ref_x{:}, offset);
            w1sym = cut(wtmp, proj, ubin_half, all_data{:}, '-nopix');

            op = obj.ref_x_op;
            op.offset = offset;
            w2sym = cut(data, proj, ubin_half, all_data{:}, op, '-nopix');

            assertEqualToTol(w1sym, w2sym);

        end

        function test_cut_sym_reflect_multi(obj)
            data = sqw.generate_cube_sqw(10);

            proj = line_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 4.5];
            all_data = {[-5 5] [-5 5] [-5 5]};

            clOb = set_temporary_warning('off','HORACE:symmetrise_sqw:deprecated');
            wtmp = symmetrise_sqw(data, obj.ref_x{:}, obj.nil);
            wtmp = symmetrise_sqw(wtmp, obj.ref_y{:}, obj.nil);
            assertEqual(wtmp.pix.num_pixels,data.pix.num_pixels);
            w_sym1 = cut(wtmp, proj, ubin_half,ubin_half,all_data{2:end});
            assertEqual(w_sym1.pix.num_pixels,data.pix.num_pixels);

            op = {obj.ref_x_op, obj.ref_y_op, [obj.ref_x_op, obj.ref_y_op]};
            w_sym2 = cut(data, proj, ubin_half, ubin_half,all_data{2:end},op);

            assertEqualToTol(w_sym1, w_sym2,'-ignore_date');

        end

        function test_cut_sym_general(~)
            data = sqw.generate_cube_sqw(10);

            proj = line_proj([1 0 0], [0 1 0]);
            ubin = {[0.5 1 4.5], [0.5 1 4.5], [-5 5], [-5 5]};

            wtmp = symmetrise_sqw(data, SymopRotation([0 0 1], 90));
            w1sym = cut(wtmp, proj, ubin{:});

            op = cell(1,3);
            for i = 1:3
                op{i} = SymopGeneral(rot_mat_z(i*90));
            end

            w2sym = cut(data, proj, ubin{:}, op);

            assertEqualToTol(w1sym, w2sym,'tol',[1.e-14,1.e-14]);
        end
    end
end

function mat = rot_mat_z(x)
mat = [cosd(x) -sind(x) 0
    sind(x)  cosd(x) 0
    0        0     1];
end
