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

    methods
        function obj = d3d(varargin)
            obj = obj@DnDBase(varargin{:});
            [args] = obj.parse_args(varargin{:});

            % i) copy
            if ~isempty(args.dnd_obj)
                obj = copy(args.dnd_obj);
            % ii) struct
            elseif ~isempty(args.data_struct)
                obj = obj.init_from_loader_struct(args.data_struct);
            % iii) filename
            elseif ~isempty(args.filename)
                obj = obj.init_from_file(args.filename);
            % iv) from sqw
            elseif ~isempty(args.sqw_obj)
                obj = obj.init_from_sqw(args.sqw_obj);
            end
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
        %               obj = sqw(S);
        %        end
    end
end
