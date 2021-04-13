classdef dnd_file_interface
    % Interface to access dnd files,
    % containing common properties, describing any sqw or dnd file.
    %
    % Various accessors should inherit this class, implement the
    % abstract methods mentioned here and define protected fields, common
    % for all dnd-file accessors.
    %
    % dnd_file_interface Methods:
    % ----------------------------------------------------------------
    % Properties:
    % See Property Summary chapter.
    % ----------------------------------------------------------------
    % ----------------------------------------------------------------
    % Initializers:
    % Static:
    % get_file_header   - open existing file for rw access and read sqw
    %                     header
    % ----------------------------------------------------------------
    % Abstract methods:
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
    %
    properties(Access=protected,Hidden=true)
        filename_=''
        filepath_=''
        % Bad MATLAB OO :: each child should redefine this version manually
        % as you can not overload get/set operators
        file_ver_ = 2;
        % if the file is sqw or dnd
        sqw_type_ = false;
        % number of dimensions in sqw object
        num_dim_ = 'undefined'
        % list of the sqw class fields or subclasses and auxiliary data
        % structures, stored on hdd
        dnd_dimensions_ = 'undefined'
        % the type of data stored in file (legacy field, -- see getter for details)
        data_type_ = 'undefined';
        %
        %True if convert all read fields (except pixels) into double
        convert_to_double_ = true;
        
        % internal sqw/dnd object holder used as source for subsequent
        % write operations, when file accessor is initialized from an sqw
        % object
        sqw_holder_ = [];
    end
    %
    properties(Constant,Access=protected,Hidden=true)
        % format of application header, written at the beginning of a
        % binary sqw/dnd file to identify this file for clients
        app_header_form_ = struct('appname','horace','version',double(1),...
            'sqw_type',uint32(1),'ndim',uint32(1));
    end
    properties(Constant,Access=private,Hidden=true)
        % list of fieldnames to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file accessor
        fields_to_save_ = {'filename_';'filepath_';...
            'num_dim_';'dnd_dimensions_';'data_type_';'convert_to_double_'};
    end
    
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
        file_version;
        % If file, associated with loader is sqw or dnd file (contains pixels information)
        sqw_type;
        % Number of dimensions in the dnd image
        num_dim;
        % Dimensions of the Horace image (dnd object), stored in the file.
        dnd_dimensions
        % Legacy type of data written in the file, describing the information
        % stored in a sqw file
        %
        % Possible types are:
        %   type 'b'    fields: filename,...,dax,s,e
        %   type 'b+'   fields: filename,...,dax,s,e,npix
        %   type 'a'    fields: filename,...,dax,s,e,npix,img_db_range,pix
        %   type 'a-'   fields: filename,...,dax,s,e,npix,img_db_range.
        %
        % all modern data files are either b+ (dnd) or a+ (sqw data) type
        % files.
        data_type
        
        % if all numeric types, read from a file to be converted to double.
        % (except pixels)
        convert_to_double
        %
    end
    %----------------------------------------------------------------------
    methods
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
        %------------------------------------------------
        function ver = get.file_version(obj)
            % return the version of the loader corresponding to the format
            % of data, stored in the file
            ver = ['-v',num2str(obj.file_ver_)];
        end
        %------------------------------------------------
        function ndims = get.num_dim(obj)
            % get number of dimensions the image part of the object has.
            ndims = obj.num_dim_;
        end
        %------------------------------------------------
        function type = get.sqw_type(obj)
            % return true if the object to load is sqw-type (contains pixels) or
            % false if not.
            type = obj.sqw_type_;
        end
        %
        function ff=get.data_type(obj)
            ff = obj.data_type_;
        end
        %
        function dims = get.dnd_dimensions(obj)
            % return image binning
            dims = obj.dnd_dimensions_;
        end
        %
        function conv = get.convert_to_double(obj)
            % if true, convert all numerical values read from an sqw file
            % into double precision
            conv = obj.convert_to_double_;
        end
        %
        function obj = set.convert_to_double(obj,val)
            lval = logical(val);
            obj.convert_to_double_ = lval;
        end
        %-------------------------
        function obj = delete(obj)
            % invalidate an object in memory (make it non-initialized).
            obj.num_dim_        = 'undefined';
            obj.dnd_dimensions_ = 'undefined';
            obj.data_type_      = 'undefined';
            obj.sqw_type_       = false;
            obj.convert_to_double_ = true;
        end
        %
        function struc = saveobj(obj)
            % method used to convert object into structure
            % for saving it to disc.
            struc = struct('class_name',class(obj));
            flds = obj.fields_to_save_;
            for i=1:numel(flds)
                struc.(flds{i}) = obj.(flds{i});
            end
            if ~isempty(obj.sqw_holder_)
                warning('FACCESS:not_implemented',...
                    'sqw object serialization is not fully implemented. Using structure on object');
                struc.sqw_holder_ = struct(obj.sqw_holder_);
            end
        end
        %
        function struc = struct(obj)
            % convert faccess object into structure, which would allow to
            % recover such object
            struc = saveobj(obj);
        end
        %
        function has = has_pix_range(~)
            % Returns true when the pix_range is stored within a file.
            % 
            % old sqw file formatters were not storing this variable. 
            % If it is not stored, it needs to be recalculated.
            % 
            has = false;
        end
    end
    methods(Access = protected,Hidden=true)
        %
        function flds = fields_to_save(obj)
            % return list of filenames to save on hdd to be able to recover
            % all substantial parts of appropriate sqw file.
            flds = obj.fields_to_save_;
        end
        %
        function obj=init_from_structure(obj,obj_structure_from_saveobj)
            % init file accessors using structure, obtained for object
            % serialization (saveobj method);
            flds = obj.fields_to_save_;
            for i=1:numel(flds)
                if isfield(obj_structure_from_saveobj,flds{i})
                    obj.(flds{i}) = obj_structure_from_saveobj.(flds{i});
                end
            end
        end
    end
    %----------------------------------------------------------------------
    methods(Static) % defined by this class
        % open existing file for rw access and get sqw file header,
        % allowing loaders to identify the type of the file format
        % stored within the file
        [header,fid] = get_file_header(file,varargin)
        %
        % convert all numerical types of a structure into double
        val = do_convert_to_double(val)
        % build object from correspondent data structure.
        function obj = loadobj(struc)
            obj = feval(struc.class_name);
            obj = obj.init_from_structure(struc);
        end
    end
    %----------------------------------------------------------------------
    methods(Abstract)
        %
        % Mainly used by file formats factory and
        % verifies if the class should load the file
        [ok,objinit,mess]=should_load(obj,filename);
        %
        % verifies if the class should load the file, determined by opened
        % file identifier, by analyzing the block of information (stream)
        % obtained from the open file by get_file_header static method of
        % this class.
        [should,objinit,mess]= should_load_stream(obj,stream,fid)
        %
        % Main initializer (accessible through constructor with the same
        % arguments too.)
        %
        % initialize the loader, to be ready to read or write dnd data.
        % Usage:
        %>>obj = obj.init(filename_to_read);
        %>>obj = obj.init(sqw_object);
        %>>obj = obj.init(sqw_object,filename_to_write);
        %>>obj = obj.init(obj_structure_from_saveobj);
        obj = init(obj,varargin);
        %
        % Set new filename to write file or prepare existing file for
        % update or write if update is not possible.
        %Usage:
        %>>[obj,file_exist] = obj.set_file_to_update(filename_to_write);
        [obj,file_exist] = set_file_to_update(obj,varargin)
        
        % Reopen existing file to write new data to it assuming
        % the loader has been already initiated by this file. Will be
        % clearly overwritten or corrupted if partial information is
        % different and no total info was written.
        obj = reopen_to_write(obj,filename)
        %---------------------------------------------------------
        [data,obj]  = get_data(obj,varargin); % get whole dnd data without packing these data into dnd object.
        [data_str,obj] = get_se_npix(obj,varargin) % get only dnd image data, namely s, err and npix
        
        [inst,obj]  = get_instrument(obj,varargin); % return instrument stored with sqw file or empty structure if
        %                                             nothing is stored. Always empty for dnd objects.
        [samp,obj]  = get_sample(obj,varargin);   % return sample stored with sqw file or empty structure if
        %                                           nothing is stored. Always empty for dnd objects.
        [sqw_obj,varargout] = get_sqw(obj,varargin); % retrieve the whole sqw or dnd object from properly initialized sqw file
        [dnd_obj,varargout] = get_dnd(obj,varargin); % retrieve any sqw/dnd object as dnd object
        
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
        obj = put_app_header(obj);
        % 2) store dnd information ('-update' option updates this
        % information within existing file)
        obj = put_dnd_metadata(obj,varargin);
        % write dnd image data, namely s, err and npix ('-update' option updates this
        % information within existing file)
        obj = put_dnd_data(obj,varargin);
        % Return true if the file accessor is connected to an open file
        is = is_activated(obj);
        % open file, connected to the sqw object, defined as input,
        % assuming that all information about this file is already loaded
        % in memory by init/deactivate or deserialize methods.
        obj = activate(obj)
        % Close files related to this file accessor leaving all information
        % about this file in memory, e.g. preparing to serialize the class.
        obj = deactivate(obj)
        
    end
    methods(Abstract,Access=protected,Hidden=true)
        % init file accessors from sqw object in memory
        %
        obj=init_from_sqw_obj(obj,varargin);
        % init file accessors from sqw file on hdd
        obj=init_from_sqw_file(obj,varargin);
    end
    
end

