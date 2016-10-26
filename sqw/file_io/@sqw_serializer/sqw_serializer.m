classdef sqw_serializer
    % Helper class to serialize-deserialize sqw object's data
    % using predefined format structures, provided by loader
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Access=private)
        sqw_holder_ = []; % reference to sqw object to serialize (if any)
        n_header_ = 1; % number of header to process
        %
        base_classes_ = {'double','single','int8','uint8','int16','uint16',...
            'int32','uint32','int64','uint64','float64'};
        class_sizes_ =  [8,4,1,1,2,2,4,4,8,8,8]; % in bytes
        class_map_; % map to associate class name and class size
        
        % helper property to calculate size of a structure
        input_is_stuct_= false;
        % helper property to calculate positions of a file
        input_is_file_ = false;
        eof_pos_ = 0;
    end
    properties(Dependent)
        n_header
        input_is_file;
        input_is_struct;
    end
    
    methods
        function obj = sqw_serializer()
            obj.class_map_ = containers.Map(obj.base_classes_,obj.class_sizes_);
        end
        function nh = get.n_header(obj)
            nh = obj.n_header_;
        end
        function obj = set.n_header(obj,val)
            if isnumeric(val) && val>0 && val <999999999
                obj.n_header_ = val;
            else
                error('SQW_SERIALIZER:invalid_argument',...
                    'Number of header to process should be ')
            end
        end
        function is = get.input_is_file(obj)
            is = obj.input_is_file_;
        end
        function is = get.input_is_struct(obj)
            is = obj.input_is_stuct_;
        end
        
        %---------------------------------------------------------------------
        function stream = serialize(obj,struct,format_struct)
            % serialize struct into the form, usually written by Horace
            % and defined by format_struct
            %
            stream = serialize_(obj,struct,format_struct);
        end
        
        function [size_str,pos,eof,template_struc] = calculate_positions(obj,template_struc,input,varargin)
            % calculate the positions, the fields of the input templated_structure
            % occupy in an input stream.
            % Usage:
            % [size_str,pos,eof,template_struc] = obj.calculate_positions(format_struc,input)
            %or
            %[size_str,pos,eof,template_struc] = obj.calculate_positions(format_struc,input,start_pos)
            %
            % where
            % obj           ::  an instance of sqw serializer
            % format_struc  ::  structure with sqw_field_formatters values
            %                   defining the format of the structure to
            %                   save
            % input         ::  input data in various formats to find
            %                   locations of different parts of the data
            % start_pos     ::  if provided, the initial position of the
            %                   data, described  by format_struct. If not
            %                   provided, default is 0 if input/output is a file
            %                   handle or 1 if it is sequence of bytes
            %
            [obj,pos] = calc_pos_check_input_set_defaults_(obj,input,varargin{:});
            %
            [size_str,pos,eof,template_struc] = calculate_positions_(obj,template_struc,input,pos);
            
        end
        %
        function [targ_struc,pos] = deserialize_bytes(obj,input,template_str,varargin)
            % Convert sequence of bytes into structure, using input structure
            % as template to obtain data types and sizes
            %
            % usage:
            % >>[res,pos] =sqw_serializer().deserialize_bytes(input,format_str)
            % or
            % >>[res,pos] =sqw_serializer().deserialize_bytes(input,format_str,pos)
            %
            % input :: either array of bytes or handle to an open binary
            %          file with data
            % template_str :: structure, which describes format of the
            %                 input data in the stream or binary file.
            %         See the examples of various horace format structures
            %         defined by sqw_binfile_common class.  Simple fields of this
            %         structure used to identify the output according to a
            %         simple rule:
            %         the field name of the templated structure defined the
            %         field name of the target structure and the size and the
            %         type of the templated strucute field define size and
            %         the type of the bytes
            %         Complex fields of the templated structure are converted
            %         according to the rules described by
            %         sqw_field_format_interface classes.
            %
            % pos ::  on input defines the position of the first byte of
            %         the data to process within the input stream and
            %         on outuput equal to the  first byte following the
            %         bytes convered into the structure
            % Output:
            % res  :: structure, converted from sequence of bytes
            %
            %
            if size(input,1) == 1
                input = input';
            end
            [targ_struc,pos] = deserialize_bytes_(obj,input,template_str,varargin{:});
        end
        
    end
    
end

