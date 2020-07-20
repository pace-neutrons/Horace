classdef test_PixelData_operations < TestCase

properties
    test_sqw_file_path = '../test_sqw_file/sqw_1d_1.sqw';
    ref_npix_data = [];
    ref_s_data = [];
    ref_e_data = [];

    page_size;

    config;
    old_config;
end

methods

    function obj = test_PixelData_operations(~)
        obj = obj@TestCase('test_PixelData_operations');

        sqw_test_obj = sqw(obj.test_sqw_file_path);
        obj.ref_npix_data = sqw_test_obj.data.npix;
        obj.ref_s_data = sqw_test_obj.data.s;
        obj.ref_e_data = sqw_test_obj.data.e;

        file_info = dir(obj.test_sqw_file_path);
        obj.page_size = file_info.bytes/6;  % Gives us 6 pages
    end

    function setUp(obj)
        obj.config = hor_config;
        obj.old_config = obj.config.get_data_to_store();
    end

    function tearDown(obj)
        set(hor_config, obj.old_config);
    end

    function test_compute_bin_data_correct_output_in_memory_mex_1_thread(obj)
        obj.config.use_mex = true;
        obj.config.threads = 1;

        pix = PixelData(obj.test_sqw_file_path);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', 4.75e-4);
        assertEqual(e, obj.ref_e_data, '', 4.75e-4);
    end

    function test_compute_bin_data_correct_output_in_memory_mex_4_threads(obj)
        obj.config.use_mex = true;
        obj.config.threads = 4;

        pix = PixelData(obj.test_sqw_file_path);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', 4.75e-4);
        assertEqual(e, obj.ref_e_data, '', 4.75e-4);
    end

    function test_compute_bin_data_correct_output_all_data_in_memory_mex_off(obj)
        obj.config.use_mex = false;

        pix = PixelData(obj.test_sqw_file_path);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', 4.75e-4);
        assertEqual(e, obj.ref_e_data, '', 4.75e-4);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_1_thread(obj)
        obj.config.use_mex = true;
        obj.config.threads = 1;

        pix = PixelData(obj.test_sqw_file_path, obj.page_size);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', 4.75e-4);
        assertEqual(e, obj.ref_e_data, '', 4.75e-4);
    end

    function test_compute_bin_data_correct_output_5_pages_mex_1_thread(obj)
        obj.config.use_mex = true;
        obj.config.threads = 1;

        file_info = dir(obj.test_sqw_file_path);
        pg_size = file_info.bytes/5;
        pix = PixelData(obj.test_sqw_file_path, pg_size);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', 4.75e-4);
        assertEqual(e, obj.ref_e_data, '', 4.75e-4);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_4_threads(obj)
        obj.config.use_mex = true;
        obj.config.threads = 4;

        pix = PixelData(obj.test_sqw_file_path, obj.page_size);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', 4.75e-4);
        assertEqual(e, obj.ref_e_data, '', 4.75e-4);
    end

    function test_compute_bin_data_correct_output_file_backed_mex_off(obj)
        obj.config.use_mex = false;

        pix = PixelData(obj.test_sqw_file_path, obj.page_size);
        [s, e] = pix.compute_bin_data(obj.ref_npix_data);

        assertEqual(s, obj.ref_s_data, '', 4.75e-4);
        assertEqual(e, obj.ref_e_data, '', 4.75e-4);
    end

end

end
