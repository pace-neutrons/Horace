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
        function obj = loadobj(S)
            % Load a sqw object from a .mat file
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
            obj = d4d(S);
            if isa(S,'d4d')
               obj = S;
               return
            end
            if numel(S)>1
               tmp = d4d();
               obj = repmat(tmp, size(S));
               for i = 1:numel(S)
                   obj(i) = d4d(S(i));
               end
            else
               obj = d4d(S);
            end
        end
    end
end
