classdef horace_binfile_interface < serializable
    % Interface to access all sqw binary files,
    % containing common properties, describing any sqw or dnd file.
    %
    % Various accessors should inherit this class, implement the
    % abstract methods mentioned here and define protected fields, common
    % for all dnd-file accessors.
    %
    % horace_binfile_interface Methods:
    % ----------------------------------------------------------------
    % Properties:
    % See Property Summary chapter.
    % ----------------------------------------------------------------
    % ----------------------------------------------------------------
    % Initializers:
    % Static:
    % get_file_header   - open existing file for rw access and read sqw
    %                     header, allowing to identify the version of the
    %                     file format.
    % ----------------------------------------------------------------
    % Main methods same for all binfiles:
    % should_load        - verify if the class should load the file
    % should_load_stream - verify if the class should load the file,
    %                      determined by opened file id
    % init               - main method to initialize empty objects.
    % set_file_to_update - open new or reopen existing file in update mode.
    %                      (all put operations will try to keep file
    %                      contents or fail)
    % reopen_to_write    - open new or reopen existing file in write mode
    %                      (all existing contents will be ignored)
    % ----------------------------------------------------------------
    % Data accessors (abstract):
    % get_data           - get all dnd data without packing them into dnd
    %                      object.
    % get_sqw            - retrieve the whole sqw or dnd object.
    % get_dnd            - retrieve any sqw/dnd object as dnd object
    % ----------------------------------------------------------------
    % Data mutators (abstract):
    % put_sqw  - save sqw object stored in memory into binary sqw file.
    % put_dnd  - save sqw/dnd object stored in memory into binary sqw file
    %            as dnd object.
    %
    % There is also range of auxiliary less important methods.
    % ----------------------------------------------------------------
    %
    properties(Dependent)
        % The name of the file, for the accessor to work with.
        filename
        % Path to the file for this accessor to work with.
        filepath
        % Version of the file format, an accessor is associated with
        %
        % Each particular accessor should set up this version to the
        % version it understands and store this version in a sqw file.
        % The sqw_formats_factory registers all available accessors and
        % selects appropriate accessor according to the file version.
        faccess_version;
        % If file, associated with loader is sqw or dnd file (contains pixels information)
        sqw_type;
        % Number of dimensions in the dnd image
        num_dim;

        % In old style sqw files returns timestamp of the file, Recent
        % format files return real creation time, files store real
        % creation time within
        creation_date
        %
        % get access to internal sqw object if any is defined for testing
        % purposes
        sqw_holder
    end
    properties(Dependent)
        % the property which sets/gets full file name (with path);
        full_filename;
    end

    properties(Access=protected)
        filename_=''
        filepath_=''

        % number of dimensions in sqw object
        num_dim_ = 'undefined'
        %
        % internal sqw/dnd object holder used as source for subsequent
        % write operations, when file accessor is initialized from this sqw
        % object
        sqw_holder_ = [];
        %------------------------------------------------------------------
        % class used to calculate all transformations between sqw/dnd class
        % in memory, and their byte representation on hdd.
        sqw_serializer_=sqw_serializer();
        % the open file handle (if any is open)
        file_id_=-1
        % holder for the object which surely closes open sqw file on class
        % deletion
        file_closer_ = [];
    end
    %
    properties(Constant,Access=protected)
        % format of application header, written at the beginning of a
        % binary sqw/dnd file to identify this file for clients
        app_header_form_ = struct('appname','horace','version',double(1),...
            'sqw_type',uint32(1),'num_dim',uint32(1));
        % the size of the horace version definition tape, the tape occupies
        % on the disk.
        max_header_size_ = 4+6+8+4+4;
    end
    %======================================================================
    % CONSTRUCTOR AND MAIN OPERATIONS:
    methods(Static) % defined by this class
        % open existing file for rw access and get sqw file header,
        % allowing loaders to identify the type of the file format
        % stored within the file
        [header,fid] = get_file_header(file,varargin)
        %
    end
    methods
        function obj = horace_binfile_interface(varargin)
            % constructor. All operations are performed througn init
            % function.
            if nargin == 0
                return;
            end
            obj = obj.init(varargin{:});
        end
        %-------------------------
        % Build header, which allows to distinguish Horace from other
        % applications and adds some information about stored sqw/dnd
        % object and binary file version
        % The binary header should be readable by all Horace versions
        % including binary versions, so its implemenataion is moved to top
        % faccessors level
        app_header = build_app_header(obj,varargin)
        % store application header which describes the sqw binary file
        obj = put_app_header(obj);
        %
        % initialize the loader, to be ready to read or write binary data.
        % Usage:
        %>>obj = obj.init(filename_to_read);
        %>>obj = obj.init(sqw_object);
        %>>obj = obj.init(sqw_object,filename_to_write);
        %>>obj = obj.init(obj_structure_from_saveobj);
        obj = init(obj,varargin);
        %------------------------------------------------------------------
        % check if the specific loader should load this file
        [ok,objinit,mess]=should_load(obj,filename)
        % check if the specific loader should load this file given that the
        % file is already opened and the file header have been read,
        [should,objinit,mess]= should_load_stream(obj,head_struc,fid)
        %----------------
        % Reopen existing file to overwrite or write new data to it
        % or open new target file to save data.
        [obj,permissions] = reopen_to_write(obj,filename)
        % Set filename to save sqw data and open file for write/append
        % /update operations. Only common update/read/write code is defined
        % here. Children should reuse it and add code to extract
        % information necessary for updating file format.
        [obj,file_exist,old_ldr] = set_file_to_update(obj,varargin)
        %----------------
        % open file, connected to the sqw object, defined as input,
        % assuming that all information about this file is already loaded
        % in memory by init/deactivate or deserialize methods.
        obj = activate(obj,varargin)
        % Close files related to this file accessor leaving all information
        % about this file in memory, e.g. preparing to serialize the class.
        obj = deactivate(obj)
        % Return true if the file accessor is connected to an open file
        is = is_activated(obj, read_or_write);
        %----------------
        function obj = delete(obj)
            % close associated file (if open) and remove all information
            % about internal file structure from memory.
            obj = delete_(obj);
        end
        function obj = init_input_stream(obj,objinit)
            % initialize object to read input file using proper obj_init
            % information, containing opened file handle.
            obj = init_input_stream_(obj,objinit);
        end
    end
    %----------------------------------------------------------------------
    methods(Access = protected)
        function obj=check_obj_initated_properly(obj)
            % helper function to check the state of put and update functions
            % if put methods are invoked separately
            obj=check_obj_initiated_properly_(obj);
        end
        % Get the creation date of the file, associated with loader
        tm = get_creation_date(obj)

        function obj = fclose(obj)
            % Close existing file header if it has been opened
            obj = fclose_(obj);
        end
        function check_error_report_fail_(obj,pos_mess)
            % check if error occurred during io operation and throw if it does happened
            [mess,res] = ferror(obj.file_id_);
            if res ~= 0; error('HORACE:sqw_file_insterface:io_error',...
                    '%s -- Reason: %s',pos_mess,mess);
            end
        end
    end
    %======================================================================
    % ACCESSORS & MUTATORS
    methods
        function sh = get.sqw_holder(obj)
            sh = obj.sqw_holder_;
        end
        function obj = set.sqw_holder(obj,val)
            if ~isa(val,'SQWDnDBase')
                error('HORACE:horace_binfile_interface:invalid_argument', ...
                    'sqw_holder can be initialized by an sqw family of objects only. Trying to assign: %s',...
                    class(val));
            end
            obj = obj.init_from_sqw_obj(val);
        end
        %------------------------------------------------
        function fn  = get.filename(obj)
            % the name of the file, this object is associated with
            fn = obj.filename_;
        end
        %
        function fp  = get.filepath(obj)
            % the path to the file, this object is associated with
            fp = obj.filepath_;
        end

        function fp = get.full_filename(obj)
            fp = fullfile(obj.filepath_,obj.filename_);
        end
        function obj = set.full_filename(obj,val)
            if ~ischar(val) || isstring(val)
                error('HORACE:horace_binfile_interface:invalid_argument', ...
                    'The full filename can be only string or char array. It is: %s',...
                    class(val));
            end
            [fp,fn,fe] = fileparts(val);
            obj.filepath_ = fp;
            obj.filename_  = [fn,lower(fe)];
        end
        %------------------------------------------------
        function ndims = get.num_dim(obj)
            % get number of dimensions the image part of the object has.
            ndims = obj.num_dim_;
        end
        %------------------------------------------------------------------
        %OVERLOADABLE ACCESSORS
        function type = get.sqw_type(obj)
            % return true if the object to load is sqw-type (contains pixels) or
            % false if not.
            type = get_sqw_type(obj);
        end
        function tm = get.creation_date(obj)
            tm = get_creation_date(obj);
        end
        function ver = get.faccess_version(obj)
            % return the version of the loader corresponding to the format
            % of data, stored in the file.  Overloadable by children.
            ver = get_faccess_version(obj);
        end
    end
    %======================================================================
    methods(Abstract)
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
    methods(Abstract,Access=protected)
        % init file accessors from sqw object in memory
        obj=init_from_sqw_obj(obj,varargin);
        % init file accessors from sqw file on hdd
        obj=init_from_sqw_file(obj,varargin);

        % the main part of the copy constructor, copying the contents
        % of the one class into another including opening the
        % corresponding file with the same access rights
        [obj,missinig_fields] = copy_contents(obj,other_obj,keep_internals)

        % get the version of the file format, the loader should process
        ver = get_faccess_version(~);
        % true, if loader processes sqw file and false if dnd.
        is_sqw = get_sqw_type(~)
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    properties(Constant,Access=private)
        % list of fieldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file accessor
        fields_to_save_ = {'filename_';'filepath_';...
            'num_dim_'};
    end
    methods
        function strc = to_bare_struct(obj,varargin)
            flds = horace_binfile_interface.fields_to_save_;
            cont = cellfun(@(x)obj.(x),flds,'UniformOutput',false);
            strc = cell2struct(cont,flds);
        end
        function obj=from_bare_struct(obj,indata)
            flds = horace_binfile_interface.fields_to_save_;
            for i=1:numel(flds)
                name = flds{i};
                if isfield(indata,name)
                    obj.(name) = indata.(name);
                end
            end
            if isfield(indata,'sqw_holder')
                if isa(indata.sqw_holder,'SQWDnDBase')
                    obj.sqw_holder_  = indata.sqw_holder;
                else
                    obj.sqw_holder_  = serializable.from_struct(indata.sqw_holder);
                end
            end
        end
        function  ver  = classVersion(~)
            % serializable fields version
            ver = 1;
        end
        function flds = saveableFields(~)
            flds = horace_binfile_interface.fields_to_save_;
        end
        %------------------------------------------------------------------
    end
end

