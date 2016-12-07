classdef faccess_sqw_v3 < sqw_binfile_common
    % Class to access Horace binary files written in binary format v3.1
    % which stores the description of all Horace sqw fields at the end of a
    % binary file. May contain instrument and sample information.
    %
    %
    % Usage:
    %1)
    %>>sqw_access = faccess_sqw_v3(filename)
    % or
    % 2)
    %>>sqw_access = faccess_sqw_v3(sqw_dnd_object,filename)
    %
    % 1)
    % First form initializes accessor to existing sqw file where
    % @param filename  :: the name of existing sqw file written
    %                     in sqw v3.1 format.
    %
    % Throws if file with filename is missing or is not written in
    % sqw v3.1 format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw file,
    % access to existing sqw files should be organized using sqw
    % formats factory namely:
    %
    % >>accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is sqw v3.1 sqw file, the sqw format
    % factory will return instance of this class, initialized for
    % reading this file.
    % The initialized object allows to use all get/read methods described
    % by sqw_file_interface,
    % dnd_file_interface and additional methods to read instrument and
    % sample, specific for v3.1 file format.
    %
    % 2)
    % Second form used to initialize the operation of writing new or
    % updating existing sqw file.
    % where:
    %@param sqw_dnd_object:: existing fully initialized sqw object in memory.
    %@param filename      :: the name of a new or existing sqw object on disc
    %
    % Update mode is initialized if the file with name filename exists and
    % can be updated, i.e. has the same number of dimensions, binning axis
    % and pixels.
    % In this case you can modify dnd or sqw methadata or explicitly
    % overwrite pixels.
    %
    % If existing file can not be updated, it will be open in write mode.
    % If file with filename does not exist, the object will be open in write mode.
    %
    % Initialized faccess_sqw_v3 object allows to use write/update methods of
    % dnd_file_interface, sqw_file_interface + writing instrument and sample
    % and all read methods of these interfaces if the proper information
    % already exists in the file.
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
    %
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
            obj = obj.init_v3_specific();
        end
        %
        function flds = fields_to_save(obj)
            % returns the fields to save in the structure in sqw binfile v3 format
            head_flds = fields_to_save@sqw_binfile_common(obj);
            flds = [head_flds(:);obj.data_fields_to_save_(:)];
        end
        %
        function obj = put_footer(obj)
            % store file footer i.e. the information, describing the file
            % format
            obj = put_sqw_footer_(obj);
        end
        %
        function obj = init_v3_specific(obj)
            % Initialize position information specific for sqw v3.1 object.
            %
            % Used by this class init and faccess_sqw_v2&similar for
            % upgrading to v3.1
            obj = init_sample_instr_records_(obj);
            %
            obj.position_info_pos_= obj.instr_sample_end_pos_;
            obj = init_sqw_footer_(obj);
        end
        %
        function [obj,missinig_fields] = copy_contents(obj,other_obj,keep_internals)
            % the main part of the copy constructor, copying the contents
            % of the one class into another.
            %
            % Copied of dnd_binfile_common to support overloading as
            % private properties are not accessible from parents
            %
            % keep_internals -- if true, do not overwrite service fields
            %                   not related to the position information
            %
            if ~exist('keep_internals','var')
                keep_internals = false;
            end
            [obj,missinig_fields] = copy_contents_(obj,other_obj,keep_internals);
        end
        
    end
    %
    properties(Constant,Access=private)
        % list of fileldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        data_fields_to_save_ = {'instrument_head_pos_','instrument_pos_',...
            'sample_head_pos_','sample_pos_','instr_sample_end_pos_'};
        v3_data_form_ = field_generic_class_hv3();
    end
    %
    methods
        % get data header
        head = get_header(obj,varargin);
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
            %>>inst = obj.get_sample(number)
            % Returns first instrument with number, specified
            %>>inst = obj.get_sample('-all')
            % returns array of samples if they are different or
            % single sample if they are the same.
            %
            [samp,obj] = get_instr_or_sample_(obj,'sample',varargin{:});
        end
        % return structure, containing position of every data field in the
        % file (when object is initialized). Here due to bug in Matlab
        % inheritance chain
        pos_info = get_pos_info(obj)
        %
        function obj = put_instruments(obj,varargin)
            % store or change instrument information in the file
            %
            % causes storing of sample and footer information too
            %
            % identical to put_instruments method, except a non-sqw class
            % or structure or array of such objects assumed to be a sample
            %Usage:
            % obj = obj.put_instruments() % store instrument information attached to
            %                  sqw - object the class has been initated
            %                  with, or empty sample information if no sqw
            %                  object was attached
            % obj = obj.put_instruments(some_object) % store some object
            %     as instrument. The numel(some_object)
            %     has to be 1 or equal to number of the contributing files,
            %     the sqw file has.
            % obj = obj.put_instruments('instrument',some_object,'sample',other_object) % store
            %     instrument and sample information. Equivalent to
            %     obj.put_samples with similar parameters.
            % obj = obj.put_instruments(sqw_object) % store instrument and
            %       sample information using sqw_object provided as the source of
            %       this information.
            %
            obj = put_is_info_(obj,'instrument',varargin{:});
        end
        %
        function obj = put_samples(obj,varargin)
            % Store or change sample information in the file
            %
            % Causes storing of instrument and footer information too.
            %
            % identical to put_instruments method, except a non-sqw class
            % or structure or array of such objects assumed to be a sample
            %Usage:
            % obj = obj.put_samples() % store sample information attached to
            %                  sqw - object the class has been initated
            %                  with, or empty sample information if no sqw
            %                  object was identified
            % obj = obj.put_samples(some_object) % store some object
            %     as sample. The numel(some_object)
            %     has to be 1 or equal to number of the contributing files,
            %     the sqw file has.
            % obj = obj.put_samples('instrument',some_object,'sample',other_object) % store
            %     instrument and sample information. Equivalent to
            %     obj.put_instruments with similar parameters.
            % obj = obj.put_samples(sqw_object) % store instrument and
            %       sample information using sqw_object provided as the source of
            %       this information.
            %
            obj = put_is_info_(obj,'sample',varargin{:});
        end
        %
        function obj = upgrade_file_format(obj)
            % this is currently (01/01/2017) recent file format.
            % Just reopen for writing
            if ~isempty(obj.filename)
                obj = obj.reopen_to_write();
            end
        end
        %
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
            % returns the format used to save/restore instrument or sample
            % information
            form = faccess_sqw_v3.v3_data_form_;
        end
        
    end
end
