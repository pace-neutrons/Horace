classdef test_accumulate_array_to_buffer < TestCase
    % test_accumulate_array_to_buffer tests accumulate_array_to_buffer
    
    methods
        %-----------------------------------------------------------------------
        %   Empty buffer size [0,0]
        %-----------------------------------------------------------------------
        function test_emptySize00Buffer_emptySize00Vals (~)
            buffer = [];
            nel = 0;
            vals = [];
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(buffer, vals);
            assertEqual(nel, 0);
        end
        
        function test_emptySize00Buffer_emptyRowVals (~)
            buffer = [];
            nel = 0;
            vals = zeros(1,0);
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(buffer, []);
            assertEqual(nel, 0);
        end
        
        function test_emptySize00Buffer_rowVals (~)
            buffer = [];
            nel = 0;
            vals = zeros(1,2);
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,2), 1);
            assertEqual(nel, 2);
        end
        
        function test_emptySize00Buffer_emptyColVals (~)
            buffer = [];
            nel = 0;
            vals = zeros(0,1);
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(buffer, []);
            assertEqual(nel, 0);
        end
        
        function test_emptySize00Buffer_colVals (~)
            buffer = [];
            nel = 0;
            vals = zeros(2,1);
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,2), 1);
            assertEqual(nel, 2);
        end
        
        %-----------------------------------------------------------------------
        %   Empty row, empty column or scalar buffer
        %-----------------------------------------------------------------------
        function test_emptyRowBuffer_colVals (~)
            buffer = zeros(1,0);
            nel = [];
            vals = zeros(2,1);
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,1), 1);
            assertEqual(nel, 2);
        end
        
        function test_emptyColBuffer_rowVals (~)
            buffer = zeros(0,1);
            nel = [];
            vals = zeros(1,2);
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,2), 1);
            assertEqual(nel, 2);
        end
        
        %-----------------------------------------------------------------------
        %   Scalar buffer
        %-----------------------------------------------------------------------
        function test_scalarBuffer_rowVals (~)
            buffer = 99;
            nel = 1;
            vals = zeros(1,2);
            filled_output = [buffer; vals(:)];
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,2), 1);     % column
            assertEqual(nel, 3);
            assertEqual(buffer(1:nel), filled_output);
            assertTrue(numel(buffer)>nel);      % buffer has spare space
        end
        
        function test_scalarBuffer_colVals (~)
            buffer = 99;
            nel = 1;
            vals = zeros(2,1);
            filled_output = [buffer; vals(:)];
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,2), 1);     % column
            assertEqual(nel, 3);
            assertEqual(buffer(1:nel), filled_output);
            assertTrue(numel(buffer)>nel);      % buffer has spare space
        end
        
        function test_scalarBuffer_arrayVals (~)
            buffer = 99;
            nel = [];
            vals = zeros(2,3);
            filled_output = [buffer; vals(:)];
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,2), 1);     % column
            assertEqual(nel, 7);
            assertEqual(buffer(1:nel), filled_output);
            assertTrue(numel(buffer)>nel);      % buffer has spare space
        end  
        
        %-----------------------------------------------------------------------
        %   Row buffer length > 1
        %-----------------------------------------------------------------------
        function test_rowBuffer_arrayVals (~)
            buffer = [101:104,NaN,NaN];
            nel = 4;
            vals = rand(2,3);
            filled_output = [buffer(1:nel), vals(:)'];
            [buffer, nel] = accumulate_array_to_buffer (buffer, nel, vals);
            assertEqual(size(buffer,1), 1);     % row
            assertEqual(nel, 10);
            assertEqual(buffer(1:nel), filled_output);
            assertTrue(numel(buffer)>nel);      % buffer has spare space
        end
        
        %-----------------------------------------------------------------------
        %   Create buffer array
        %-----------------------------------------------------------------------
        function test_create_emptyBuffer (~)
            [buffer, nel] = accumulate_array_to_buffer (0);
            assertEqual(buffer, NaN(0));
            assertEqual(nel, 0);
        end
        
        function test_create_Buffer (~)
            [buffer, nel] = accumulate_array_to_buffer ([3,2]);
            assertEqual(buffer, NaN(3,2),'-nan_equal');
            assertEqual(nel, 0);
        end
        
    end
end
