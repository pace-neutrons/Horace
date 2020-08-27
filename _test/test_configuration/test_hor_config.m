classdef test_hor_config < TestCase

properties
    old_config;
end

properties (Constant)
    PIXEL_PAGE_SIZE_OPT = 'pixel_page_size';
end

methods

    function obj = test_hor_config(~)
        obj = obj@TestCase('test_hor_config');

        obj.old_config = hor_config().get_data_to_store();
    end

    function tearDown(obj)
        set(hor_config, obj.old_config);
    end

    function test_HOR_CONFIG_error_if_pixel_page_size_set_lt_one_pixel(obj)
        pix_size = PixelData.DEFAULT_NUM_PIX_FIELDS*PixelData.DATA_POINT_SIZE;
        lt_pix_size = floor(pix_size) - 1;

        f = @() set(hor_config, obj.PIXEL_PAGE_SIZE_OPT, lt_pix_size);
        assertExceptionThrown(f, 'HOR_CONFIG:set_pixel_page_size');
    end

    function test_HOR_CONFIG_error_if_pixel_pg_size_gt_max_array_size(obj)
        mem = memory();
        gt_max_array_size = mem.MaxPossibleArrayBytes + 1;

        f = @() set(hor_config, obj.PIXEL_PAGE_SIZE_OPT, gt_max_array_size);
        assertExceptionThrown(f, 'HOR_CONFIG:set_pixel_page_size');
    end

end

end
