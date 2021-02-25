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
            obj = d0d(S);
            if isa(S,'d0d')
               obj = S;
               return
            end
            if numel(S)>1
               tmp = d0d();
               obj = repmat(tmp, size(S));
               for i = 1:numel(S)
                   obj(i) = d0d(S(i));
               end
            else
               obj = d0d(S);
            end
        end
    end
end
