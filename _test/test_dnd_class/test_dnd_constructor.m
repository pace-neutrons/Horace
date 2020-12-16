classdef test_dnd_constructor < TestCase

properties
    dnd_file_2d_name = 'dnd_2d.sqw';
    sqw_file_1d_name = 'sqw_1d_1.sqw';
    sqw_file_2d_name = 'sqw_2d_1.sqw';
    test_files_path = '../test_sqw_file/';

    test_dnd_2d_fullpath = '';
    test_sqw_1d_fullpath = '';
    test_sqw_2d_fullpath = '';
end

methods

    function obj = test_dnd_constructor(~)
        obj = obj@TestCase('test_dnd_constructor');

        test_sqw_1d_file = java.io.File(pwd(), fullfile(obj.test_files_path, obj.sqw_file_1d_name));
        obj.test_sqw_1d_fullpath = char(test_sqw_1d_file.getCanonicalPath());

        test_sqw_2d_file = java.io.File(pwd(), fullfile(obj.test_files_path, obj.sqw_file_2d_name));
        obj.test_sqw_2d_fullpath = char(test_sqw_2d_file.getCanonicalPath());

        test_dnd_2d_file = java.io.File(pwd(), fullfile(obj.test_files_path, obj.dnd_file_2d_name));
        obj.test_dnd_2d_fullpath = char(test_dnd_2d_file.getCanonicalPath());
    end

    function test_dnd_classes_follow_expected_class_heirarchy(obj)
        dnd_objects = { d0d(), d1d(), d2d(), d3d(), d4d() };
        for idx = 1:numel(dnd_objects)
            dnd_obj = dnd_objects{idx};
            assertTrue(isa(dnd_obj, 'DnDBase'));
            assertTrue(isa(dnd_obj, 'SQWDnDBase'));
        end
    end

    function test_d0d_constructor_returns_zero_d_instance(obj)
        dnd_obj = d0d();

        assertEqual(numel(dnd_obj.pax), 0);
        assertEqual(dnd_obj.dimensions(), 0);
    end
    function test_d1d_constructor_returns_1d_instance(obj)
        dnd_obj = d1d();

        assertEqual(numel(dnd_obj.pax), 1);
        assertEqual(dnd_obj.dimensions(), 1);
    end
    function test_d2d_constructor_returns_2d_instance(obj)
          dnd_obj = d2d();

          assertEqual(numel(dnd_obj.pax), 2);
          assertEqual(dnd_obj.dimensions(), 2);
    end
    function test_d3d_constructor_returns_3d_instance(obj)
        dnd_obj = d3d();

        assertEqual(numel(dnd_obj.pax), 3);
        assertEqual(dnd_obj.dimensions(), 3);
    end
    function test_d4d_constructor_returns_4d_instance(obj)
        dnd_obj = d4d();

        assertEqual(numel(dnd_obj.pax), 4);
        assertEqual(dnd_obj.dimensions(), 4);
    end


    function test_default_constructor_returns_empty_instance(obj)
        dnd_obj = d2d();

        assertEqualToTol(dnd_obj.s, 0, 1e-6);
        assertEqualToTol(dnd_obj.e, 0, 1e-6);
    end

    function test_d2d_contains_expected_properties(obj)
        expected_props = { ...
            'filename', 'filepath', 'title', 'alatt', 'angdeg', ...
            'uoffset', 'u_to_rlu', 'ulen', 'ulabel', 'iax', ...
             'iint', 'pax', 'p', 'dax', 's', 'e', 'npix'};

        dnd_obj = d2d();
        actual_props = fieldnames(dnd_obj);

        assertEqual(numel(actual_props), numel(expected_props));
        for idx = 1:numel(actual_props)
            assertTrue( ...
                any(strcmp(expected_props, actual_props(idx))), ...
                sprintf('Unrecognised DnD property "%s"', actual_props{idx}));
        end
    end

    function test_d2d_get_returns_set_properties(obj)
        dnd_obj = d2d();
        class_props = fieldnames(dnd_obj);

        % properties are mapped to an internal data structure; verify the getters and
        % setters are correctly wired
        for idx = 1:numel(class_props)
            test_value = rand(10);
            prop_name = class_props{idx};
            dnd_obj.(prop_name) = test_value;
            assertEqual(dnd_obj.(prop_name), test_value, ...
                sprintf('Value set to "%s" not returned', prop_name));
        end
    end

    function test_copy_constructor_clones_d2d_object(obj)
        dnd_obj = d2d(obj.test_dnd_2d_fullpath);
        dnd_copy = d2d(dnd_obj);

        assertTrue(isa(dnd_obj, 'd2d'));
        assertEqualToTol(dnd_copy, dnd_obj);
    end

    function test_copy_constructor_clones_d4d_object(obj)
        dnd_obj = d4d();
        dnd_copy = d4d(dnd_obj);

        assertTrue(isa(dnd_obj, 'd4d'));
        assertEqualToTol(dnd_copy, dnd_obj);
    end

    function test_copy_constructor_returns_distinct_object(obj)
        dnd_obj = d2d(obj.test_dnd_2d_fullpath);
        dnd_copy = d2d(dnd_obj);

        dnd_copy.angdeg = [1, 25, 80];
        dnd_copy.title = 'test string';
        dnd_copy.p{1} = [2,4,6];
        dnd_copy.s = ones(10);

        % changed data is not mirrored in initial
        assertFalse(equal_to_tol(dnd_copy.angdeg, dnd_obj.angdeg));
        assertFalse(equal_to_tol(dnd_copy.title, dnd_obj.title));
        assertFalse(equal_to_tol(dnd_copy.p, dnd_obj.p));
        assertFalse(equal_to_tol(dnd_copy.s , dnd_obj.s));

        assertFalse(equal_to_tol(dnd_copy, dnd_obj));
    end

    function test_filename_constructor_returns_populated_class(obj)
        d2d_obj = d2d(obj.test_dnd_2d_fullpath);

        expected_ulen = [2.101896, 1.486265, 2.101896, 1.0000];
        expected_u_to_rlu = [1, 0, 1, 0; 1, 0, -1, 0; 0, 1, 0, 0; 0, 0, 0, 1];

        % expected data populated from instance of test object
        assertTrue(isa(d2d_obj, 'd2d'));
        assertEqual(d2d_obj.dax, [1, 2]);
        assertEqual(d2d_obj.iax, [3, 4]);
        assertEqual(size(d2d_obj.s), [16, 11]);
        assertEqualToTol(d2d_obj.ulen, expected_ulen, 'tol', 1e-5);
        assertEqual(d2d_obj.u_to_rlu, expected_u_to_rlu, 'tol', 1e-5);
    end

    function test_d2d_sqw_constuctor_raises_error_from_1d_sqw_object(obj)
        sqw_obj = sqw(obj.test_sqw_1d_fullpath);
        f = @() d2d(sqw_obj);

        assertExceptionThrown(f, 'D2D:d2d');
    end

    function test_d1d_sqw_constuctor_creates_d1d_from_1d_sqw_object(obj)
        sqw_obj = sqw(obj.test_sqw_1d_fullpath);
        d1d_obj = d1d(sqw_obj);

        assertEqual(sqw_obj.data.s, d1d_obj.s);
        assertEqual(sqw_obj.data.e, d1d_obj.e);
        assertEqual(sqw_obj.data.p, d1d_obj.p);
        assertEqual(sqw_obj.data.ulabel, d1d_obj.ulabel);
    end

    function test_d2d_sqw_constuctor_creates_d2d_from_2d_sqw_object(obj)
        sqw_obj = sqw(obj.test_sqw_2d_fullpath);
        d2d_obj = d2d(sqw_obj);

        assertEqual(sqw_obj.data.s, d2d_obj.s);
        assertEqual(sqw_obj.data.e, d2d_obj.e);
        assertEqual(sqw_obj.data.p, d2d_obj.p);
        assertEqual(sqw_obj.data.ulabel, d2d_obj.ulabel);
    end

end
end
