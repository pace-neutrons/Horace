classdef test_resolve_repeat_w_blocks < TestCase
    % Test resolving placeholder values for iw_beg and delta_w, and getting the
    % range of the output workspaces for the repeated blocks of spectra
    
    methods
        %-----------------------------------------------------------------------
        function test_delta_w_NaN (~)
            % delta_w_in is a placeholder - needs to set from nw
            iw_beg_in = 11; iw_dcn = 1; delta_w_in = NaN; nw = 5; nrepeat = 4; iw_max_prev = 50;
            
            [iw_beg, delta_w, iw_min, iw_max] = exposed_IX_map.resolve_repeat_w_blocks ...
                (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual ([iw_beg, delta_w, iw_min, iw_max], [11, 5, 11, 30])
        end
        
        %-----------------------------------------------------------------------
        function test_delta_w_NaN_iw_dcn_Neg (~)
            % delta_w_in is a placeholder - needs to set from nw; now iw_dcn -ve
            iw_beg_in = 105; iw_dcn = -1; delta_w_in = NaN; nw = 5; nrepeat = 4; iw_max_prev = 50;
            
            [iw_beg, delta_w, iw_min, iw_max] = exposed_IX_map.resolve_repeat_w_blocks ...
                (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual ([iw_beg, delta_w, iw_min, iw_max], [105, 5, 101, 120])
        end
        
        %-----------------------------------------------------------------------
        function test_iw_beg_NaN (~)
            % iw_beg_in a placeholder - uses iw_max_prev
            iw_beg_in = NaN; iw_dcn = 1; delta_w_in = 1000; nw = 5; nrepeat = 4; iw_max_prev = 100;
            
            [iw_beg, delta_w, iw_min, iw_max] = exposed_IX_map.resolve_repeat_w_blocks ...
                (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual ([iw_beg, delta_w, iw_min, iw_max], [101, 1000, 101, 3105])
        end
        
        %-----------------------------------------------------------------------
        function test_iw_beg_NaN_iw_dcn_Neg (~)
            % iw_beg_in a placeholder - uses iw_max_prev; now iw_dcn -ve
            iw_beg_in = NaN; iw_dcn = -1; delta_w_in = 5; nw = 10; nrepeat = 4; iw_max_prev = 50;
            
            [iw_beg, delta_w, iw_min, iw_max] = exposed_IX_map.resolve_repeat_w_blocks ...
                (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual ([iw_beg, delta_w, iw_min, iw_max], [60, 5, 51, 75])
        end
        
        %-----------------------------------------------------------------------
    end
end
