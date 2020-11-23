classdef d2d < DnDBase
    %D2D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d2d ()               % Create a default, zero-dimensional SQW object
    %   >> w = d2d (struct)         % Create from a structure with valid fields (internal use)

    methods
        function obj = d2d(varargin)
            obj = obj@DnDBase(varargin{:});
            [args] = obj.parse_args(varargin{:});
        end
    end

    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1,w2,binary_op);
    end

    methods(Static, Access = private)
        function args = parse_args(varargin)
            args = [];
        end
    end
end
