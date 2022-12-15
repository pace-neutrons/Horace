classdef faccess_dnd_v4 < binfile_v4_common
    % Class to access Horace dnd files written by Horace v4
    %
    % Majority of class properties and methods are inherited from <a href="matlab:help('binfile_v4_common');">binfile_v4_common</a>
    % class.
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
    % Throws if file with filename is missing or is not written in dnd v1-v2 format.
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
    % Initialized faccess_dnd_v2 object allows to use write/update methods of dnd_format_interface
    % and all read methods if the proper information already exists in the file.
    %
    %
    %
    properties(Access=protected)
        % Blocks allocation table
        bat_
    end
    properties(Dependent)
        bat;
    end
    properties(Constant,Access=protected)
        % list of data blocks, this class maintains
        dnd_blocks_list_ = {data_block('data','dnd_metadata'),...
            dnd_data_block()}
    end
    methods
        function obj=faccess_dnd_v4(varargin)
            % constructor, to build sqw reader/writer version 2
            %
            % Usage:
            % ld = faccess_dnd_v4() % initialize empty sqw reader/writer version 2
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_dnd_v4(filename) % initialize sqw reader/writer  version 2
            %                       to load sqw file version 2.
            %                       Throw error if the file version is not sqw
            %                       version 2.
            % ld = faccess_dnd_v4(dnd_object) % initialize sqw reader/writer version 2
            %                       to save dnd object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            %
            if nargin>0
                obj = obj.init(varargin{:}); % call generic init function
            end
        end
        %
        function bt = get.bat(obj)
            bt = obj.bat_;
        end
        %
    end
    %======================================================================
    % Define old interface
    methods
        %
        %---------------------------------------------------------
        [data,obj]  = get_data(obj,varargin); % get whole dnd data without packing these data into dnd object.
        [data_str,obj] = get_se_npix(obj,varargin) % get only dnd image data, namely s, err and npix

        [inst,obj]  = get_instrument(obj,varargin); % return instrument stored with sqw file or empty structure if
        %                                             nothing is stored. Always empty for dnd objects.
        [samp,obj]  = get_sample(obj,varargin);   % return sample stored with sqw file or empty structure if
        %                                           nothing is stored. Always empty for dnd objects.
        [sqw_obj,varargout] = get_sqw(obj,varargin); % retrieve the whole sqw or dnd object from properly initialized sqw file
        [dnd_obj,varargout] = get_dnd(obj,varargin); % retrieve any sqw/dnd object as dnd object

        % -----------------------------------------------------------------
        % get [2x4] array of min/max ranges of the pixels contributing into
        % an object
        pix_range = get_pix_range(obj);
        % get [2x4] array of min/max ranges of the image contributing into
        % an object, which is the basis for the grid, the pixels are sorted
        % on
        img_db_range = get_img_db_range(obj);
        %
        % ----------------------------------------------------------------
        % save sqw object stored in memory into binary sqw file. Depending
        % on data present in memory it can in fact be a dnd object.
        % Save new or fully overwrite existing sqw file
        obj = put_sqw(obj,varargin);
        % save sqw/dnd object stored in memory into binary sqw file as dnd object.
        % it always reduced data in memory into dnd object on hdd
        obj = put_dnd(obj,varargin);
        % Comprising of:
        % 1) store or update application header
        % 2) store dnd information ('-update' option updates this
        % information within existing file)
        obj = put_dnd_metadata(obj,varargin);
        % write dnd image data, namely s, err and npix ('-update' option updates this
        % information within existing file)
        obj = put_dnd_data(obj,varargin);        
    end
    methods(Access=protected)
        function is_sqw = get_sqw_type(~)
            % Main part of get.sqw_type accessor
            % return true if the loader is intended for processing sqw file
            % format and false otherwise
            is_sqw = false;
        end
        function obj=init_from_sqw_obj(obj,varargin)
            % init file accessors from sqw object in memory
            obj = init_from_sqw_obj_(obj,varargin{:});
        end
        function obj=init_from_sqw_file(obj,varargin)
            % init file accessors from sqw file on hdd
            obj = init_from_sqw_file_(obj,varargin{:});
        end
        function [obj,missinig_fields] = copy_contents(obj,other_obj,keep_internals)
            % the main part of the copy constructor, copying the contents
            % of the one class into another including opening the
            % corresponding file with the same access rights
            error('Not Implemented yet');
        end

    end

end
