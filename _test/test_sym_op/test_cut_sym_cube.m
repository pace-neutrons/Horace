classdef test_cut_sym_cube < TestCase

    properties(Constant)
        nil = [0 0 0];

        ref_x = {[0 1 0], [0 0 1]};
        ref_y = {[0 0 1], [1 0 0]};
        ref_z = {[1 0 0], [0 1 0]};
        ref_xy = {[0 0 1], [1 -1 0]};

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
        end

        function test_cut_sym_identity_stripped(obj)
            tsqw = sqw.generate_cube_sqw(10);

            res_sqw = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                          [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5]);
            res_sqw2 = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                           [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                           {SymopIdentity()});
            res_sqw3 = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                           [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                           SymopIdentity());

            assertEqual(res_sqw, res_sqw2)
            assertEqual(res_sqw, res_sqw3)

        end

        function test_cut_sym_no_dup_2_identity(obj)
        % Test that symmetrisation does not duplicate pixels in overlap region
        % Cut identity twice (full overlap)
        % `id` is defined as 2 identical reflections because
        % `SymopIdentity`s are filtered from ops.


            id = [obj.ref_x_op, obj.ref_x_op]; % Reflect -> reflect back
            tsqw = sqw.generate_cube_sqw(10);

            res_sqw = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                          [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5]);
            res_sqw2 = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                           [-5 5], [0.5 1 1.5], [-1.5 1 1.5], [-5 5], ...
                           {id});

            assertEqual(res_sqw.data, res_sqw2.data)

        end

        function test_cut_sym_reflect(obj)
        % Test with basic reflection
            data = sqw.generate_cube_sqw(10);

            proj = ortho_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 1.5];
            all_data = {[-5 5] [-5 5] [-5 5]};

            wtmp = symmetrise_sqw(data, obj.ref_x{:}, obj.nil);
            w1sym = cut(wtmp, proj, ubin_half, all_data{:});

            w2sym = cut(data, proj, ubin_half, all_data{:}, obj.ref_x_op);

            assertEqualToTol(w1sym.data, w2sym.data);
        end

        function test_cut_sym_reflect_xy(obj)
        % test with reflection in x=-y (into positive quadrant)
            data = sqw.generate_cube_sqw(2);

            proj = ortho_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 1.5];
            all_data = {[-5 5] [-5 5] [-5 5]};
            x = cut(data, proj, ubin_half, all_data{:});

            wtmp = symmetrise_sqw(data, obj.ref_xy{:}, obj.nil);

            w1sym = cut(wtmp, proj, ubin_half, all_data{:});
            w2sym = cut(data, proj, ubin_half, all_data{:}, obj.ref_xy_op);

            assertEqualToTol(w1sym.data, w2sym.data);
        end

        function test_cut_sym_reflect_offset(obj)
        % test with reflection in x offset by 0.5
            data = sqw.generate_cube_sqw(10);

            proj = ortho_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 1.5];
            all_data = {[-5 5] [-5 5] [-5 5]};
            offset = [0.5 0 0];

            wtmp = symmetrise_sqw(data, obj.ref_x{:}, offset);
            w1sym = cut(wtmp, proj, ubin_half, all_data{:});

            op = obj.ref_x_op;
            op.offset = offset;
            w2sym = cut(data, proj, ubin_half, all_data{:}, op);

            assertEqualToTol(w1sym.data, w2sym.data);

        end

        function test_cut_sym_reflect_multi(obj)
            data = sqw.generate_cube_sqw(10);

            proj = ortho_proj([1 0 0], [0 1 0]);
            ubin_half = [0.5 1 1.5];
            all_data = {[-5 5] [-5 5] [-5 5]};

            wtmp = symmetrise_sqw(data, obj.ref_x{:}, obj.nil);
            wtmp = symmetrise_sqw(wtmp, obj.ref_y{:}, obj.nil);
            w1sym = cut(wtmp, proj, ubin_half, all_data{:});


            op = {obj.ref_x_op, obj.ref_y_op, [obj.ref_x_op, obj.ref_y_op]};
            w2sym = cut(data, proj, ubin_half, all_data{:}, op);

            assertEqualToTol(w1sym.data, w2sym.data);

        end


    end
end
