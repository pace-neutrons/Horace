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
        [sqwobj,obj] = get_sqw(obj,varargin)
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
        obj = put_sqw(obj,varargin);
        obj = put_instruments(obj,varargin);
        obj = put_samples(obj,varargin);

    end
    methods
    end
    %======================================================================
    % Old, partially redundant interface
    methods
        % -----------------------------------------------------------------
        function img_db_range = get_img_db_range(obj,varargin)
            % get [2x4] array of min/max ranges of the image where pixels
            % are rebinned into
            ds = obj.get_dnd_metadata();
            img_db_range  = ds.axes.img_range;
        end
        function [data_str,obj] = get_se_npix(obj,varargin)
            % get only dnd image data, namely s, err and npix
            data_dnd = obj.get_dnd_data(varargin{:});
            data_str = struct('s',data_dnd.sig,'e',data_dnd.err, ...
                'npix',data_dnd.npix);
        end
    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        function obj = do_class_dependent_updates(obj,old_ldr,varargin)
            % function does nothing as this is recent file format
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
                mh = obj.get_main_header();
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
        %
        function  obj=init_from_sqw_obj(obj,varargin)
            % initalize faccessor using sqw object as input
            %
            % initialize binfile_v4 interface
            obj = init_from_sqw_obj@binfile_v4_common(obj,varargin{:});
            % intialize sqw_file_interface.
            % sqw holder now contains sqw object by definition
            obj.num_contrib_files_ = obj.sqw_holder.main_header.nfiles;
            obj.npixels_           = obj.sqw_holder.npixels;
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
            npix_bl = obj.bat_.blocks_list{end-1}; % block responsible for pix metadata;
            [~,pix_md] = npix_bl.get_sqw_block(obj.file_id_);
            obj.npixels_          = pix_md.npix;
        end

    end
    %======================================================================
    % SERIALIZABLE INTERFACE FULLY INHERITED FROM binfile_v4_common
end