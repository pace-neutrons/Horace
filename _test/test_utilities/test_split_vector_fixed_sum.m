classdef test_split_vector_fixed_sum < TestCase

methods
    function obj = test_split_vector_fixed_sum(~)
        obj@TestCase('test_split_vector_fixed_sum');
    end

    function test_outputs_are_empty_if_inputs_are_empty(~)
        [chunks, idxs] = split_vector_fixed_sum([], []);
        assertTrue(isa(chunks, 'cell'))
        assertTrue(isempty(chunks));
        assertTrue(isa(idxs, 'double'))
        assertTrue(isempty(idxs));
    end

    function test_error_if_first_arg_is_not_a_vector(~)
        vector = ones(2, 10);
        f = @() split_vector_fixed_sum(vector, 100);
        assertExceptionThrown(f, 'MATLAB:expectedVector');
    end

    function test_error_if_any_value_of_input_is_negative(~)
        vector = ones(1, 10);
        vector(5) = -1;
        f = @() split_vector_fixed_sum(vector, 100);
        assertExceptionThrown(f, 'MATLAB:expectedNonnegative');
    end

    function test_error_if_max_input_is_not_a_scalar(~)
        vector = ones(1, 10);
        f = @() split_vector_fixed_sum(vector, [1, 1]);
        assertExceptionThrown(f, 'MATLAB:expectedScalar');
    end

    function test_error_if_chunk_sum_is_zero(~)
        vector = ones(1, 10);
        f = @() split_vector_fixed_sum(vector, 0);
        assertExceptionThrown(f, 'MATLAB:expectedPositive');
    end

    function test_error_if_chunk_sum_is_negative(~)
        vector = ones(1, 10);
        f = @() split_vector_fixed_sum(vector, -1);
        assertExceptionThrown(f, 'MATLAB:expectedPositive');
    end

    function test_input_vector_is_split_into_expected_chunks(~)
        numeric_vector = [3, 2, 0, 6, 0, 5, 3, 1, 1, 24, 4, 2, 3, 0];
        chunk_sum = 10;
        [chunks, idxs] = split_vector_fixed_sum(numeric_vector, chunk_sum);

        expected_chunks = {
            [3, 2, 0, 5], ...
            [1, 0, 5, 3, 1], ...
            [1, 9], ...
            10, ...
            [5, 4, 1], ...
            [1, 3, 0] ...
        };
        assertEqual(chunks, expected_chunks);

        expected_idxs = [1, 4,  9, 10, 10, 12;
                         4, 8, 10, 10, 12, 14];
        assertEqual(idxs, expected_idxs);
    end

    function test_input_vector_is_split_into_expected_chunks_0_at_chunk_end(~)
        numeric_vector = [3, 2, 0, 5, 0, 0, 6, 0, 5, 0, 0];
        chunk_sum = 10;
        [chunks, idxs] = split_vector_fixed_sum(numeric_vector, chunk_sum);

        expected_chunks = {
            [3, 2, 0, 5, 0, 0], ...
            [6, 0, 4], ...
            [1, 0, 0] ...
        };
        assertEqual(chunks, expected_chunks);

        expected_idxs = [1, 7,  9;
                         6, 9, 11];
        assertEqual(idxs, expected_idxs);
    end

    function test_input_vector_is_split_into_expected_chunks_zeros_at_start(~)
        numeric_vector = [0, 0, 3, 2, 0, 5, 0, 0, 6, 0, 5, 0, 0];
        chunk_sum = 10;
        [chunks, idxs] = split_vector_fixed_sum(numeric_vector, chunk_sum);

        expected_chunks = {
            [0, 0, 3, 2, 0, 5, 0, 0], ...
            [6, 0, 4], ...
            [1, 0, 0] ...
        };
        assertEqual(chunks, expected_chunks);

        expected_idxs = [1, 9,  11;
                         8, 11, 13];
        assertEqual(idxs, expected_idxs);
    end

    function test_column_vector_split_into_expected_chunks(~)
        numeric_vector = [3, 2, 0, 6, 0, 5, 3, 1, 1, 24, 4, 2, 3, 0];
        chunk_sum = 10;
        [chunks, idxs] = split_vector_fixed_sum(numeric_vector', chunk_sum);

        expected_chunks = {
            [3, 2, 0, 5], ...
            [1, 0, 5, 3, 1], ...
            [1, 9], ...
            10, ...
            [5, 4, 1], ...
            [1, 3, 0] ...
        };
        assertEqual(chunks, expected_chunks);

        expected_idxs = [1, 4,  9, 10, 10, 12;
                         4, 8, 10, 10, 12, 14];
        assertEqual(idxs, expected_idxs);
    end

    function test_scalar_input_vector_split_if_value_gt_chunk_sum(~)
        numeric_vector = 24;
        chunk_sum = 10;
        [chunks, idxs] = split_vector_fixed_sum(numeric_vector, chunk_sum);
        expected_chunks = {10, 10, 4};
        assertEqual(chunks, expected_chunks);
        assertEqual(idxs, [1, 1, 1; 1, 1, 1]);
    end

    function test_correct_splitting_if_first_element_gt_chunk_sum(~)
        numeric_vector = [23, 2, 0, 6, 0, 5, 3, 1, 1, 24, 4, 2, 3, 0];
        chunk_sum = 10;
        [chunks, idxs] = split_vector_fixed_sum(numeric_vector, chunk_sum);

        expected_chunks = {
            10, ...
            10, ...
            [3, 2, 0, 5], ...
            [1, 0, 5, 3, 1], ...
            [1, 9], ...
            10, ...
            [5, 4, 1], ...
            [1, 3, 0] ...
        };
        assertEqual(chunks, expected_chunks);

        expected_idxs = [1, 1, 1, 4, 9, 10, 10, 12;
                         1, 1, 4, 8, 10, 10, 12, 14];
        assertEqual(idxs, expected_idxs);
    end

    function test_scalar_lt_chunk_sum_returns_single_chunk_containing_scalar(~)
        [chunks, idxs] = split_vector_fixed_sum(10, 20);
        assertEqual(chunks, {10});
        assertEqual(idxs, [1; 1]);
    end
end

end
