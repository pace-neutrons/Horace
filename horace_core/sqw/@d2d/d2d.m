classdef d2d < DnDBase
    %D2D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d2d()               % Create a default, zero-dimensional SQW object
    %   >> w = d2d(struct)         % Create from a structure with valid fields (internal use)


    methods
        function obj = d2d(varargin)
            obj = obj@DnDBase(varargin{:});
            [args] = obj.parse_args(varargin{:});


            % ii) struct
            if ~isempty(args.data_struct)
                obj = obj.init_from_loader_struct(args.data_struct);
            end
        end
    end

    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1,w2,binary_op);
    end

    methods(Static, Access = private)

        function args = parse_args(varargin)
            % Parse a single argument passed to the SQW constructor
            %
            % Return struct with the data set to the appropriate element:
            % args.filename  % string, presumed to be filename
            % args.sqw_obj   % D2D class instance
            % args.data_struct % generic struct, presumed to represent D2D
            parser = inputParser();
            parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || is_string(x) || isstruct(x)));
            parser.KeepUnmatched = true;
            parser.parse(varargin{:});

            input = parser.Results.input;
            args = struct('dnd_obj', [], 'filename', [], 'data_struct', []);

            if isa(input, 'SQWDnDBase')
                if ~isa(input, 'd2d') % relax this in future updates
                    error('D2D:d2d', 'D2D cannot be constructed from a non-D2D object');
                end
                args.dnd_obj = input;
            elseif is_string(parser.Results.input)
                args.filename = input;
            elseif isstruct(input) && ~isempty(input)
                args.data_struct = input;
            else
                % create struct holding default instance
                args.data_struct = data_sqw_dnd(2);
            end
        end
    end

    methods(Access = 'private')
        function obj = init_from_loader_struct(obj, data_struct)
            obj.data = data_struct;
        end
    end
end
