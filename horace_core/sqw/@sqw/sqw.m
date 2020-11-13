classdef sqw < SQWDnDBase

    %SQW_NEW reate an sqw object
    %
    % Syntax:
    %   >> w = sqw (filename)       % Create an sqw object from a file
    %   >> w = sqw (sqw_object)     % Create a new SQW object from a existing one
    %   >> w = sqw (struct)         % Create from a structure with valid fields
    %   >> w = sqw ()               % Create a default, zero-dimensional SQW object

    properties
        main_header
        header
        detpar
        data
    end

    methods
        function obj = sqw(varargin)
            % Constructors
            % i) struct
            % ii) filename
            % iii) copy
            obj = obj@SQWDnDBase();

            [args] = obj.parse_args(varargin{:});

            % i) copy
            if ~isempty(args.sqw_obj)
               obj = copy(args.sqw_obj);

            % ii) filename
            elseif ~isempty(args.filename)
               obj = obj.init_from_file(args.filename);

            % iii) struct
            elseif ~isempty(args.data_struct)
                obj = obj.init_from_loader_struct(args.data_struct);
            end
        end
    end

    methods (Static, Access = 'private')
        % Signatures of private functions declared in files
        sqw_struct = make_sqw(ndims);
        detpar_struct = make_sqw_detpar();
        header = make_sqw_header();
        main_header = make_sqw_main_header();

        function args = parse_args(varargin)
            % Parse a single argument passed to the SQW constructor
            %
            % Return struct with the data set to the appropriate element:
            % args.filename  % string, presumed to be filename
            % args.sqw_obj   % SQW class instance
            % args.data_struct % generic struct, presumed to represent SQW
            parser = inputParser();
            parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || is_string(x) || isstruct(x)));
            parser.KeepUnmatched = true;
            parser.parse(varargin{:});

            input = parser.Results.input;
            args = struct('sqw_obj', [], 'filename', [], 'data_struct', []);

            if isa(input, 'SQWDnDBase')
                if isa(input, 'DnDBase')
                    error('SQW:sqw', 'SQW cannot be constructed from a DnD object');
                end
                args.sqw_obj = input;
            elseif is_string(parser.Results.input)
                args.filename = input;
            elseif isstruct(input) && ~isempty(input)
                args.data_struct = input;
            else
                % create struct holding default instance
                args.data_struct = make_sqw(0);
            end
        end
    end

    methods (Access = 'private')
        function obj = init_from_file(obj, in_filename)
            % Parse SQW from file
            %
            % An error is raised if the data file is identified not a SQW object
            ldr = sqw_formats_factory.instance().get_loader(in_filename);
            if ~strcmpi(ldr.data_type,'a')   % not a valid sqw-type structure
                error('SQW:sqw', 'Data file does not contain valid sqw-type object');
            end

            w=struct();
            [w.main_header, w.header, w.detpar, w.data] = ldr.get_sqw('-legacy');
            obj = obj.init_from_loader_struct(w);
        end

        function obj = init_from_loader_struct(obj, data_struct)
            obj.main_header = data_struct.main_header;
            obj.header = data_struct.header;
            obj.detpar = data_struct.detpar;
            obj.data = data_struct.data;
        end
    end
end

