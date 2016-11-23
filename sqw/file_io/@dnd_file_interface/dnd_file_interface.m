classdef dnd_file_interface
    % Class provides interface to access dnd files.
    %
    %   Various accessors should inherit this class, implement the
    %   abstract methods mentioned here and define protected fields, common
    %   for all sqw-file accessors
    %
    %
    % $Revision$ ($Date$)
    %
    
    properties(Access=protected)
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
        
        %True to convert all read fields (except pixels) into double
        convert_to_double_ = true;
        
    end
    %
    properties(Constant,Access=protected)
        % format of application header, written at the beginning of a
        % binary sqw/dnd file to identify this file for clients
        app_header_form_ = struct('appname','horace','version',double(1),...
            'sqw_type',uint32(1),'ndim',uint32(1));
    end
    
    properties(Dependent)
        % the name of the file, this object is associated and should be
        % read from/written to
        filename
        % path to the object above
        filepath
        % version of the file format, a loader processes
        file_version;
        % if file, associated with loader is sqw or dnd file (contains
        % pixels)
        sqw_type;
        % number of dimensions in the dnd image
        num_dim;
        % dimensions of the Horace image (dnd object), stored in the file
        dnd_dimensions
        % type of the data, stored in a file
        data_type
        
        % if true, all numeric types, read from a file (except pixels)
        % are converted to double
        convert_to_double
        %
    end
    %----------------------------------------------------------------------
    methods
        function fn  = get.filename(obj)
            % the name of the file, this object is associated with
            fn = obj.filename_;
        end
        %
        function fp  = get.filepath(obj)
            % the path to the file, this object is associated with
            fp = obj.filepath_;
        end
        %
        function ver = get.file_version(obj)
            % return the version of the loader corresponding to the format
            % of data, stored in the file
            ver = ['-v',num2str(obj.file_ver_)];
        end
        %
        function ndims = get.num_dim(obj)
            ndims = obj.num_dim_;
        end
        %
        function type = get.sqw_type(obj)
            % return true if the object to load is sqw-type (contains pixels) or
            % false if not.
            type = obj.sqw_type_;
        end
        %
        function ff=get.data_type(obj)
            %   data_type   Type of sqw data written in the file
            %   type 'b'    fields: filename,...,dax,s,e
            %   type 'b+'   fields: filename,...,dax,s,e,npix
            %   type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
            %   type 'a-'   fields: filename,...,dax,s,e,npix,urange
            ff = obj.data_type_;
        end
        %
        function dims = get.dnd_dimensions(obj)
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
            obj.num_dim_        = 'undefined';
            obj.dnd_dimensions_ = 'undefined';
            obj.data_type_      = 'undefined';
            obj.sqw_type_       = false;
            obj.convert_to_double_ = true;
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
    end
    %----------------------------------------------------------------------
    methods(Abstract)
        % Initializers:
        % Mainly used by file formats factory:
        %
        % verify if the class should load the file
        [ok,obj]=should_load(obj,filename);
        %
        % verify if the class should load the file, determined by opened
        % file identifier by analysing the block of information (stream)
        % obtained from the open file
        [should,obj,mess]= should_load_stream(obj,stream,fid)
        %
        % Main initializer (accessible through constructor with the same
        % arguments too.)
        %
        % initialize the loader, to be ready to read or write the sqw data.
        % Usage:
        %>>obj = obj.init(filename_to_read);
        %>>obj = obj.init(sqw_object);
        %>>obj = obj.init(sqw_object,filename_to_write);
        obj = init(obj,varargin);
        % set new filename to write file to prepare existing file for
        % writing
        % Defined only for classes, initiated with sqw_object
        %Usage:
        %>>[obj,file_exist] = obj.set_file_to_write(filename_to_write);
        [obj,file_exist] = set_file_to_write(obj,varargin)
        % ----------------------------------------------------------------
        % File Accessors:
        [data,obj]  = get_data(obj,varargin);
        % get only dnd image data, namely s, err and npix
        [data_str,obj] = get_se_npix(obj,varargin)
        
        [inst,obj]  = get_instrument(obj,varargin);
        [samp,obj]  = get_sample(obj,varargin);
        % retrieve the whole sqw object from properly initialized sqw file
        [sqw_obj,varargout] = get_sqw(obj,varargin);
        % retrieve any sqw/dnd object as dnd object
        [dnd_obj,varargout] = get_dnd(obj,varargin);        
        % ----------------------------------------------------------------
        % File Mutators:
        %
        % save sqw object stored in memory into binary sqw file. Depending
        % on data present in memory it can in fact save dnd object.
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
        obj = put_dnd_methadata(obj,varargin);
        % write dnd image data, namely s, err and npix ('-update' option updates this
        % information within existing file)
        obj = put_dnd_data(obj,varargin);
        % Reopen existing file to upgrade/write new data to it assuming
        % the loader has been already initiated by this file. Will be
        % clearly overwritten or destroyed if partial information is
        % different and no total info was written.
        obj = reopen_to_write(obj)
        %
    end
    methods(Abstract,Access=protected)
        % init file accessors from sqw object in memory
        obj=init_from_sqw_obj(obj,varargin);
        % init file accessors from sqw file on hdd
        obj=init_from_sqw_file(obj,varargin);
    end
    
end
