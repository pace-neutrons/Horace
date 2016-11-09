classdef faccess_sqw_v3 < sqw_binfile_common
    % Class to access Horace bibary files written in binary format v3
    % which contains the description of all Horace fields at the end of the
    % file.
    %
    %
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Access=protected)
        %
        instrument_head_pos_ = 0;
        instrument_pos_      = 0;
        sample_head_pos_     = 0;
        sample_pos_          = 0;
        instr_sample_end_pos_= 0;
        %
        position_info_pos_   = 0;
        %
        eof_pos_ = 0;
    end
    methods(Access=protected)
        function obj=init_from_sqw_file(obj)
            % intialize the structure of faccess class using opened
            % sqw file as input
            obj= get_sqw_footer_(obj);
        end
        %
        function obj=init_from_sqw_obj(obj,varargin)
            % intialize the structure of faccess class using opened
            % sqw file as input
            obj = init_from_sqw_obj@sqw_binfile_common(obj,varargin{:});
            %
            obj = init_sample_instr_records_(obj);
            %
            obj.position_info_pos_= obj.instr_sample_end_pos_;
            obj = init_sqw_footer_(obj);
        end
        %
        function flds = fields_to_save(obj)
            % returns the fields to save in the structure in sqw binfile v3 format
            head_flds = fields_to_save@sqw_binfile_common(obj);
            flds = [head_flds(:);obj.data_fields_to_save_(:)];
        end
        
    end
    properties(Constant,Access=private)
        % list of fileldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        data_fields_to_save_ = {'instrument_head_pos_','instrument_pos_',...
            'sample_head_pos_','sample_pos_','instr_sample_end_pos_'};
        v3_data_form_ = field_generic_class_hv3();
    end
    %
    methods
        % Save new or fully overwrite existing sqw file
        obj = put_sqw(obj,varargin);
        %
        
        
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
            % set up fields, which define appropriate file version
            obj.file_ver_ = 3.1;
            obj.sqw_type_ = true;
            if nargin>0
                obj = obj.init(varargin{:});
            end
            
        end
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
        % return structure, containing position of every data field in the
        % file (when object is initialized). Here due to bug in Matlab
        % inheritance chain
        pos_info = get_pos_info(obj)
        
        function obj = put_sample(obj,varargin)
            % store or change sample information in the file
            obj= put_sample_(obj,varargin);
        end
        function new_obj = upgrade_file_format(obj)
            % this is currently (01/01/2017) recent file format. Do nothing
            new_obj = obj;
        end
    end
    %
    methods(Static)
        function form = get_si_head_form(obj_name)
            % describes format of instrument or sample
            % block descriptor, which is written in the beginning of
            % instrument or sample block and describes the contents and
            % the format of this block
            form = struct('obj_name',obj_name,...
                'version',int32(1),'nfiles',int32(1),'all_same',uint8(1));
        end
        function form = get_si_form(obj_name)
            % returns the format used to save/restopre instrument or sample
            % information
            form = faccess_sqw_v3.v3_data_form_;
        end
        
    end
end
