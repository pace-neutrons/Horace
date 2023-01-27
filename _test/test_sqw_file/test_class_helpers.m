classdef test_class_helpers < TestCase

methods

    function obj = test_class_helpers(~)
        obj = obj@TestCase('test_class_helpers');
    end

    function test_get_read_seek_sizes_with_increasing_indices(~)
        indices = [3:7, 10, 40:41];
        [read_size, seek_size] = get_read_and_seek_sizes(indices);
        assertEqual(read_size, [5, 1, 2]);
        assertEqual(seek_size, [2, 2, 29]);
    end

    function test_get_read_seek_sizes_with_single_index(~)
        idx = 4;
        [read_size, seek_size] = get_read_and_seek_sizes(idx);
        assertEqual(read_size, 1);
        assertEqual(seek_size, 3);
    end

    function test_get_read_seek_sizes_returns_empty_if_args_empty(~)
        [read_size, seek_size] = get_read_and_seek_sizes([]);
        assertEqual(read_size, []);
        assertEqual(seek_size, []);
    end

    function test_get_read_seek_sizes_with_unordered_indices(~)
        indices = [3:7, 40:41, 12:19];
        [read_size, seek_size] = get_read_and_seek_sizes(indices);
        assertEqual(read_size, [5, 2, 8]);
        assertEqual(seek_size, [2, 32, -30]);
    end

    function test_get_read_seek_sizes_throws_for_non_int_indices(~)
        indices = [3:7, 12:19, 25.5];
        f = @() get_read_and_seek_sizes(indices);
        assertExceptionThrown(f, 'MATLAB:expectedInteger');
    end

    function test_get_read_seek_sizes_throws_for_negative_indices(~)
        indices = [-3:7, 40:41, 12:19];
        f = @() get_read_and_seek_sizes(indices);
        assertExceptionThrown(f, 'MATLAB:expectedPositive');
    end

    function test_get_read_seek_sizes_can_handle_repeated_indices(~)
        indices = [3:7, 7, 40:41, 40:41, 12:19];
        [read_size, seek_size] = get_read_and_seek_sizes(indices);
        assertEqual(read_size, [5, 1, 2, 2, 8]);
        assertEqual(seek_size, [2, -1, 32, -2, -30]);
    end

end

end
