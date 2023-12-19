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
        function [is_out, iw_out] = repeat_s_w_arrays (varargin)
            [is_out, iw_out] = test_repeat_s_w_arrays (IX_map(), varargin{:});
        end
        
        function [is_out, iw_out] = repeat_s_w_blocks (varargin)
            [is_out, iw_out] = test_repeat_s_w_blocks (IX_map(), varargin{:});
        end
        
        function [iw_beg, delta_iw, iw_min, iw_max] = resolve_repeat_blocks (varargin)
            [iw_beg, delta_iw, iw_min, iw_max] = test_resolve_repeat_blocks ...
                (IX_map(), varargin{:});
        end
    end
    
end
