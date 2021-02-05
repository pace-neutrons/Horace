classdef faccess_sqw_v3_3 < faccess_sqw_v3
    % Class to access Horace binary files written in binary format v3.3
    % The format differs from 3.1 format as efixed can contain range of
    % energies (equal to number of detectors). This format may be necessary
    % for writing results of indirect instruments
    %
    % In addition to that, it distinguish between img_range and pix_range
    % and stores/restores both fields
    %
    % The pix_range is stored in sqw_footer together with the positions of
    % the main data blocks.
    %
    %
    %
    % Usage:
    %1)
    %>>sqw_access = faccess_sqw_v3_3(filename)
    % or
    % 2)
    %>>sqw_access = faccess_sqw_v3_3(sqw_dnd_object,filename)
    %
    % 1)
    % First form initializes accessor to existing sqw file where
    % filename  :: the name of existing sqw file written
    %                     in sqw v3.3 format.
    %
    % Throws if file with filename is missing or is not written in
    % sqw v3.3 format.
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
    % sample, specific for v3.2 file format.
    %
    % 2)
    % Second form used to initialize the operation of writing new or
    % updating existing sqw file.
    % where:
    % sqw_dnd_object:: existing fully initialized sqw object in memory.
    % filename      :: the name of a new or existing sqw object on disc
    %
    % Update mode is initialized if the file with name filename exists and
    % can be updated, i.e. has the same number of dimensions, binning axis
    % and pixels.
    % In this case you can modify dnd or sqw metadata or explicitly
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
    properties(Access=public,Hidden=true)
        % the transient class stores pix range together with the data
        % footer.
        pix_range_ = [];
    end
    properties(Constant,Access=protected,Hidden=true)
        % list of fileldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        fields_to_save_3_3 = {'pix_range_'};
    end
    
    methods
        
        function obj=faccess_sqw_v3_3(varargin)
            % constructor, to build sqw reader/writer version 3
            %
            % Usage:
            % ld = faccess_sqw_v3_3() % initialize empty sqw reader/writer
            %                        version 3.3
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_sqw_v3_3(filename) % initialize sqw reader/writer
            %                       version 3.3
            %                       to load sqw file version 3.3
            %                       Throws error if the file version is not sqw
            %                       version 3.3
            % ld = faccess_sqw_v3_3(sqw_object) % initialize sqw
            %                       reader/writer version 3.3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            % ld = faccess_sqw_v3_3(sqw_object,filename) % initialize sqw
            %                       reader/writer version 3.3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            
            % set up fields, which define appropriate file version
            obj = obj@faccess_sqw_v3();
            obj.file_ver_ = 3.3;
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %
        function has = has_pix_range(~)
            % Returns true when the pix_range is stored within a file.
            has = true;
        end
        function pix_range = get_pix_range(obj)
            % get [2x4] array of min/max ranges of the image contributing
            % into an object
            %
            pix_range = obj.pix_range_;
        end
        %
        function obj = store_pix_range(obj,new_range)
            if any(size(new_range) ~=[2,4])
                error('FACCESS_SQW_V3_3:invalid_argument',...
                    ' Pixels range has to be array of size [2,4]');
            end
            obj.pix_range_ = new_range;
            obj = obj.put_sqw_footer();
        end
        %
        function struc = saveobj(obj)
            % method used to convert object into structure
            % for saving it to disc.
            struc = saveobj@faccess_sqw_v3(obj);
            flds = obj.fields_to_save_3_3;
            for i=1:numel(flds)
                struc.(flds{i}) = obj.(flds{i});
            end
        end
        function obj = upgrade_file_format(obj)
            % upgrade the file to recent write format and open this file
            % for writing/updating
            %
            % v3.3 is currently (10/01/2021) recent file format, so
            % the method just reopens file for update.
            if ~isempty(obj.filename)
                obj = obj.set_file_to_update();
            end
        end
        %-------------------------------------------------------------------
    end
    methods(Access=protected,Hidden=true)
        function flds = fields_to_save(obj)
            % returns the fields to save in the structure in sqw binfile v3 format
            head_flds = fields_to_save@faccess_sqw_v3(obj);
            flds = [head_flds(:);obj.fields_to_save_3_3(:)];
        end
        %
        function obj = init_v3_specific(obj)
            % Initialize position information specific for sqw v3.3 object.
            %
            % Used by this class init and faccess_sqw_v2&similar for
            % upgrading to v3.3
            obj = init_sample_instr_records(obj);
            %
            obj.position_info_pos_= obj.instr_sample_end_pos_;
            %
            data = obj.extract_correct_subobj('data');
            obj.pix_range_ = data.pix.pix_range;            
            num_pix = data.pix.num_pixels;            
            
            if any(any(obj.pix_range_ == PixelData.EMPTY_RANGE_)) && num_pix > 0
                data.pix.recalc_pix_range();
                obj.pix_range_ = data.pix.pix_range;
            end
            obj = init_sqw_footer(obj);
        end
        
        function obj=init_from_structure(obj,obj_structure_from_saveobj)
            % init file accessors using structure, obtained for object
            % serialization (saveobj method);
            obj = init_from_structure@faccess_sqw_v3(obj,obj_structure_from_saveobj);
            %
            flds = obj.fields_to_save_3_3;
            for i=1:numel(flds)
                if isfield(obj_structure_from_saveobj,flds{i})
                    obj.(flds{i}) = obj_structure_from_saveobj.(flds{i});
                end
            end
        end
    end
    %
end
