classdef d0d < DnDBase
    %D0D Create an zero-dimensional DnD object
    %
    % Syntax:
    %   >> w = d0d()               % Create a default, empty, D0D object
    %   >> w = d0d(filename)       % Create a D0D object from a file
    %   >> w = d0d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
        NUM_DIMS = 0;
    end
    methods
        function obj = d0d(varargin)
            obj = obj@DnDBase(varargin{:});
        end
        
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class. Put it as it is replacing the
            obj = d0d();
            obj = loadobj@serializable(S,obj);
        end
    end
end
