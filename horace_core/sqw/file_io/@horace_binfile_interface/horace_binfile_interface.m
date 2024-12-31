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
        % format files return real creation time, as files store real
        % creation time within.
        creation_date
        % The property indicates if the data are stored in file the loader
        % is connected to.
        data_in_file;

        %
        % get access to internal sqw object to store/restore from hdd
        % if any is defined.
        % Normally it is necessary for testing purposes
        sqw_holder
        % interfaces to binary access outside of this class:
        % initial location of npix array
        npix_position;
        % the property which sets/gets full file name (with path);
        % Duplicates filename/filepath information. Provided for
        % flexibility/simplicity.
        full_filename;
    end
    properties(Dependent,Hidden=true)
        % HELPER/convenience PROPERTIES. hidden not to clutter main interface.
        %
        % property used in upgrading file format and specifying
        % for what class IO operations (sqw or dnd) the file accessor
        format_for_object; % is intended for
        % Read-only accessor to the mode, current source file
        io_mode % is opened in. Empty if the file is not opened
        % access to the file_id of the f-accessor
        file_id
        % property, which gives read-only access to file-closer
        file_closer;
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
        % The property indicates if the data are stored in file the loader
        % is connected with.
        data_in_file_ = false;
    end
    %
    properties(Constant,Access=protected)
        % format of application header, written at the beginning of a
        % binary sqw/dnd file to identify this file for clients
        app_header_form_ = struct('appname','horace','version',double(1),...
            'sqw_type',uint32(1),'num_dim',uint32(1));
        % the size of the Horace version definition tape, the tape occupies
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

    % Main class methods & constructor
    methods
        function obj = horace_binfile_interface(varargin)
            % constructor. All operations are performed through init
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
        % including binary versions, so its implementation is moved to top
        % f-accessors level
        app_header = build_app_header(obj,varargin)
        % store application header which describes the sqw binary file
        obj = put_app_header(obj,varargin);
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
            % close associated file
            obj = delete_(obj);
        end
        function obj = init_input_stream(obj,objinit)
            % initialize object to read input file using proper obj_init
            % information, containing opened file handle.
            obj = init_input_stream_(obj,objinit);
        end
        % upgrade file format to new current preferred file format
        new_obj = upgrade_file_format(obj,varargin);
        %
    end
    %======================================================================
    % MAIN INTERFACE
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
        [dnd_meta,obj] = get_dnd_metadata(obj,varargin) % retrieve dnd object metadata (all data stored in dnd object except data arrays)

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

        % the function returns standard head information about sqw/dnd file
        hd = head(obj,varargin)
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
        % getter for the object type
        obj_type = get_format_for_object(obj);
        % main part of upgrade file format, which computes and transforms missing
        % properties from old file format to the new file format
        new_obj = do_class_dependent_updates(new_obj,old_obj,varargin);

        % main part of the accessor to the npix array position on hdd
        pos = get_npix_position(obj);
    end
    %======================================================================
    % GENERAL ACCESSORS & MUTATORS
    methods
        function is = get.data_in_file(obj)
            is = obj.data_in_file_;
        end
        %
        function mode = get.io_mode(obj)
            [~,mode] = fopen(obj.file_id_);
        end
        %
        function sh = get.sqw_holder(obj)
            sh = obj.sqw_holder_;
        end
        function obj = set.sqw_holder(obj,val)
            if ~isa(val,'SQWDnDBase')
                if isempty(val)
                    obj.sqw_holder_ = [];
                    return;
                else
                    error('HORACE:horace_binfile_interface:invalid_argument', ...
                        'sqw_holder can be initialized by an sqw family of objects only. Trying to assign: %s',...
                        class(val));
                end
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
            if ischar(obj.num_dim_)
                ndims = obj.num_dim_;
            else
                ndims = double(obj.num_dim_);
            end
        end
        function id = get.file_id(obj)
            id = obj.file_id_;
        end
        function fc = get.file_closer(obj)
            fc = obj.file_closer_;
        end
        %
        function obj = fclose(obj)
            % Close existing file header if it has been opened
            obj = fclose_(obj);
        end
        %------------------------------------------------------------------
        %OVERLOADABLE ACCESSORS
        function obj_type = get.format_for_object(obj)
            obj_type = get_format_for_object(obj);
        end
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
        function pos = get.npix_position(obj)
            % retrieve the position of npix array in a binary file
            % for accessing it using
            pos = get_npix_position(obj);
        end
    end
    %======================================================================
    % COMMON PROTECTED METHODS.
    methods(Access = protected)
        function obj=check_obj_initated_properly(obj)
            % helper function to check the state of put and update functions
            % if put methods are invoked separately
            obj=check_obj_initiated_properly_(obj);
        end
        % Get the creation date of the file, associated with loader
        tm = get_creation_date(obj)

        function check_error_report_fail_(obj,pos_mess)
            % check if error occurred during io operation and throw if it does happened
            [mess,res] = ferror(obj.file_id_);
            if res ~= 0; error('HORACE:sqw_file_insterface:io_error',...
                    '%s -- Reason: %s',pos_mess,mess);
            end
        end
        function [iseq,mess]  = equal_to_tol_single(obj,other_obj,opt,varargin)
            % internal procedure used by equal_to_toll method to compare
            % single pair of faccess objects
            % Input:
            % obj       -- first object to compare
            % other_obj -- second object to compare
            % opt       -- the structure containing fieldnames and their
            %              values as accepted by generic equal_to_tol
            %              procedure or retruned by
            %              process_inputs_for_eq_to_tol function
            %
            %TODO: this is fudge implementation. Re #1795 should provide a
            %proper one.
            %
            % Returns:
            % iseq      -- logical containing true if objects are equal and
            %              false otherwise.
            % mess      -- char array empty if iseq == true or containing
            %              more information on the reason behind the
            %              difference if iseq == false
            mess = '';
            iseq = isequal(obj,other_obj);
            if ~iseq
                clOb =  set_temporary_warning('off','MATLAB:structOnObject');
                s1 = struct(obj);
                s2 = struct(other_obj);
                [iseq,mess] = equal_to_tol(s1,s2,opt,varargin{:});
            end
        end
    end
    methods(Static,Access=protected)
        function  opts = parse_get_sqw_args(varargin)
            % processes keywords and input options of get_sqw function.
            % See get_sqw function for the description of the options
            % available
            opts = parse_get_sqw_args_(varargin{:});
        end
    end
    %======================================================================
    methods(Static) % helper methods used for binary IO
        function move_to_position(fid,pos)
            % move write point to the position, specified by input
            %
            % Inputs:
            % fid -- open file id
            % pos -- position from beginning of the file
            % error_message
            %     -- text to add to the error message in case of failure to
            %        identify the code, attempting the move
            %
            % Throw, HORACE:data_block:io_error if the movement have not
            % been successful.
            %
            move_to_position_(fid,pos);
        end
        function check_write_error(fid,add_info)
            % check if write operation have completed successfully.
            %
            % Inputs:
            % fid -- open file id for write operation
            % Throw HORACE:data_block:io_error if there were write errors.
            %
            % If add_info is not empty, it added to the error message and
            % used for clarification of the error location.
            if nargin<2
                add_info = '';
            end
            check_io_error_(fid,'writing',add_info);
        end
        function check_read_error(fid,add_info)
            % check if read operation have completed successfully.
            %
            % Inputs:
            % fid -- open file id for write operation

            % Throw HORACE:data_block:io_error if there were read errors.
            %
            % If add_info is not empty, it added to the error message and
            % used for clarification of the error location.
            if nargin<2
                add_info = '';
            end
            check_io_error_(fid,'reading',add_info);
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    % Unlike usual serializable, this class is serialized through
    % protected and private properties values. Because of this, the class
    % have unusual overloads, which may not support chain of serializable
    % objects. This is unnecessary, because this object do not contain
    % serializable properties.
    properties(Constant,Access=private)
        % list of fieldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file accessor
        fields_to_save_ = {'filename_';'filepath_';...
            'num_dim_'};
    end
    properties(Dependent,Hidden=true)
        % accessor to number of dimensions, hidden for use with
        % serializable only and used by faccess_v4 to save/restore num_dim
        % as old faccess_v<4 use protected "num_dim_" property
        num_dims_to_save;
    end

    methods % to satisfy serializable interface
        function nd = get.num_dims_to_save(obj)
            nd = obj.num_dim_;
        end
        function obj = set.num_dims_to_save(obj,val)
            if ~(isnumeric(val) && (val>-1 && val<5))
                if ~((ischar(val)||isstring(val))&&strcmp(val,'undefined'))
                    error('HORACE:horace_binfile_interface:invalid_argument', ...
                        'num_dim variable can be only number in the range [0:5]. It is: %s', ...
                        disp2str(val));
                end
            end
            obj.num_dim_ = val;
        end

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
