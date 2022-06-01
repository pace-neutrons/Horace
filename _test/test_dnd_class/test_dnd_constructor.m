classdef test_dnd_constructor < TestCase

    properties (Constant)
        DND_FILE_2D_NAME = 'dnd_2d.sqw';
        SQW_FILE_1D_NAME = 'sqw_1d_1.sqw';
        SQW_FILE_2D_NAME = 'sqw_2d_1.sqw';
        SQW_FILE_4D_NAME = 'sqw_4d.sqw';

        TEST_FILES_PATH = '../common_data/';
    end

    properties
        test_dnd_2d_fullpath = '';
        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
    end

    methods(Static)
        function fullpath = build_full_path(file_relative_path, filename)
            filepath = java.io.File(pwd(), fullfile(file_relative_path, filename));
            fullpath = char(filepath.getCanonicalPath());
        end
    end

    methods

        function obj = test_dnd_constructor(~)
            obj = obj@TestCase('test_dnd_constructor');

            obj.test_sqw_1d_fullpath = obj.build_full_path(obj.TEST_FILES_PATH, obj.SQW_FILE_1D_NAME);
            obj.test_sqw_2d_fullpath = obj.build_full_path(obj.TEST_FILES_PATH, obj.SQW_FILE_2D_NAME);
            obj.test_sqw_4d_fullpath = obj.build_full_path(obj.TEST_FILES_PATH, obj.SQW_FILE_4D_NAME);

            obj.test_dnd_2d_fullpath = obj.build_full_path(obj.TEST_FILES_PATH, obj.DND_FILE_2D_NAME);
        end

        function test_dnd_classes_follow_expected_class_heirarchy(~)
            dnd_objects = { d0d(), d1d(), d2d(), d3d(), d4d() };
            for idx = 1:numel(dnd_objects)
                dnd_obj = dnd_objects{idx};
                assertTrue(isa(dnd_obj, 'DnDBase'));
                assertTrue(isa(dnd_obj, 'SQWDnDBase'));
            end
        end

        %% Dimension
        function test_d0d_constructor_returns_zero_d_instance(~)
            dnd_obj = d0d();

            assertEqual(numel(dnd_obj.pax), 0);
            assertEqual(dnd_obj.dimensions(), 0);
        end

        function test_d1d_constructor_returns_1d_instance(~)
            dnd_obj = d1d();

            assertEqual(numel(dnd_obj.pax), 1);
            assertEqual(dnd_obj.dimensions(), 1);
        end

        function test_d2d_constructor_returns_2d_instance(~)
            dnd_obj = d2d();

            assertEqual(numel(dnd_obj.pax), 2);
            assertEqual(dnd_obj.dimensions(), 2);
        end

        function test_d3d_constructor_returns_3d_instance(~)
            dnd_obj = d3d();

            assertEqual(numel(dnd_obj.pax), 3);
            assertEqual(dnd_obj.dimensions(), 3);
        end

        function test_d4d_constructor_returns_4d_instance(~)
            dnd_obj = d4d();

            assertEqual(numel(dnd_obj.pax), 4);
            assertEqual(dnd_obj.dimensions(), 4);
        end

        function test_default_constructor_returns_empty_instance(~)
            dnd_obj = d2d();

            assertEqualToTol(dnd_obj.s, 0, 1e-6);
            assertEqualToTol(dnd_obj.e, 0, 1e-6);
        end

        %% Class properties
        function test_d0d_contains_expected_properties(obj)
            dnd_obj = d0d();
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d1d_contains_expected_properties(obj)
            dnd_obj = d1d();
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d2d_contains_expected_properties(obj)
            dnd_obj = d2d();
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d3d_contains_expected_properties(obj)
            dnd_obj = d3d();
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d4d_contains_expected_properties(obj)
            dnd_obj = d4d();
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function assert_dnd_contains_expected_properties(~, dnd_obj)
            expected_props = { ...
                'filename', 'filepath', 'title', 'alatt', 'angdeg', ...
                'uoffset', 'u_to_rlu', 'ulen', 'label', 'iax', ...
                'iint', 'pax', 'p', 'dax', 's', 'e', 'npix','data',...
                'img_range','nbins_all_dims','isvalid'};

            actual_props = fieldnames(dnd_obj);

            assertEqual(numel(actual_props), numel(expected_props));
            for idx = 1:numel(actual_props)
                assertTrue( ...
                    ismember(actual_props(idx),expected_props), ...
                    sprintf('Unrecognised DnD property "%s"', actual_props{idx}));
            end
        end

        %% getters/setters
        function test_d0d_get_returns_set_properties(obj)
            dnd_obj = d0d();
            obj.assert_dnd_get_returns_set_properties(dnd_obj);
        end

        function test_d1d_get_returns_set_properties(obj)
            dnd_obj = d1d();
            obj.assert_dnd_get_returns_set_properties(dnd_obj);
        end

        function test_d2d_get_returns_set_properties(obj)
            dnd_obj = d2d();
            obj.assert_dnd_get_returns_set_properties(dnd_obj);
        end

        function test_d3d_get_returns_set_properties(obj)
            dnd_obj = d3d();
            obj.assert_dnd_get_returns_set_properties(dnd_obj);
        end

        function test_d4d_get_returns_set_properties(obj)
            dnd_obj = d4d();
            obj.assert_dnd_get_returns_set_properties(dnd_obj);
        end

        function assert_dnd_get_returns_set_properties(~, dnd_obj)
            class_props = fieldnames(dnd_obj);
            isdata = ismember(class_props,'data');
            class_props = class_props(~isdata);
            [sample_prop,dep_prop]=dnd_object_sample_properties();
            test_prop = sample_prop.keys;            
     
            % included all properties, forgot nothing
            assertTrue(all(ismember(class_props,[test_prop(:);dep_prop(:)])))

            % properties are mapped to an internal data structure; verify the getters and
            % setters are correctly wired
            for idx = 1:numel(test_prop)
                prop_name = test_prop{idx};
                test_value = sample_prop(prop_name);
                dnd_obj.(prop_name) = test_value;
                assertEqual(dnd_obj.(prop_name), test_value, ...
                    sprintf('Value set to "%s" not returned', prop_name));
            end
            assertTrue(dnd_obj.isvalid);

            function setter(obj,prop)
                val = obj.(prop);
                obj.(prop) = val;
            end            
            for idx=1:numel(dep_prop)
                assertExceptionThrown(@()setter(dnd_obj,dep_prop{idx}), ...
                    'MATLAB:class:noSetMethod');
            end

        end

        %% Copy
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

        function assert_constructor_returns_distinct_object(obj)
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

        %% Filename
        function test_filename_constructor_returns_populated_class_from_dnd_file(obj)
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

        function test_filename_constructor_returns_populated_class_from_sqw_file(obj)
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

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

        function test_fname_constr_returns_same_obj_as_sqw_constr_from_sqw_file(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            d2d_obj = d2d(obj.test_sqw_2d_fullpath);

            d2d_from_sqw = d2d(sqw_obj);

            assertEqualToTol(d2d_from_sqw, d2d_obj,'ignore_str',true);
        end


        %% SQW and dimensions checks
        function test_d2d_sqw_constuctor_raises_error_from_1d_sqw_object(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            f = @() d2d(sqw_obj);

            assertExceptionThrown(f, 'HORACE:DnDBase:invalid_argument');
        end

        function test_d1d_sqw_constuctor_creates_d1d_from_1d_sqw_object(obj)
            sqw_obj = sqw(obj.test_sqw_1d_fullpath);
            d1d_obj = d1d(sqw_obj);

            obj.assert_dnd_sqw_constructor_creates_dnd_from_sqw(sqw_obj, d1d_obj);
        end

        function test_save_load_d2d(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            d2d_obj = d2d(sqw_obj);

            wkdir = tmp_dir();
            wk_file = fullfile(wkdir,'test_save_load_d2d.mat');
            clOb = onCleanup(@()delete(wk_file));
            save(wk_file,'d2d_obj');
            ld = load(wk_file);
            assertEqual(ld.d2d_obj,d2d_obj);
        end


        function test_d2d_sqw_constuctor_creates_d2d_from_2d_sqw_object(obj)
            sqw_obj = sqw(obj.test_sqw_2d_fullpath);
            d2d_obj = d2d(sqw_obj);

            obj.assert_dnd_sqw_constructor_creates_dnd_from_sqw(sqw_obj, d2d_obj);
        end

        function test_d4d_sqw_constuctor_creates_d4d_from_4d_sqw_object(obj)
            sqw_obj = sqw(obj.test_sqw_4d_fullpath);
            d4d_obj = d4d(sqw_obj);

            obj.assert_dnd_sqw_constructor_creates_dnd_from_sqw(sqw_obj, d4d_obj);
        end

        function assert_dnd_sqw_constructor_creates_dnd_from_sqw(~, sqw_obj, dnd_obj)
            assertEqual(sqw_obj.data.s, dnd_obj.s);
            assertEqual(sqw_obj.data.e, dnd_obj.e);
            assertEqual(sqw_obj.data.p, dnd_obj.p);
            assertEqual(sqw_obj.data.npix, dnd_obj.npix)
            assertEqual(sqw_obj.data.label, dnd_obj.label);
        end


    end
end
