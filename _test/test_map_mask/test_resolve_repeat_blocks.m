classdef test_resolve_repeat_blocks < TestCase
    % Test resolving placeholder values for ix_beg and delta_ix, and getting the
    % range of the output workspaces for the repeated blocks of spectra
    
    methods
        %-----------------------------------------------------------------------
        function test_delta_ix_positive (~)
            % ix_beg_in is defined - does not need ix_max_prev, which can
            % therefore be omitted
            ix_beg_in = 51; ix_dcn = 1; delta_ix_in = 1000; nx = 5; nrepeat = 4;
            
            [ix_beg, delta_ix, ix_min, ix_max] = exposed_IX_map.resolve_repeat_blocks ...
                (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat);
            assertEqual ([ix_beg, delta_ix, ix_min, ix_max], [51, 1000, 51, 3055])
        end
        
        %-----------------------------------------------------------------------
        function test_delta_ix_negative (~)
            % ix_beg_in is defined - does not need ix_max_prev, which can
            % therefore be omitted
            ix_beg_in = 51; ix_dcn = 1; delta_ix_in = -1000; nx = 5; nrepeat = 4;
            
            [ix_beg, delta_ix, ix_min, ix_max] = exposed_IX_map.resolve_repeat_blocks ...
                (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat);
            assertEqual ([ix_beg, delta_ix, ix_min, ix_max], [51, -1000, -2949, 55])
        end
        
        %-----------------------------------------------------------------------
        function test_delta_ix_NaN (~)
            % delta_ix_in is a placeholder - needs to set from nx
            % ix_max_prev is not needed, so can be omitted
            ix_beg_in = 11; ix_dcn = 1; delta_ix_in = NaN; nx = 5; nrepeat = 4;
            
            [ix_beg, delta_ix, ix_min, ix_max] = exposed_IX_map.resolve_repeat_blocks ...
                (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat);
            assertEqual ([ix_beg, delta_ix, ix_min, ix_max], [11, 5, 11, 30])
        end
        
        %-----------------------------------------------------------------------
        function test_delta_ix_NaN_ix_dcn_Neg (~)
            % delta_ix_in is a placeholder - needs to set from nx; now ix_dcn -ve
            % ix_max_prev is not needed, so can be omitted
            ix_beg_in = 105; ix_dcn = -1; delta_ix_in = NaN; nx = 5; nrepeat = 4;
            
            [ix_beg, delta_ix, ix_min, ix_max] = exposed_IX_map.resolve_repeat_blocks ...
                (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat);
            assertEqual ([ix_beg, delta_ix, ix_min, ix_max], [105, 5, 101, 120])
        end
        
        %-----------------------------------------------------------------------
        function test_ix_beg_NaN (~)
            % ix_beg_in a placeholder - uses ix_max_prev
            ix_beg_in = NaN; ix_dcn = 1; delta_ix_in = 1000; nx = 5; nrepeat = 4; ix_max_prev = 100;
            
            [ix_beg, delta_ix, ix_min, ix_max] = exposed_IX_map.resolve_repeat_blocks ...
                (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat, ix_max_prev);
            assertEqual ([ix_beg, delta_ix, ix_min, ix_max], [101, 1000, 101, 3105])
        end
        
        %-----------------------------------------------------------------------
        function test_ix_beg_NaN_ix_max_prev_Missing_ERROR (~)
            % ix_beg_in a placeholder - uses ix_max_prev, so throws an error if
            % not given
            ix_beg_in = NaN; ix_dcn = 1; delta_ix_in = 1000; nx = 5; nrepeat = 4;
            
            func = @()exposed_IX_map.resolve_repeat_blocks ...
                (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat);
            ME = assertExceptionThrown (func, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, 'Must provide ''ix_max_prev'''))
        end
        
        %-----------------------------------------------------------------------
        function test_ix_beg_NaN_ix_dcn_Neg (~)
            % ix_beg_in a placeholder - uses ix_max_prev; now ix_dcn -ve
            ix_beg_in = NaN; ix_dcn = -1; delta_ix_in = 5; nx = 10; nrepeat = 4; ix_max_prev = 50;
            
            [ix_beg, delta_ix, ix_min, ix_max] = exposed_IX_map.resolve_repeat_blocks ...
                (ix_beg_in, ix_dcn, delta_ix_in, nx, nrepeat, ix_max_prev);
            assertEqual ([ix_beg, delta_ix, ix_min, ix_max], [60, 5, 51, 75])
        end
        
        %-----------------------------------------------------------------------
    end
end
