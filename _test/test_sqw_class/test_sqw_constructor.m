classdef test_sqw_constructor < TestCase

properties
    sqw_file_1d_name = 'sqw_1d_1.sqw';
    sqw_files_path = '../test_sqw_file/';

    test_sqw_1d_fullpath = '';
end

methods

    function obj = test_sqw_constructor(~)
        obj = obj@TestCase('test_sqw_constructor');

        test_sqw_file = java.io.File(pwd(), fullfile(obj.sqw_files_path, obj.sqw_file_1d_name));
        obj.test_sqw_1d_fullpath = char(test_sqw_file.getCanonicalPath());
    end

    function test_default_constructor_returns_empty_instance(obj)
        sqw_obj = sqw();

        assertTrue(isa(sqw_obj, 'sqw'));
        assertEqual(sqw_obj.main_header, struct([]));
        assertEqual(sqw_obj.header, struct([]));
        assertEqual(sqw_obj.detpar, struct([]));
        assertEqual(sqw_obj.data.pix, PixelData());
        assertEqual(numel(sqw_obj.data.pax), 0);
    end

    function test_filename_constructor_returns_populated_class(obj)
        sqw_obj = sqw(obj.test_sqw_1d_fullpath);

        assertTrue(isa(sqw_obj, 'sqw'));
        assertEqual(sqw_obj.main_header.nfiles, 85)
        assertEqual(numel(sqw_obj.header), 85)
        assertEqual(numel(sqw_obj.detpar.group), 36864);
        assertEqual(numel(sqw_obj.data.pax), 1);
        assertEqual(sqw_obj.data.pix.page_size, 100337);
    end

    function test_copy_constructor_clones_object(obj)
        sqw_obj = sqw(obj.test_sqw_1d_fullpath);
        sqw_copy = sqw(sqw_obj);

        assertTrue(isa(sqw_obj, 'sqw'));
        assertEqual(sqw_copy.main_header, sqw_obj.main_header)
        assertEqual(sqw_copy.header, sqw_obj.header)
        assertEqual(sqw_copy.data.pax, sqw_obj.data.pax);
        assertEqual(sqw_copy.detpar, sqw_obj.detpar);

        assertTrue(equal_to_tol(sqw_copy, sqw_obj))
    end

    function test_copy_constructor_returns_distinct_object(obj)
        sqw_obj = sqw(obj.test_sqw_1d_fullpath);
        sqw_copy = sqw(sqw_obj);

        sqw_copy.main_header.title = 'test_copy';
        sqw_copy.header = struct([]);
        sqw_copy.detpar.azim(1:10) = 0;
        sqw_copy.data.pix.signal = 1;

        % changed data is not mirrored in initial
        assertFalse(equal_to_tol(sqw_copy, sqw_obj))
    end

    function test_save_load_returns_identical_object(obj)
        tmp_filename=fullfile(tmp_dir, 'sqw_loadobj_test.mat');
        cleanup_obj=onCleanup(@() delete(tmp_filename));

        sqw_obj = sqw(obj.test_sqw_1d_fullpath);
        save(tmp_filename, 'sqw_obj');
        from_file = load(tmp_filename);
        assertTrue(equal_to_tol(from_file.sqw_obj, sqw_obj))
    end

end
end
