classdef test_spaghetti_plot_sqw < TestCase
    % Test plotting methods on sqw and dnd objects
    properties
        sqw_obj

        rlp = [0,0,0; 0,0,1; 1,0,1; 1,1,1];
    end

    methods

        function obj = test_spaghetti_plot_sqw(varargin)
            obj@TestCase('test_spaghetti');
            proj = line_proj([1,0,0],[0,1,0],'type','rrr','alatt',pi,'angdeg',90);
            ax = proj.get_proj_axes_block(cell(4,1),{[0,0.02,1],[0,0.02,1],[0,0.02,1],[0,1,50]});
            obj.sqw_obj = sqw.generate_cube_sqw(ax,proj);
            % for testing with old Horace versions
            % obj.sqw_obj = 'd:\Data\Fe\Data\sqw\Fe_ei401.sqw';
        end
        %------------------------------------------------------------------
        function test_bad_inputs_fail(obj)

            f = @() spaghetti_plot();
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Invalid number of arguments'));

            f = @() spaghetti_plot(obj.rlp);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Invalid number of arguments'));

            f = @() spaghetti_plot(obj.rlp(1,:), obj.sqw_obj);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Array should contain at least 2 rlp'));

            f = @() spaghetti_plot(obj.rlp(:,1:2), obj.sqw_obj);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Array should contain at least 2 rlp'));

            f = @() spaghetti_plot(obj.rlp, 8);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check argument giving data source. Must be an sqw object or sqw file'));

            f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'labels', {'A', 'B'});
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));

            f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'labels', 'A');
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));

            f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'labels', {1 2});
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));
        end

        function test_return_1dcuts_withpix(obj)
            [disp,cuts]=spaghetti_plot(obj.rlp, obj.sqw_obj, 'noplot','withpix');
            assertEqual(numel(disp),3)
            assertEqual(numel(cuts),3)
            assertTrue(isa(disp,'d2d'))
            assertTrue(iscell(cuts))
            assertTrue(isa(cuts{1},'sqw'))
            assertEqual(cuts{1}(1).NUM_DIMS,1)
        end

        function test_return_1dcuts_nopix(obj)
            [disp,cuts]=spaghetti_plot(obj.rlp, obj.sqw_obj, 'noplot');
            assertEqual(numel(disp),3)
            assertEqual(numel(cuts),3)
            assertTrue(isa(disp,'d2d'))
            assertTrue(iscell(cuts))
            assertTrue(isa(cuts{1},'d1d'))
        end

        function test_input_qwidth(obj)
            qwidths = {0.1
                [0.1, 0.2]
                [0.1; 0.2]
                [0.1; 0.2; 0.3]
                [0.1, 0.2, 0.3]
                [0.1, 0.2, 0.3; 0.4, 0.5, 0.6]};

            qwl = {...
                [0.2,0.2,0.2;0.2,0.2,0.2]
                [0.2,0.2,0.2;0.4,0.4,0.4]
                [0.2,0.2,0.2;0.4,0.4,0.4]
                [0.2,0.4,0.6;0.2,0.4,0.6]
                [0.2,0.4,0.6;0.2,0.4,0.6]
                [0.2,0.4,0.6;0.8,1,1.2]};
            for i = 1:numel(qwidths)
                disp=spaghetti_plot(obj.rlp, obj.sqw_obj, 'qwidth', qwidths{i}, 'noplot');
                assertEqual(numel(disp),3)
                assertTrue(isa(disp,'d2d'))
                q_width = qwl{i};
                for j=1:numel(disp)
                    dw = disp(j).img_range(2,:)-disp(j).img_range(1,:);
                    assertElementsAlmostEqual(dw(2:3)',q_width(1:2,j)/2); % 2 = 2*pi/pi -- inverse lattice constant
                end
            end
        end

        function test_bad_inputs_qwidth_fail(obj)
            qwidths = {[0.1; 0.2; 0.3; 0.5]       % Too many widths
                [0.1, 0.2, 0.3; 0.4, 0.5, 0.6; 0.7, 0.8, 0.9] % Too many widths
                };

            for i = 1:numel(qwidths)
                f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'qwidth', qwidths{i}, 'noplot');
                err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
                assertTrue(contains(err.message, 'qwidth size must be one of: [1, 1], [2, 1], [1, nseg] or [2, nseg] where'))
            end
        end

        function test_cuts_return_correct_projections_3d_path(obj)
            [wdisp, cuts_sqw] = spaghetti_plot(obj.rlp, obj.sqw_obj, 'noplot', 'withpix');
            [~, cuts_d1d] = spaghetti_plot(obj.rlp, obj.sqw_obj, 'noplot');

            expected_u = [0, 0, 1; 1, 0, 0; 0, 1, 0];
            expected_v = [0, 1, 0; 0, -1, 0; 1, 0, 0];
            sqw_proj = obj.sqw_obj.data.proj;

            assert_spaghetti_projections(obj.rlp, sqw_proj, wdisp, cuts_sqw, cuts_d1d, ...
                expected_u, expected_v);
        end

        function test_cuts_return_corr_proj_coplanar_noncubic_dir_coincides(~)
            proj = line_proj([1, 0, 0], [0, 1, 0], 'type', 'rrr', ...
                'alatt', [4, 4, 6], 'angdeg', [90, 90, 120]);
            ax = proj.get_proj_axes_block(cell(4, 1), ...
                {[0, 0.05, 1.2], [0, 0.05, 1.2], [-0.2, 0.05, 0.2], [0, 5, 50]});
            w_hex = sqw.generate_cube_sqw(ax, proj);

            rlp_coplanar = [0, 0, 0; 1, 0, 0; 1, 1, 0];
            wdisp1 = spaghetti_plot(rlp_coplanar, w_hex, ...
                'qwidth', [0.1, 0.2], 'noplot');

            rlp_coplanar = [0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 0, 0];
            wdisp2 = spaghetti_plot(rlp_coplanar, w_hex, ...
                'qwidth', [0.1, 0.2], 'noplot');

            assertEqualToTol(wdisp1,wdisp2(1:2),'-ignore_str');
        end


        function test_cuts_return_correct_projections_coplanar_noncubic(~)
            proj = line_proj([1, 0, 0], [0, 1, 0], 'type', 'rrr', ...
                'alatt', [4, 4, 6], 'angdeg', [90, 90, 120]);
            ax = proj.get_proj_axes_block(cell(4, 1), ...
                {[0, 0.05, 1.2], [0, 0.05, 1.2], [-0.2, 0.05, 0.2], [0, 5, 50]});
            w_hex = sqw.generate_cube_sqw(ax, proj);

            rlp_coplanar = [0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 0, 0];
            [wdisp, cuts_sqw] = spaghetti_plot(rlp_coplanar, w_hex, ...
                'qbin', 0.1, 'ebin', [0, 5, 50], 'noplot', 'withpix');
            [~, cuts_d1d] = spaghetti_plot(rlp_coplanar, w_hex, ...
                'qbin', 0.1, 'ebin', [0, 5, 50], 'noplot');

            expected_u = diff(rlp_coplanar, 1, 1);
            assert_spaghetti_projections(rlp_coplanar, w_hex.data.proj, wdisp, ...
                cuts_sqw, cuts_d1d, expected_u, []);
        end
    end
end

function assert_spaghetti_projections(rlp, src_proj, wdisp, cuts_sqw, cuts_d1d, expected_u, expected_v)
nseg = size(rlp, 1) - 1;
assertEqual(numel(wdisp), nseg);
assertEqual(numel(cuts_sqw), nseg);
assertEqual(numel(cuts_d1d), nseg);

for i = 1:nseg
    q_dir_rlu = rlp(i+1, :) - rlp(i, :);
    q_dir_cart = src_proj.transform_hkl_to_pix(q_dir_rlu')';
    seg_len = norm(q_dir_cart);

    wp = wdisp(i).proj;
    assertTrue(isa(wp, 'line_proj'));
    assertElementsAlmostEqual(wp.u, expected_u(i, :), 'absolute', 1e-12);
    if ~isempty(expected_v)
        assertElementsAlmostEqual(wp.v, expected_v(i, :), 'absolute', 1e-12);
    end
    assertEqual(wp.type, 'aaa');
    assertElementsAlmostEqual(wp.offset, [rlp(i, :), 0], 'absolute', 1e-12);
    assertElementsAlmostEqual(wp.alatt, src_proj.alatt, 'absolute', 1e-12);
    assertElementsAlmostEqual(wp.angdeg, src_proj.angdeg, 'absolute', 1e-12);

    % u and v must remain orthogonal in Cartesian reciprocal space
    u_pix = wp.transform_hkl_to_pix(wp.u');
    v_pix = wp.transform_hkl_to_pix(wp.v');
    assertElementsAlmostEqual(dot(u_pix, v_pix), 0, 'absolute', 1e-10);

    % First axis maps inverse Angstroms along q_dir_rlu from rlp(i) to rlp(i+1)
    assertElementsAlmostEqual(wdisp(i).u_to_rlu(1:3, 1), q_dir_rlu' / seg_len, 'absolute', 1e-12);
    hkl_start = wp.transform_img_to_hkl([0; 0; 0]);
    hkl_end = wp.transform_img_to_hkl([seg_len; 0; 0]);
    assertElementsAlmostEqual(hkl_start(:)', rlp(i, :), 'absolute', 1e-10);
    assertElementsAlmostEqual(hkl_end(:)', rlp(i+1, :), 'absolute', 1e-10);

    % Verify 1D cuts (both sqw withpix and d1d nopix) preserve the segment projection and slice range
    ncut = numel(cuts_sqw{i});
    assertEqual(numel(cuts_d1d{i}), ncut);
    assertTrue(ncut >= 1);
    expected_edges = linspace(0, seg_len, ncut + 1);
    for j = 1:ncut
        assert_single_cut_projection(cuts_sqw{i}(j).data, wp, wdisp(i).u_to_rlu, ...
            expected_edges(j:j+1), rlp(i, :), rlp(i+1, :), seg_len);
        assert_single_cut_projection(cuts_d1d{i}(j), wp, wdisp(i).u_to_rlu, ...
            expected_edges(j:j+1), rlp(i, :), rlp(i+1, :), seg_len);
    end
end
end

function assert_single_cut_projection(cut_data, seg_proj, seg_u_to_rlu, edge_pair, rlp_start, rlp_end, seg_len)
cp = cut_data.proj;
assertTrue(isa(cp, 'line_proj'));
assertElementsAlmostEqual(cp.u, seg_proj.u, 'absolute', 1e-12);
assertElementsAlmostEqual(cp.v, seg_proj.v, 'absolute', 1e-12);
assertEqual(cp.type, seg_proj.type);
assertElementsAlmostEqual(cp.offset, seg_proj.offset, 'absolute', 1e-12);
assertElementsAlmostEqual(cp.alatt, seg_proj.alatt, 'absolute', 1e-12);
assertElementsAlmostEqual(cp.angdeg, seg_proj.angdeg, 'absolute', 1e-12);
assertElementsAlmostEqual(cut_data.u_to_rlu, seg_u_to_rlu, 'absolute', 1e-12);

slice_range = cut_data.img_range(:, 1)';
assertElementsAlmostEqual(slice_range, edge_pair, 'absolute', 1e-10);

frac = mean(slice_range) / seg_len;
expected_hkl = rlp_start + frac * (rlp_end - rlp_start);
actual_hkl = cp.transform_img_to_hkl([mean(slice_range); 0; 0]);
assertElementsAlmostEqual(actual_hkl(:)', expected_hkl, 'absolute', 1e-10);
end
