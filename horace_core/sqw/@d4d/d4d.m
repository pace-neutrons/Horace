classdef d4d < DnDBase
    %D4D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d4d()               % Create a default, empty, D4D object
    %   >> w = d4d(sqw)            % Create a D4D object from a 4-dimensional SQW object
    %   >> w = d4d(filename)       % Create a D4D object from a file
    %   >> w = d4d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
        NUM_DIMS = 4;
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class. Put it as it is replacing the
            obj = d4d();
            obj = loadobj@serializable(S,obj);
        end
    end

    methods
        wout = cut (varargin);
        function obj = d4d(varargin)
            obj = obj@DnDBase(varargin{:});
            if nargin==0
                obj.nbins_all_dims = [2,2,2,2];
            end
        end
    end
end
