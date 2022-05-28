classdef test_get_ind_from_ranges< TestCase
    
    methods
        function obj = test_get_ind_from_ranges(~)
            obj@TestCase('test_get_ind_from_ranges');
        end
        function test_wrong_block_edges_ovelap(~)
            range_starts = [13; 15; 12];
            block_sizes = [4; 3; 3];
            ref = [13;14;15;16; 15; 16; 17; 12; 13; 14];
            
            calc = get_ind_from_ranges(range_starts, block_sizes);
            
            assertEqual(ref,calc);
        end
        
        function test_block_conversion_two(~)
            range_starts = [3, 15, 12];
            block_sizes = [4, 3, 3];
            ref = [3;4;5;6; 15; 16; 17; 12; 13; 14];
            
            calc = get_ind_from_ranges(range_starts, block_sizes);
            
            assertEqual(ref,calc);
        end
        
        %
        function test_block_conversion(~)
            range_starts = [1, 15, 12];
            block_sizes = [4, 3, 3];
            ref = [1; 2 ;3;4; 15; 16; 17; 12; 13; 14];
            
            calc = get_ind_from_ranges(range_starts, block_sizes);
            
            assertEqual(ref,calc);
        end
        function test_get_values_in_ranges(obj)
            range_starts = [1, 15, 12];
            block_sizes = [4, 17, 14];
            ref = [1;2;3;4; 15;16;17; 12;13;14];
            
            calc = obj.get_values_in_ranges(range_starts, block_sizes);
            
            assertEqual(ref,calc);
            
        end
        
        function out = get_values_in_ranges(~,range_starts, range_ends)
            % Get an array containing the values between the given ranges
            % e.g.
            %   >> range_starts = [1, 15, 12]
            %   >> range_ends = [4, 17, 14]
            %   >> get_values_in_ranges(range_starts, range_ends)
            %       ans = [1, 2, 3, 4, 15, 16, 17, 12, 13, 14]
            
            % Ensure the vectors are 1xN so concatenation below works
            if length(range_starts) > 1 && size(range_starts, 1) ~= 1
                range_starts = range_starts(:).';
                range_ends = range_ends(:).';
            end
            
            % Find the indexes of the boundaries of each range
            range_boundary_idxs = cumsum([1; range_ends(:) - range_starts(:) + 1]);
            % Generate vector of ones with length equal to output vector length
            value_diffs = ones(range_boundary_idxs(end) - 1, 1);
            % Insert size of the difference between boundaries in each boundary index
            value_diffs(range_boundary_idxs(1:end - 1)) = [ ...
                range_starts(1), range_starts(2:end) - range_ends(1:end - 1) ...
                ];
            % Take the cumulative sum
            out = cumsum(value_diffs);
        end
        
    end
    
end
