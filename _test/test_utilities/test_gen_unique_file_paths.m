classdef test_gen_unique_file_paths < TestCase

    methods

        function test_error_if_nfiles_not_positive_int(~)
            f = @() gen_unique_file_paths(0, '', '');
            assertExceptionThrown(f, 'MATLAB:expectedPositive');
        end

        function test_error_if_prefix_not_char_or_string(~)
            f = @() gen_unique_file_paths(1, 100, '');
            assertExceptionThrown(f, 'MATLAB:invalidType');
        end

        function test_error_if_base_dir_not_char_or_string(~)
            f = @() gen_unique_file_paths(1, '', 100);
            assertExceptionThrown(f, 'MATLAB:invalidType');
        end

        function test_error_if_ext_not_char_or_string(~)
            f = @() gen_unique_file_paths(1, '',  '', 100);
            assertExceptionThrown(f, 'MATLAB:invalidType');
        end

        function test_all_output_file_names_startwith_prefix(~)
            prefix = 'MY_PREFIX';
            nfiles = 2;
            paths = gen_unique_file_paths(nfiles, prefix, '');

            for i = 1:numel(paths)
                [~, base_name] = fileparts(paths{i});
                assertTrue(startsWith(base_name, prefix));
            end
        end

        function test_all_output_paths_within_base_dir(~)
            base_dir = fullfile('my', 'dir');
            nfiles = 2;
            paths = gen_unique_file_paths(nfiles, 'MY_PREFIX', base_dir);
            for i = 1:numel(paths)
                [dir_name, ~] = fileparts(paths{i});
                assertEqual(dir_name, base_dir);
            end
        end

        function test_zero_padded_counter_suffixes_file_base_names(~)
            prefix = 'MY_PREFIX';
            nfiles = 101;
            paths = gen_unique_file_paths(nfiles, prefix, '');

            for i = 1:numel(paths)
                [~, base_name] = fileparts(paths{i});
                padded_ctr = sprintf('_%03i', i);
                assertTrue(endsWith(base_name, padded_ctr));
            end
        end

        function test_same_36_char_UUID_proceeds_prefix_in_all_paths(~)
            prefix = 'MY_PREFIX';
            nfiles = 2;
            paths = gen_unique_file_paths(nfiles, prefix, '');

            path_1 = paths{1};
            regex_pattern = sprintf('%s_(?<uuid>[\\w-]{36})_.*', prefix);
            match_1 = regexp(path_1, regex_pattern, 'names');

            assertTrue(~isempty(match_1));
            for i = 2:numel(paths)
                match = regexp(paths{i}, regex_pattern, 'names');
                assertEqual(match, match_1);
            end
        end

        function test_all_file_paths_end_with_input_file_extension(~)
            prefix = 'MY_PREFIX';
            nfiles = 2;
            ext = 'my_ext';
            paths = gen_unique_file_paths(nfiles, prefix, '', ext);

            for i = 1:numel(paths)
                assertTrue(endsWith(paths{i}, ext));
            end
        end

        function test_default_file_extension_is_tmp(~)
            prefix = 'MY_PREFIX';
            nfiles = 2;
            paths = gen_unique_file_paths(nfiles, prefix, '');

            for i = 1:numel(paths)
                assertTrue(endsWith(paths{i}, 'tmp'));
            end
        end

        function test_separate_calls_generate_different_UUIDs(~)
            regex_pattern = '_(?<uuid>[\w-]{36})_.*';

            paths_1 = gen_unique_file_paths(1, '', '');
            match_1 = regexp(paths_1{1}, regex_pattern, 'names');

            paths_2 = gen_unique_file_paths(1, '', '');
            match_2 = regexp(paths_2{1}, regex_pattern, 'names');

            assertFalse(strcmp(match_1.uuid, match_2.uuid));
        end
    end

end
