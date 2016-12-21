classdef sqw_serializer
    % Helper class to serialize-deserialize sqw object's data
    % using predefined format structures, provided by loader
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Access=private,Hidden=true)
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
        % true if serializer is processing a file and the input
        % data for serizliatation/deserizliation are stored in the file
        % defined by input file_id.
        input_is_file;
        % true if input is structure and input (even digital) is serialized
        % directly. If input is neither file nor structure, it must be
        % an array of bytes.
        input_is_struct;
    end
    
    methods
        function obj = sqw_serializer()
            obj.class_map_ = containers.Map(obj.base_classes_,obj.class_sizes_);
        end
        %
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
            %
            % Three types of input are possible:
            % 1) class or structure to serialize
            % 2) array of bytes
            % 3) the handle related to open binary file to read.
            % The method calcuates the positions each input data field
            % would occupy or is occupying (if converted) into/in a/the
            % sequence of  bytes.
            %
            % Usage:
            %>>[size_str,pos,eof,template_struc] = obj.calculate_positions(format_struc,input)
            %or
            %>>[size_str,pos,eof,template_struc] = obj.calculate_positions(format_struc,input,start_pos)
            %
            % where
            % obj           ::  an instance of sqw serializer
            % format_struc  ::  structure with sqw_field_formatters values
            %                   defining the format of the structure to
            %                   save/restore.
            % input         ::  input data in various formats to find
            %                   locations of different parts of the data
            % start_pos     ::  if provided, the initial position of the
            %                   data, described  by format_struct. If not
            %                   provided, default is 0 if input/output is a file
            %                   handle or 1 if it is sequence of bytes
            %
            % Returns:
            % size_str       :: the structure with the names of
            %                   template_structure and values equal to
            %                   calculated positions of these fields in
            %                   stream
            % pos            :: first position after the all data positions
            % eof            :: true when  positions calculated on stream
            %                   and end of a stream reached before all
            %                   format fields were processed. size_str in
            %                   this case contains only the positions of
            %                   the fields which were processed from stream
            % template_struc  :: is the copy of the input format structure with
            %                    appropriate fields values calculated from
            %                    the input stream.
            %
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
            %         See the examples of various Horace format structures
            %         defined by sqw_binfile_common class.  Simple fields of this
            %         structure used to identify the output according to a
            %         simple rule:
            %         the field name of the templated structure defined the
            %         field name of the target structure and the size and the
            %         type of the templated structure field define size and
            %         the type of the bytes
            %         Complex fields of the templated structure are converted
            %         according to the rules described by
            %         sqw_field_format_interface classes.
            %
            % pos ::  on input defines the position of the first byte of
            %         the data to process within the input stream and
            %         on output equal to the  first byte following the
            %         bytes converted into the structure
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

