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

    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1,w2,binary_op);
    end

    methods(Static, Access = private)

        function args = parse_args(varargin)
            % Parse a single argument passed to the D2D constructor
            %
            % Return struct with the data set to the appropriate element:
            % args.filename  % string, presumed to be filename
            % args.dnd_obj   % D2D class instance
            % args.sqw_obj   % SQW class instance
            % args.data_struct % generic struct, presumed to represent D2D
            parser = inputParser();
            parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || is_string(x) || isstruct(x)));
            parser.KeepUnmatched = true;
            parser.parse(varargin{:});

            input = parser.Results.input;
            args = struct('dnd_obj', [], 'sqw_obj', [], 'filename', [], 'data_struct', []);

            if isa(input, 'SQWDnDBase')
                if isa(input, 'd2d')
                    args.dnd_obj = input;
                elseif isa(input, 'sqw')
                    args.sqw_obj = input;
                else
                    error('D2D:d2d', ...
                        ['D2D cannot be constructed from an instance of this object "' class(input) '"']);
                end
            elseif is_string(parser.Results.input)
                args.filename = input;
            elseif isstruct(input) && ~isempty(input)
                args.data_struct = input;
            else
                % create struct holding default instance
                args.data_struct = data_sqw_dnd(d2d.NUM_DIMS);
            end
        end
    end

    methods(Access = 'private')
        function obj = init_from_loader_struct(obj, data_struct)
            obj.data = data_struct;
        end

        function obj = init_from_sqw(obj, sqw_obj)
            sqw_dim = sqw_obj.dimensions();
            if sqw_dim ~= d2d.NUM_DIMS
                error('D2D:d2d', 'SQW object cannot be converted to a 2d dnd-type object');
            end
            obj.data = sqw_obj.data;
        end

        function obj = init_from_file(obj, in_filename)
            % Parse DnD from file
            %
            % An error is raised if the data file is identified not a D2D object
            ldr = sqw_formats_factory.instance().get_loader(in_filename);
            if ~strcmpi(ldr.data_type, 'b+') % not a valid dnd-type structure
                error('D2D:d2d', 'Data file does not contain valid dnd-type object');
            end
            if ldr.num_dim ~= d2d.NUM_DIMS
                error('D2D:d2d', 'Data file does not contain 2d dnd-type object');
            end

            [~, ~, ~, dnd_data] = ldr.get_dnd('-legacy');
            obj = obj.init_from_loader_struct(dnd_data);
        end
    end
end
