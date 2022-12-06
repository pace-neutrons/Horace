classdef d0d < DnDBase
    %D0D Create an zero-dimensional DnD object
    %
    % Syntax:
    %   >> w = d0d()               % Create a default, empty, D0D object
    %   >> w = d0d(filename)       % Create a D0D object from a file
    %   >> w = d0d(struct)         % Create from a structure with valid fields (internal use)

    properties (Dependent,Hidden=true)
        NUM_DIMS;
    end
    methods
        function obj = d0d(varargin)
            obj = obj@DnDBase(varargin{:});
            if nargin == 0
                obj.s_ = 0;
                obj.e_ = 0;
                obj.npix_ = 0;
            end
        end
        %
        function nd = get.NUM_DIMS(~)
            nd =0;
        end
        function [nd, sz] = dimensions(~)
            % overloaded dimensions for special case of d0d object
            nd = 0;
            sz = [1,1];
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
