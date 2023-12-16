classdef test_resolve_w_range < TestCase
    % Test resolving placeholder values for iw_beg and delta_w, and getting the
    % range of the output workspaces for the repeated blocks of spectra
    
    methods
        %-----------------------------------------------------------------------
        function test_1 (~)
            % delta_w_in a placeholder - needs to set from nw
            iw_beg_in = 11; iw_dcn = 1; delta_w_in = NaN; nw = 5; nrepeat = 4; iw_max_prev = 50;
            
            val = wrapped_resolve_w_range (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual (val, [11, 5, 11, 30])
        end
        
        %-----------------------------------------------------------------------
        function test_1b (~)
            % delta_w_in a placeholder - needs to set from nw; now iw_dcn -ve
            iw_beg_in = 105; iw_dcn = -1; delta_w_in = NaN; nw = 5; nrepeat = 4; iw_max_prev = 50;
            
            val = wrapped_resolve_w_range (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual (val, [105, 5, 101, 120])
        end
        
        %-----------------------------------------------------------------------
        function test_2 (~)
            % iw_beg_in a placeholder - uses iw_max_prev
            iw_beg_in = NaN; iw_dcn = 1; delta_w_in = 1000; nw = 5; nrepeat = 4; iw_max_prev = 100;
            
            val = wrapped_resolve_w_range (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual (val, [101, 1000, 101, 3105])
        end
        
        %-----------------------------------------------------------------------
        function test_2b (~)
            % iw_beg_in a placeholder - uses iw_max_prev; now iw_dcn -ve
            iw_beg_in = NaN; iw_dcn = -1; delta_w_in = 5; nw = 10; nrepeat = 4; iw_max_prev = 50;
            
            val = wrapped_resolve_w_range (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev);
            assertEqual (val, [60, 5, 51, 75])
        end
        
        %-----------------------------------------------------------------------
    end
end


%-------------------------------------------------------------------------------
function val = wrapped_resolve_w_range (iw_beg_in, iw_dcn, delta_w_in, nw, nrepeat, iw_max_prev)
% Wrapped function to make testing more compact - take advantage that each
% return argument is a scalar
[iw_beg, delta_w, iw_min, iw_max] = resolve_w_range (iw_beg_in, iw_dcn, ...
    delta_w_in, nw, nrepeat, iw_max_prev);
val = [iw_beg, delta_w, iw_min, iw_max];

end

