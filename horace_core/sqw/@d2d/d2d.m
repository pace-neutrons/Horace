classdef d2d < DnDBase
    %D2D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d2d()               % Create a default, empty, D2D object
    %   >> w = d2d(sqw)            % Create a D2D object from a 2-dimensional SQW object
    %   >> w = d2d(filename)       % Create a D2D object from a file
    %   >> w = d2d(struct)         % Create from a structure with valid fields (internal use)

    properties (Constant, Access = protected)
       NUM_DIMS = 2;
    end

    methods
        function obj = d2d(varargin)
            obj = obj@DnDBase(varargin{:});
        end
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
%            %   obj = d2d(S);
%        end
    end
end
