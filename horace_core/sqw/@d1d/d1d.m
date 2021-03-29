classdef d1d < DnDBase
    %D1D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d1d()               % Create a default, empty, D1D object
    %   >> w = d1d(sqw)            % Create a D1D object from a 1-dimensional SQW object
    %   >> w = d1d(filename)       % Create a D1D object from a file
    %   >> w = d1d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
       NUM_DIMS = 1;
    end

    methods(Static)
        %TODO: disabled until full functionality is implemeneted in new class;
        % The addition of this method causes sqw_old tests to incorrectly load data from .mat files
        % as new-DnD class objects
        %        function obj = loadobj(S)
        %            % Load a sqw object from a .mat file
        %            %
        %            %   >> obj = loadobj(S)
        %            %
        %            % Input:
        %            % ------
        %            %   S       An instance of this object or struct
        %            %
        %            % Output:
        %            % -------
        %            %   obj     An instance of this object
        %            %
        %               obj = sqw(S);
        %        end
    end
    
    methods
        wout = cut (varargin);
        function obj = d1d(varargin)
            obj = obj@DnDBase(varargin{:});
        end

    end
end
