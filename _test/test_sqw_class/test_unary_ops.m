classdef test_unary_ops < TestCase

methods

    function obj = test_unary_ops(~)
        obj = obj@TestCase('test_unary_ops');
    end

    function test_all_functions_are_defined(obj)
        % the unary operation and the range the data it acts on should take
        unary_ops = {
            @acos, [0, 1], ...
            @acosh, [1, 3], ...
            @acot, [0, 1], ...
            @acoth, [10, 15], ...
            @acsc, [1, 3], ...
            @acsch, [1, 3], ...
            @asec, [1.5, 3], ...
            @asech, [0, 1], ...
            @asin, [0, 1], ...
            @asinh, [1, 3], ...
            @atan, [0, 1], ...
            @atanh, [0, 0.5], ...
            @cos, [0, 1], ...
            @cosh, [0, 1], ...
            @cot, [0, 1], ...
            @coth, [1.5, 3], ...
            @csc, [0.5, 2.5], ...
            @csch, [1, 3], ...
            @exp, [0, 1], ...
            @log, [1, 3], ...
            @log10, [1, 3], ...
            @sec, [2, 4], ...
            @sech, [0, 1.4], ...
            @sin, [0, 3], ...
            @sinh, [0, 3], ...
            @sqrt, [0, 3], ...
            @tan, [0, 1], ...
            @tanh, [0, 3], ...
        };

        % For each unary operator, perform the operation on some data
        num_pix = 7;
        for i = 1:2:numel(unary_ops)
            unary_op = unary_ops{i};
            data_range = unary_ops{i+1};

            data = get_random_data_in_range( ...
                PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix, data_range);

            sqw_obj = sqw();
            sqw_obj.pix = PixelDataBase.create(data);
            sqw_obj.data.npix = num_pix;
            sqw_obj.data.s = -99;
            sqw_obj.data.e = 99;

            % exception will be thrown if method not implemented
            result = unary_op(sqw_obj);

            % confirm the raw pixel data has changed
            assertFalse(equal_to_tol(result.pix.signal, sqw_obj.pix.signal))

            % confirm the (previously unset) image data (s, e) has been
            % calculated correctly from the updated raw pixels
            assertEqualToTol(result.data.s, mean(result.pix.signal));
            assertEqualToTol(result.data.e, sum(result.pix.variance)./num_pix^2);
        end
    end

    function test_unary_op_updates_image_signal_and_error_if_no_pixeldata(~)
        sqw_obj = sqw();
        ax = axes_block('img_range',[-1,-1,-1,-1;1,1,1,1],'nbins_all_dims',[2,1,1,1]);
        sqw_obj.data = d1d(ax,ortho_proj());
        sqw_obj.pix = PixelDataBase.create();
        sqw_obj.data.s = [2, 21951]; % simple dataset for ease of testing
        sqw_obj.data.e = [1.5, 4123];
        sqw_obj.data.npix = [1,1];

        % arbitrary unary op for test
        result = log10(sqw_obj);

        % explicit calculation test
        % calculate reference values using code matching implmentation in 'log10_single'
        expected_signal = log10(sqw_obj.data.s);
        expected_var = sqw_obj.data.e./(sqw_obj.data.s*log(10)).^2;

        assertEqualToTol(result.data.s, expected_signal);
        assertEqualToTol(result.data.e, expected_var);
    end

    function test_unary_op_updates_image_signal_and_error(~)
        num_pix = 23; % create small, single bin dataset for test
        data = get_random_data_in_range( ...
            PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix, [1, 3]);

        sqw_obj = sqw();
        sqw_obj.pix = PixelDataBase.create(data);
        sqw_obj.data.npix = num_pix;
        sqw_obj.data.s = -99; % fake data that will be overwritten
        sqw_obj.data.e = 99;

        % arbitrary unary op for test
        result = log10(sqw_obj);

        % explicit calculation test - the values should be calculated
        % from the pixel data not from the inconsistent image data
        % calculate reference values using code matching implmentation in 'compute_bin_data_mex_'
        expected_signal =  mean(result.pix.signal);
        expected_var = sum(result.pix.variance)./num_pix^2;

        assertEqualToTol(result.data.s, expected_signal);
        assertEqualToTol(result.data.e, expected_var);
    end

    function test_unary_op_updates_pixel_signal_and_variance(obj)
        num_pix = 23; % create small, single bin dataset for test
        data = get_random_data_in_range( ...
            PixelDataBase.DEFAULT_NUM_PIX_FIELDS, num_pix, [1, 3]);

        sqw_obj = sqw();
        sqw_obj.pix = PixelDataBase.create(data);
        sqw_obj.data.npix = num_pix;
        sqw_obj.data.s = -99; % fake data that will be overwritten
        sqw_obj.data.e =  99;

        % arbitrary unary op for test
        result = log10(sqw_obj);

        % explicit calculation test
        % calculate reference values using code matching implmentation in 'log10_single'
        expected_signal = log10(sqw_obj.pix.signal);
        expected_var = sqw_obj.pix.variance./(sqw_obj.pix.signal * log(10)).^2;

        assertEqualToTol(result.pix.signal, expected_signal);
        assertEqualToTol(result.pix.variance, expected_var);
    end

end
end
