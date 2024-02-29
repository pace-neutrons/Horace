classdef exposed_IX_map < IX_map
    % Class to expose protected methods of IX_map that in turn access
    % private methods and functions of IX_map for the purpose of testing those
    % methods and functions.
    
    methods
        function obj = exposed_IX_map()
            obj@IX_map()
        end
    end
    
    methods (Static)
        function [wkno_out, ns_out, s_out] = repeat_s_w_arrays (varargin)
            [wkno_out, ns_out, s_out] = test_repeat_s_w_arrays (IX_map(), varargin{:});
        end
        
        function [wkno_out, ns_out, s_out] = repeat_s_w_blocks (varargin)
            [wkno_out, ns_out, s_out] = test_repeat_s_w_blocks (IX_map(), varargin{:});
        end
        
        function [ix_beg, delta_ix, ix_min, ix_max] = resolve_repeat_blocks (varargin)
            [ix_beg, delta_ix, ix_min, ix_max] = test_resolve_repeat_blocks ...
                (IX_map(), varargin{:});
        end
    end
    
end
