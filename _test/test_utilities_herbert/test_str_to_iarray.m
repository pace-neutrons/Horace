classdef test_str_to_iarray < TestCase
    % Test test_str_to_iarray
    %
    % str_to_iarray converts a string, character array or cell array of strings
    % to an integer array
    
    methods
        %--------------------------------------------------------------------------
        % Single number
        %--------------------------------------------------------------------------
        function test_single_number (~)
            % Test constructor with no arguments
            iarr = str_to_iarray ('37');
            assertEqual (iarr, 37)
        end
        
        %--------------------------------------------------------------------------
        % Matlab style tokens
        %--------------------------------------------------------------------------
        function test_range (~)
            iarr = str_to_iarray ('-3:6');
            assertEqual (iarr, -3:6)
        end
        
        function test_range_rhs_lt_lhs (~)
            iarr = str_to_iarray ('6:-3');
            assertEqual (iarr, 6:-3)
        end
        
        function test_range_with_positive_stride (~)
            iarr = str_to_iarray ('3:2:8');
            assertEqual (iarr, 3:2:8)
        end
        
        function test_range_with_negative_stride (~)
            iarr = str_to_iarray ('3:-2:8');
            assertEqual (iarr, 3:-2:8)
        end
        
        function test_range_with_positive_stride_rhs_lt_lhs (~)
            iarr = str_to_iarray ('3:2:-4');
            assertEqual (iarr, 3:2:-4)
        end
        
        function test_range_with_negative_stride_rhs_gt_lhs (~)
            iarr = str_to_iarray ('3:-2:8');
            assertEqual (iarr, 3:-2:8)
        end

        function test_range_with_zero_stride_rhs_lt_lhs (~)
            func = @()str_to_iarray ('3:0:-4');
            assertExceptionThrown (func, 'HERBERT:str_to_iarray:invalid_argument');
        end
        
        function test_range_with_zero_stride_rhs_gt_lhs (~)
            func = @()str_to_iarray ('3:0:8');
            assertExceptionThrown (func, 'HERBERT:str_to_iarray:invalid_argument');
        end
        
        
        %--------------------------------------------------------------------------
        % non-Matlab format tokens
        %--------------------------------------------------------------------------
        function test_non_Matlab_range_pos2pos_ascend (~)
            iarr = str_to_iarray ('3-8');
            assertEqual (iarr, 3:8)
        end
        
        function test_non_Matlab_range_pos2pos_descend (~)
            iarr = str_to_iarray ('8-3');
            assertEqual (iarr, 8:-1:3)
        end
        
        function test_non_Matlab_range_neg2pos_ascend (~)
            iarr = str_to_iarray ('-3-8');
            assertEqual (iarr, -3:8)
        end
        
        function test_non_Matlab_range_pos2neg_descend (~)
            iarr = str_to_iarray ('3--8');
            assertEqual (iarr, 3:-1:-8)
        end
        
        function test_non_Matlab_range_neg2neg_ascend (~)
            iarr = str_to_iarray ('-8--3');
            assertEqual (iarr, -8:-3)
        end
        
        function test_non_Matlab_range_neg2neg_descend (~)
            iarr = str_to_iarray ('-3--8');
            assertEqual (iarr, -3:-1:-8)
        end
       
        function test_non_Matlab_range_neg2neg_single (~)
            % Tough test of parsing?
            iarr = str_to_iarray ('-3--3');
            assertEqual (iarr, -3)
        end
       
        function test_non_Matlab_range_neg2neg_single_FAIL (~)
            % Tough test of parsing? Catch erroneous range indicator at front
            func = @()str_to_iarray ('--3--3');
            assertExceptionThrown (func, 'HERBERT:str_to_iarray:invalid_argument');
        end
       
        
        %--------------------------------------------------------------------------
        % Tokens with whitespace
        %--------------------------------------------------------------------------
        function test_single_number_WS (~)
            iarr = str_to_iarray ('  45  ');
            assertEqual (iarr, 45)
        end
        
        function test_range_with_positive_stride_rhs_gt_lhs_WS (~)
            iarr = str_to_iarray ('  3:2:14  ');
            assertEqual (iarr, 3:2:14)
        end
                
        function test_range_with_positive_stride_rhs_gt_lhs_WSfail (~)
            % Should fail as we do not permit whitespace within the token
            func = @()str_to_iarray (' 3 :2: 14');
            assertExceptionThrown (func, 'HERBERT:str_to_iarray:invalid_argument');
        end
        
        function test_non_Matlab_range_with_positive_stride_rhs_gt_lhs_WS (~)
            iarr = str_to_iarray ('  3-14  ');
            assertEqual (iarr, 3:14)
        end
                
        function test_non_Matlab_range_with_positive_stride_rhs_gt_lhs_WSfail (~)
            % Should fail as we do not permit whitespace within the token
            func = @()str_to_iarray (' 3 - 14');
            assertExceptionThrown (func, 'HERBERT:str_to_iarray:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        % Multiple tokens
        %--------------------------------------------------------------------------
        function test_two_numbers (~)
            iarr = str_to_iarray ('45,46');
            assertEqual (iarr, [45,46])
        end
        
        function test_mixed_format_ranges (~)
            iarr = str_to_iarray ('14:-2:5, 19 -3--6  4:6');
            assertEqual (iarr, [14:-2:5, 19, -3:-1:-6, 4:6])
        end
        
        %--------------------------------------------------------------------------
        % Enclosing brackets
        %--------------------------------------------------------------------------
        function test_array_scalar (~)
            % Test constructor with no arguments
            iarr = str_to_iarray ('[37]');
            assertEqual (iarr, 37)
        end
        
        function test_array_range (~)
            % Test constructor with no arguments
            iarr = str_to_iarray (' [ 46,  45] ');
            assertEqual (iarr, [46,45])
        end
        
        %--------------------------------------------------------------------------
        % Comment lines, multiple lines
        %--------------------------------------------------------------------------
        function test_comment_line (~)
            % Test constructor with no arguments
            iarr = str_to_iarray ('% 35');
            assertEqual (iarr, NaN(1,0))
        end
        
        function test_trailing_comment (~)
            % Test constructor with no arguments
            iarr = str_to_iarray (' [ 46,  45] % a comment');
            assertEqual (iarr, [46,45])
        end
        
        function test_two_lines (~)
            % Test constructor with no arguments
            iarr = str_to_iarray ({'45:47','49'});
            assertEqual (iarr, [45:47,49])
        end
        
    end
end
