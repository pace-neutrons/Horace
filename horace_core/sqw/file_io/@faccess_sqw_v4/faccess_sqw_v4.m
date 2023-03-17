classdef faccess_sqw_v4 < binfile_v4_common & sqw_file_interface
    % Class to access Horace dnd files written by Horace v4
    %
    % Main of class properties and methods are inherited from
    % <a href="matlab:help('binfile_v4_common');">binfile_v4_common</a>
    % class but this class provides classical faccess interface.
    %
    % Usage:
    % 1)
    %>>dnd_access = faccess_dnd_v4(filename)
    % or
    % 2)
    %>>dnd_access = faccess_dnd_v4(sqw_dnd_object,filename)
    %---------------------------------------------------------------
    %
    % 1)------------------------------------------------------------
    % First form initializes accessor to existing dnd file where
    % filename  :: the name of existing dnd file.
    %
    % Throws if file with filename is missing or is not written in dnd v4
    % format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw file,
    % access to existing sqw files should be organized using sqw format factory
    % namely:
    %
    % >> accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is dnd v1 or v2 sqw file, the sqw format factory will
    % return instance of this class, initialized for reading the file.
    % The initialized object allows to use all get/read methods described by horace_binfile_interface.
    %
    % 2)------------------------------------------------------------
    % Second form used to initialize the operation of writing new or updating existing dnd file.
    % where:
    % sqw_dnd_object:: existing fully initialized sqw or dnd object in memory.
    % filename      :: the name of a new or existing dnd object on disc
    %
    % Update mode is initialized if the file with name filename exists and can be updated,
    % i.e. has the same number of dimensions, binning and  axis. In this case you can modify
    % dnd metadata.
    %
    % if existing file can not be updated, it will be open in write mode.
    % If file with filename does not exist, the object will be open in write mode.
    %
    % Initialized faccess_dnd_v4 object allows to use write/update methods of dnd_format_interface
    % and all read methods if the proper information already exists in the file.
    %
    %
    %
    properties(Constant,Access=protected)
        % list of data blocks, this class maintains
        sqw_blocks_list_ = {data_block('','main_header'),...
            data_block('','detpar'),...
            data_block('data','metadata'),dnd_data_block(),...
            data_block('experiment_info','instruments'),...
            data_block('experiment_info','samples'),...
            data_block('experiment_info','expdata'),...
            data_block('pix','metadata'),pix_data_block()}
    end
    properties(Dependent)
        % return the number of fields, pixel data stored on hdd have
        num_pix_fields
    end
    properties(Access=private)
        clear_caches_ = true;
    end
    %======================================================================
    % ACCESSORS & constructor
    methods
        function obj=faccess_sqw_v4(varargin)
            % constructor, to build sqw reader/writer version 4
            %
            % Usage:
            % ld = faccess_sqw_v4() % initialize empty sqw reader/writer
            %                       version 4.
            %                       The class should be initialized later
            %                       using init method
            % ld = faccess_sqw_v4(filename) % initialize sqw reader/writer
            %                       version 4  to load sqw file version 4.
            %                       Throw error if the file version is not
            %                       sqw version 4.
            % ld = faccess_sqw_v4(dnd_object,[filename]) % initialize sqw
            %                       reader/writer version 4
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately or as the second
            %                       argument of the constructor in this
            %                       form.
            %
            obj = obj@binfile_v4_common(varargin{:});
        end
        %
        function npf = get.num_pix_fields(~)
            npf = 9;
            % THIS ALL FOR THE FUTURE DIFFERENT PIX FORMAT
            %             persistent mbb_cache;
            %             if obj.clear_caches_
            %                 mbb_cache = [];
            %             end
            %             if isempty(mbb_cache)
            %                 if obj.bat_.initialized
            %                     mbb_cache = obj.get_sqw_block('bl_pix_metadata');
            %                     npf = mbb_cache.num_pix_fields;
            %                 else
            %                     npf = 9; % default number of num_pix_fields
            %                 end
            %             else
            %                 npf = mbb_cache.num_pix_fields;
            %             end
        end
    end
    %======================================================================
    % Main interface
    methods
        function [obj,file_exist,old_ldr] = set_file_to_update(obj,filename)
            % open existing file for update its format and/or data blocks
            % stored in it.
            % Inputs:
            %
            if ~exist('filename','var')
                filename = obj.full_filename;
            end
            [obj,file_exist,old_ldr] = set_file_to_update@horace_binfile_interface(obj,filename,nargout);
            if ~old_ldr.sqw_type
                error('HORACE:faccess_sqw_v4:invalid_argument', ...
                    'Can not update file %s containing dnd object using sqw accessor', ...
                    filename)
            end
        end
        %==================================================================
        % retrieve the whole or partial sqw object from properly initialized sqw file
        [sqwobj,varargout] = get_sqw(obj,varargin)
        [mn_hdr,obj] = get_main_header(obj,varargin);
        [expinf,obj] = get_exp_info(obj,varargin);
        [detpar,obj] = get_detpar(obj,varargin);
        [pix,obj]    = get_pix(obj,varargin);
        [pix,obj]    = get_raw_pix(obj,varargin);
        % read pixels at the given indices
        pix         = get_pix_at_indices(obj,indices);
        % read pixels in the given index ranges
        pix         = get_pix_in_ranges(obj,pix_starts,pix_ends,skip_validation,keep_precision);
        %------------------------------------------------------------------
        [pix_range,obj]   = get_pix_range(obj,varargin)
        [dat_range,obj]   = get_data_range(obj,varargin)
        [samp,obj]  = get_sample(obj,varargin)
        [inst,obj]  = get_instrument(obj,varargin)
        %==================================================================
        % common write interface for v4
        obj = put_main_header(obj,varargin);
        obj = put_headers(obj,varargin);
        obj = put_det_info(obj,varargin);
        obj = put_pix(obj,varargin);
        obj = put_raw_pix(obj,pix_data,pix_idx,varargin);
        obj = put_num_pixels(obj,num_pixels);
        obj = put_sqw(obj,varargin);
        %
        obj = put_instruments(obj,varargin);
        obj = put_samples(obj,varargin);
        obj = put_pix_metadata(ob,pix_class)
    end
    %======================================================================
    % Old, interface
    methods
        function hd = head(obj,varargin)
            % Return the information, which describes sqw file in a standard form
            %
            [ok,mess,full_data] = parse_char_options(varargin,'-full');
            if ~ok
                error('HORACE:sqw_binfile_common:invalid_argument',mess);
            end
            hd =head@binfile_v4_common(obj,varargin{:});

            hd = obj.shuffle_fields_form_sqw_head(hd,full_data);
        end

        % -----------------------------------------------------------------
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        % Given initialized sqw object in memory, initialized BAT and sqw file
        % written in old file format, write everything in memory to proper places
        % in file keeping pixels data on their original place.
        obj = update_sqw_keep_pix(obj)

        function npix = get_npixels(obj)
            pix_data_bl = obj.bat_.blocks_list{end};
            npix =  pix_data_bl.npixels;
        end
        function [obj,missinig_fields] = copy_contents(obj,other_obj,varargin)
            % Copy infromation, relevant to new file format from the old file format
            [obj,missinig_fields] = copy_contents@binfile_v4_common(obj,other_obj,varargin{:});
            if ~PixelDataBase.do_filebacked(other_obj.npixels)
                return;
            end
            % Fix and freeze the position of the pixels data block
            pix_data_block = obj.bat_.get_data_block('bl_pix_data_wrap');
            pix_data_block.pix_position = other_obj.pix_position;
            % this defines the block size
            pix_data_block.npixels      = other_obj.npixels;
            % allocate space in new data block
            obj.bat_ = obj.bat_.set_data_block(pix_data_block);
            sqw_obj = other_obj.get_sqw('-norange');
            mh = sqw_obj.main_header;
            if ~mh.creation_date_defined
                sqw_obj.creation_date = datetime('now');
            end

            % build data range as if it has not been stored with
            % majority of old data files
            %
            missing_range = sqw_obj.pix.data_range == PixelDataBase.EMPTY_RANGE;
            if any(missing_range(:))
                hc = hor_config;
                log_level = hc.log_level;
                %log_level = config_store.instance().get_value('hor_config','log_level');
                if log_level > 0
                    fprintf(2,['*** Recalculating actual data range missing in file %s:\n', ...
                        '*** This is one-off operation occuring during upgrade from file format version %d to file format version %d\n',...
                        '*** Do not interrupt this operation after the page count completeon, as the input data file may become corrupted\n'],...
                        obj.full_filename,other_obj.faccess_version,obj.faccess_version);
                end
                [pix,unique_pix_id] = sqw_obj.pix.recalc_data_range();
                sqw_obj.pix = pix;
                sqw_obj = update_pixels_run_id(sqw_obj,unique_pix_id);
            end
            % define number of confrinuting files, which is stored in sqw
            % object header, but necessary for sqw_file_interface (not any
            % more but historically to be able to recover headers)
            obj.num_contrib_files_ = sqw_obj.main_header.nfiles;

            % as pix data block position already allocated,
            obj.bat_ = obj.bat_.init_obj_info(sqw_obj,'-insert');
            obj.sqw_holder_ = sqw_obj;
            missinig_fields = 'data_in_memory_write_result';
        end
        function obj = do_class_dependent_updates(obj,~,varargin)
            % function does nothing as this is recent file format
            % should not be actually called as the call checks for recent
            % format, but overloaded just in case.
        end

        function  dt = get_data_type(~)
            % overloadable accessor for the class datatype function
            dt  = 'a';
        end
        function bll = get_data_blocks(~)
            % Return list of data blocks, defined on this class
            % main bat of data_blocks getter. Protected for possibility to
            % overload
            bll = faccess_sqw_v4.sqw_blocks_list_;
        end
        function is_sqw = get_sqw_type(~)
            % Main part of get.sqw_type accessor
            % return true if the loader is intended for processing sqw file
            % format and false otherwise
            is_sqw = true;
        end
        %
        function   obj_type = get_format_for_object(~)
            % main part of the format_for_object getter, specifying for
            % what class saving the file format is intended
            obj_type = 'sqw';
        end
        function cd = get_creation_date(obj)
            % main accessor for creation date for sqw object
            % The creation data is defined in main header
            %
            if obj.bat_.initialized
                if ~isempty(obj.sqw_holder)
                    if isa(obj.sqw_holder,'sqw') || is_sqw_struct(obj.sqw_holder)
                        mh = obj.sqw_holder.main_header;
                    elseif isa(obj.sqw_holder,"DnDBase")
                        mh = obj.sqw_holder;
                    else
                        mh = obj.get_main_header();
                    end
                else
                    mh = obj.get_main_header();
                end
                cd = mh.creation_date;
            else
                cd = get_creation_date@binfile_v4_common(obj);
            end
        end
        function  pos = get_pix_position(obj)
            pix_block = obj.bat_.blocks_list{end};
            % pix
            pos = pix_block.pix_position;
        end
        function  npix = get_npix(obj)
            pix_data_bl = obj.bat_.blocks_list{end-1}; % block responsible for pix metadata;
            npix = pix_data_bl.npix;
        end
        %
        function  obj=init_from_sqw_obj(obj,varargin)
            % initalize faccessor using sqw object as input
            %
            % initialize binfile_v4 interface
            obj = init_from_sqw_obj@binfile_v4_common(obj,varargin{:});
            % intialize sqw_file_interface.
            % sqw holder now contains sqw object by definition
            obj.num_contrib_files_ = obj.sqw_holder.main_header.nfiles;
        end
        function  obj=init_from_sqw_file(obj,varargin)
            % initalize faccessor using sqw file as input
            %
            % initialize binfile_v4 interface
            obj = init_from_sqw_file@binfile_v4_common(obj,varargin{:});
            % intialize sqw_file_interface.
            nfil_bl = obj.bat_.blocks_list{1}; % block responsible for main header
            [~,mhb] = nfil_bl.get_sqw_block(obj.file_id_);
            obj.num_contrib_files_ = mhb.nfiles;
        end

    end
    %======================================================================
    % SERIALIZABLE INTERFACE MAINLY INHERITED FROM binfile_v4_common
    %======================================================================
    methods
        function flds = saveableFields(obj)
            flds = saveableFields@binfile_v4_common(obj);
            flds = [flds(:)','num_contrib_files'];
        end
    end
end
