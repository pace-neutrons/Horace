classdef d3d < DnDBase
    %D3D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d3d()               % Create a default, empty, D3D object
    %   >> w = d3d(sqw)            % Create a D3D object from a 3-dimensional SQW object
    %   >> w = d3d(filename)       % Create a D3D object from a file
    %   >> w = d3d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
       NUM_DIMS = 3;
    end

    methods(Static)
        function obj = loadobj(S)
            % Load a d3d object from a .mat file
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       An instance of this object or struct
            %
            % -------
            % Output:
            %   obj     An instance of this object
            %obj = d3d(S);
            if isa(S,'d3d')
               obj = S;
               return
            end
            if numel(S)>1
               tmp = d3d();
               obj = repmat(tmp, size(S));
               for i = 1:numel(S)
                   obj(i) = d3d(S(i));
               end
            else
               obj = d3d(S);
            end
        end
    end

    methods
        wout = cut (varargin);
        function obj = d3d(varargin)
            obj = obj@DnDBase(varargin{:});
        end

    end
end
