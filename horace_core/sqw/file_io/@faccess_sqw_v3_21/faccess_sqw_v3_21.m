classdef faccess_sqw_v3_21 < faccess_sqw_v3_2
    % Class to access Horace binary files written in binary format v3.21
    % The format differs from 3.2 as it contains pixel range stored within
    % the footer, similarly to sqw_v3_3 but for indirect instrument
    %
    %
    % Usage:
    %1)
    %>>sqw_access = faccess_sqw_v3_21(filename)
    % or
    % 2)
    %>>sqw_access = faccess_sqw_v3_21(sqw_dnd_object,filename)
    %
    % 1)
    % First form initializes accessor to existing sqw file where
    % filename  :: the name of existing sqw file written
    %                     in sqw v3.2 format.
    %
    % Throws if file with filename is missing or is not written in
    % sqw v3.21 format.
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
    %
    %
    properties(Access=public,Hidden=true)
        % the transient class stores pix range together with the data
        % footer.
        pix_range_ = [];
    end
    properties(Constant,Access=protected,Hidden=true)
        % list of field-names to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        fields_to_save_3_21 = {'pix_range_'};
    end

    methods
        %
        %
        function obj=faccess_sqw_v3_21(varargin)
            % constructor, to build sqw reader/writer version 3
            %
            % Usage:
            % ld = faccess_sqw_v3_21() % initialize empty sqw reader/writer
            %                        version 3.21
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_sqw_v3_21(filename) % initialize sqw reader/writer
            %                       version 3.21
            %                       to load sqw file version 3.21
            %                       Throws error if the file version is not sqw
            %                       version 3.2
            % ld = faccess_sqw_v3_21(sqw_object) % initialize sqw
            %                       reader/writer version 3.21
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            % ld = faccess_sqw_v3_21(sqw_object,filename) % initialize sqw
            %                       reader/writer version 3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.

            %
            % set up fields, which define appropriate file version
            obj = obj@faccess_sqw_v3_2(varargin{:});
        end

        %
        function obj = upgrade_file_format(obj,varargin)
            % upgrade the file to recent write format and open this file
            % for writing/updating
            %
            % v3.21 is not currently further upgradable. Just reopen the
            % file
            if ~isempty(obj.filename)
                obj = obj.set_file_to_update();
            end
        end
        function pix_range = get_pix_range(obj)
            % get [2x4] array of min/max ranges of the pixels contributing
            % into an object. Empty for DND object
            %
            pix_range = obj.pix_range_;
        end

        %
    end
    methods(Access=protected,Hidden=true)
        function ver = get_faccess_version(~)
            % retrieve sqw-file version the particular loader works with
            ver = 3.21;
        end

        function obj = init_v3_specific(obj)
            % Initialize position information specific for sqw v3.3 object.
            %
            % Used by this class init and faccess_sqw_v2&similar for
            % upgrading to v3.21
            obj = init_sample_instr_records(obj);
            %
            obj.position_info_pos_= obj.instr_sample_end_pos_;
            %
            pix = obj.extract_correct_subobj('pix');
            obj.pix_range_ = pix.pix_range;
            num_pix = pix.num_pixels;

            if any(any(obj.pix_range_ == PixelData.EMPTY_RANGE_)) && num_pix > 0
                pix = pix.recalc_pix_range();
                obj.pix_range_ = pix.pix_range;
            end
            obj = init_sqw_footer(obj);
        end
    end
    %==================================================================
    % SERIALIZABLE INTERFACE
    methods
        function strc = to_bare_struct(obj,varargin)
            base_cont = to_bare_struct@faccess_sqw_v3(obj,varargin{:});
            flds = faccess_sqw_v3_21.fields_to_save_3_21;
            cont = cellfun(@(x)obj.(x),flds,'UniformOutput',false);

            base_flds = fieldnames(base_cont);
            base_cont = struct2cell(base_cont);
            flds  = [base_flds(:);flds(:)];
            cont = [base_cont(:);cont(:)];
            %
            strc = cell2struct(cont,flds);
        end

        function obj=from_bare_struct(obj,indata)
            obj = from_bare_struct@faccess_sqw_v3(obj,indata);
            %
            flds = faccess_sqw_v3_21.fields_to_save_3_21;
            for i=1:numel(flds)
                name = flds{i};
                obj.(name) = indata.(name);
            end
        end
        function flds = saveableFields(obj)
            add_flds = faccess_sqw_v3.fields_to_save_;
            flds = saveableFields@faccess_sqw_v3(obj);
            flds = [flds(:);add_flds(:)];
        end

    end
    methods(Static)
        function obj = loadobj(inputs,varargin)
            inobj = faccess_sqw_v3_21();
            obj = loadobj@serializable(inputs,inobj,varargin{:});
        end
    end
    %
end

