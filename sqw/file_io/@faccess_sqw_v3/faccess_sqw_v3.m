classdef faccess_sqw_v3 < sqw_binfile_common
    % Class to access Horace bibary files written in v3
    
    properties(Access=protected)
        %
        instrument_pos_=0;
        sample_pos_=0;
        %
        sample_holder_=[];
        instrument_holder_=[];        
        %
        position_info_pos_=0;
        eof_pos_ = 0;
    end
    methods(Access=protected)
        function obj=init_from_sqw_file(obj)
            % intialize the structure of faccess class using opened
            % sqw file as input
            obj= read_sqw_structure_(obj);
        end
        
    end
    
    
    methods
        function obj=faccess_sqw_v3(varargin)
            % constructor, to build sqw reader/writer version 3
            %
            % Usage:
            % ld = faccess_sqw_v3() % initialize empty sqw reader/writer
            %                        version 3
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_sqw_v3(filename) % initialize sqw reader/writer
            %                       version 3
            %                       to load sqw file version 3.
            %                       Throws error if the file version is not sqw
            %                       version 3.
            % ld = faccess_sqw_v3(sqw_object) % initialize sqw
            %                       reader/writer version 3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            %
            obj.file_ver_ = 3;
            obj.sqw_type_ = true;            
            if nargin>0
                obj = obj.init(varargin{:});
            end
            
        end
        %
        %
        function [inst,obj] = get_instrument(obj,varargin)
            % get instrument stored in sqw file
            % Usage:
            %>>inst = obj.get_instrument()
            % Returns first instrument, sroted in the file
            %>>inst = obj.get_instrument(number)
            % Returns instrument with number, specified
            %>>inst = obj.get_instrument('-all')
            % returns array of instruments if they are different or
            % single instrument if they are the same.
            %
            [inst,obj] = get_instr_or_sample_(obj,'instrument',varargin{:});
        end
        %
        function [samp,obj] = get_sample(obj,varargin)
            % get sample stored in sqw file
            % Usage:
            %>>inst = obj.get_sample()
            % Returns first sample, stored in the sqw file
            %>>inst = obj.get_instrument(number)
            % Returns first instrument with number, specified
            %>>inst = obj.get_instrument('-all')
            %
            [samp,obj] = get_instr_or_sample_(obj,'sample',varargin{:});
        end
        
        
    end
end
