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
        num_dim_ = 'uninitiated'
        %
        % internal sqw/dnd object used as source for subsequent write operations
        sqw_object_ = [];
        
        %True to convert all read fields (except pixels) into double
        convert_to_double_ = true;
    end
    properties(Dependent)
        % the name of the file, this object is associated and should be
        % read from/written to
        filename
        % path to the obhect above
        filepath
        % version of the file format, a loader processes
        file_version;
        % if file, associated with loader is sqw or dnd file (contains
        % pixels)
        sqw_type;
        % number of dimensions in the dnd image
        num_dim;
        % if true, all numeric types, read from a file (except pixels)
        % are converted to double
        convert_to_double
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
        function obj = set.filename(obj,new_filename)
            % set new file name to save sqw data in.
            %
            obj = obj.check_file_upgrade_get_new_name(new_filename);
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
        function obj = close(obj)
            obj.num_dim_ = 'uninitiated';
            obj.sqw_object_ = [];
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        % open existing file for rw acces and get sqw file header,
        % allowing loaders to identify the type of the file format
        % stored within the file
        [header,fid] = get_file_header(file,varargin)
        %
        % convert all numerical types of the structure into double
        val = do_convert_to_double(val)
    end
    %----------------------------------------------------------------------
    methods(Abstract)
        % verify if the class should load the file
        [ok,obj]=should_load(obj,filename);
        %
        [should,obj,mess]= should_load_stream(obj,stream,fid)
        %
        % Check if file exist and prepare to update it contetns if it is
        % necessary and possible. Throws if upgrade is not possible
        obj = check_file_upgrade_set_new_name(obj,new_filename,new_data_struct);
        
        % initialize the loader, to be ready to read or write the sqw data.
        obj = init(obj,varargin);
        data        = get_data(obj,varargin);
        [inst,obj]  = get_instrument(obj,varargin);
        [samp,obj]  = get_sample(obj,varargin);
        % retrieve the whole sqw object from properly initialized sqw file
        sqw_obj = get_sqw(obj,varargin);
        % save sqw object stored in memory into binary sqw file
        %obj = put_sqw(obj,sqw_obj,varargin);
    end
 
end
