classdef test_sigvar_set < TestCase

    properties
    end

    methods
        function obj = test_sigvar_set(~)
            obj = obj@TestCase('test_sigvar_set');
        end

        function test_sigvar_set_raises_error_if_e_not_same_size_as_dnd_object(~)
            ab = axes_block([0,0.5,1],[0,1],[0,0.5,1],[0,1], ...
                'single_bin_defines_iax',[false,true,true,true]);
            pr = ortho_proj();
            d2d_obj = d2d(ab,pr);

            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));
            me = assertExceptionThrown(@()d2d_obj.sigvar_set(sigvar_obj), ...
                'HORACE:DnDBase:invalid_argument');

            assertTrue(contains(me.message, 'size of npix array'));
            assertTrue(contains(me.message, num2str(size(d2d_obj.e))));
            assertTrue(contains(me.message, num2str(size(sigvar_obj.e))));

        end
        function test_sigvar_set_s_and_e_nopix_gives_zero(~)
            ab = axes_block([0,0.5,1],[0,1],[0,0.5,1],[0,1], ...
                'single_bin_defines_iax',[false,true,true,true]);
            pr = ortho_proj();
            d2d_obj = d2d(ab,pr);
            d2d_obj.npix = zeros(2,3);

            sigvar_obj = sigvar(struct(...
                's', [1, 2, 3; 4, 5, 6], ...
                'e', [44, 55, 66; 77, 88, 99]));
            sigvar_zer_obj = sigvar(struct('s',zeros(2,3), ...
                'e',zeros(2,3)));

            result = d2d_obj.sigvar_set(sigvar_obj);
            assertEqualToTol(result.s, sigvar_zer_obj.s);
            assertEqualToTol(result.e, sigvar_zer_obj.e);
        end


        function test_sigvar_set_updates_s_and_e_values(~)
            ab = axes_block([0,0.5,1],[0,1],[0,0.5,1],[0,1], ...
                'single_bin_defines_iax',[false,true,true,true]);
            pr = ortho_proj();
            d2d_obj = d2d(ab,pr);

            sigvar_obj = sigvar(struct(...
                's', [1, 2, 3; 4, 5, 6], ...
                'e', [44, 55, 66; 77, 88, 99]));

            result = d2d_obj.sigvar_set(sigvar_obj);
            assertEqualToTol(result.s, sigvar_obj.s);
            assertEqualToTol(result.e, sigvar_obj.e);
        end

        function test_sigvar_set_zero_s_and_e_where_npix_zero(~)
            ab = axes_block([0,0.5,1],[0,1],[0,1],[0,1]);
            pr = ortho_proj();
            d1d_obj = d1d(ab,pr);
            d1d_obj.s = ones(1,3);
            d1d_obj.e = ones(1,3);
            d1d_obj.npix = [3, 0, 1];

            sigvar_obj = sigvar(struct('s', [1, 2, 3], 'e', [44, 55, 66]));

            expected_s = [1, 0, 3]';
            expected_e = [44, 0, 66]';

            result = d1d_obj.sigvar_set(sigvar_obj);

            assertEqualToTol(result.s, expected_s);
            assertEqualToTol(result.e, expected_e);
        end
    end
end
