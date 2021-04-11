classdef test_split_vector_max_sum < TestCase

methods
    function obj = test_split_vector_max_sum(~)
        obj@TestCase('test_split_vector_max_sum');
    end

    function test_outputs_are_empty_if_inputs_are_empty(~)
        [chunks, idxs] = split_vector_max_sum([], []);
        assertTrue(isa(chunks, 'cell'))
        assertTrue(isempty(chunks));
        assertTrue(isa(idxs, 'double'))
        assertTrue(isempty(idxs));
    end

    function test_outputs_have_length_1_if_max_chunk_sum_gt_input_vector_sum(~)
        vector = ones(1, 10);
        max_sum = 11;
        [chunks, idxs] = split_vector_max_sum(vector, max_sum);
        assertEqual(numel(chunks), 1);
        assertEqual(chunks{1}, vector);
        assertEqual(size(idxs), [2, 1]);
        assertEqual(idxs, [1; numel(vector)]);
    end

    function test_outputs_have_length_1_if_max_chunk_sum_eq_input_vector_sum(~)
        vector = ones(1, 10);
        max_sum = 11;
        [chunks, idxs] = split_vector_max_sum(vector, max_sum);
        assertEqual(numel(chunks), 1);
        assertEqual(chunks{1}, vector);
        assertEqual(size(idxs), [2, 1]);
        assertEqual(idxs, [1; numel(vector)]);
    end

    function test_error_if_input_is_not_a_vector(~)
        vector = ones(2, 10);
        f = @() split_vector_max_sum(vector, 100);
        assertExceptionThrown(f, 'MATLAB:expectedVector');
    end

    function test_error_if_any_value_of_input_vector_is_negative(~)
        vector = ones(1, 10);
        vector(5) = -1;
        f = @() split_vector_max_sum(vector, 100);
        assertExceptionThrown(f, 'MATLAB:expectedNonnegative');
    end

    function test_error_if_max_chunk_sum_is_not_a_scalar(~)
        vector = ones(1, 10);
        f = @() split_vector_max_sum(vector, [1, 1]);
        assertExceptionThrown(f, 'MATLAB:expectedScalar');
    end

    function test_error_if_max_chunk_sum_is_zero(~)
        vector = ones(1, 10);
        f = @() split_vector_max_sum(vector, 0);
        assertExceptionThrown(f, 'MATLAB:expectedPositive');
    end

    function test_error_if_max_chunk_sum_is_negative(~)
        vector = ones(1, 10);
        f = @() split_vector_max_sum(vector, -1);
        assertExceptionThrown(f, 'MATLAB:expectedPositive');
    end

    function test_vector_value_gt_max_chunk_sum_comprises_its_own_chunk(~)
        vector = [3, 2, 0, 6, 0, 5, 3, 1, 1, 24, 4, 2, 3, 0];
        max_sum = 11;
        [chunks, idxs] = split_vector_max_sum(vector, max_sum);
        expected_chunks = { ...
            [3, 2, 0, 6, 0], ...
            [5, 3, 1, 1], ...
            24, ...
            [4, 2, 3, 0] ...
        };
        expected_idxs = [1, 6, 10, 11;
                         5, 9, 10, 14];
        assertEqual(chunks, expected_chunks);
        assertEqual(idxs, expected_idxs);
    end

    function test_chunking_correct_for_a_sample_vector_array(~)
        vector = [3, 2, 0, 6, 0, 5, 3, 1, 1, 4, 2, 3, 0];
        max_sum = 11;
        [chunks, idxs] = split_vector_max_sum(vector, max_sum);
        expected_chunks = { ...
            [3, 2, 0, 6, 0], ...
            [5, 3, 1, 1], ...
            [4, 2, 3, 0] ...
        };
        expected_idxs = [1, 6, 10;
                         5, 9, 13];
        assertEqual(chunks, expected_chunks);
        assertEqual(idxs, expected_idxs);
    end

    function test_chunking_correct_for_vector_array_with_doubles(~)
        vector = [3.5, 2.1, 0, 5.5, 0, 5.1, 3.4, 1, 1, 4.1, 2, 3, 0.2];
        max_sum = 11;
        [chunks, idxs] = split_vector_max_sum(vector, max_sum);
        expected_chunks = { ...
            [3.5, 2.1, 0], ...
            [5.5, 0, 5.1], ...
            [3.4, 1, 1, 4.1], ...
            [2, 3, 0.2] ...
        };
        expected_idxs = [1, 4, 7, 11;
                         3, 6, 10, 13];
        assertEqual(chunks, expected_chunks);
        assertEqual(idxs, expected_idxs);
    end

    function test_3rd_return_value_is_cumulative_sum_of_input_vector(~)
        vector = [3.5, 2.1, 0, 5.5, 0, 5.1, 3.4, 1, 1, 4.1, 2, 3, 0.2];
        max_sum = 11;
        [~, ~, cumulative_sum] = split_vector_max_sum(vector, max_sum);
        assertEqual(cumulative_sum, cumsum(vector));
    end
end

end
