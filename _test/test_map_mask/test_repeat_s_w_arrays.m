classdef test_repeat_s_w_arrays < TestCase
    % Test repeat_s_w_arrays
    
    methods
        %-----------------------------------------------------------------------
        function test_oneRepeat (~)
            % nrepeat = 1 (i.e. no repeat)
            
            is = [1 4 5];
            iw = [1 2 1];
            nrepeat = 1;
            delta_sp = 10;
            delta_w = 2;
                        
            is_ref = is';
            iw_ref = iw';
            [is_out, iw_out] = exposed_IX_map.repeat_s_w_arrays ...
                (is, iw, nrepeat, delta_sp, delta_w);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
        function test_manyRepeats (~)
            % nrepeat = 3
            
            is = [1 4 5];
            iw = [1 2 1];
            nrepeat = 3;
            delta_sp = 10;
            delta_w = 2;
                        
            is_ref = [1 4 5 11 14 15 21 24 25]';
            iw_ref = [1 2 1 3 4 3 5 6 5]';
            [is_out, iw_out] = exposed_IX_map.repeat_s_w_arrays ...
                (is, iw, nrepeat, delta_sp, delta_w);
            assertEqual (is_out, is_ref)
            assertEqual (iw_out, iw_ref)
        end
        
        %-----------------------------------------------------------------------
    end
end
