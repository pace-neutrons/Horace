classdef dnd_file_interface
    % Class to describe interface to access sqw files.
    %
    %   Various accessors should inherit this class, implement the
    %   abstract methods mentioned here and define protected fields, common
    %   for all sqw-file accessors
    %
    %
    % $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
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
        function fp  = get.filepath(obj)
            % the path to the file, this object is associated with
            fp = obj.filepath_;
        end
        function obj = set.filename(obj,new_filename)
            % set new file name to save sqw data in.
            %
            obj = obj.check_file_upgrade_get_new_name(new_filename);
        end
        
        function ver = get.file_version(obj)
            % return the version of the loader corresponding to the format
            % of data, stored in the file
            ver = ['-v',num2str(obj.file_ver_)];
        end
        function ndims = get.num_dim(obj)
            ndims = obj.num_dim_;
        end
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
        function obj = set.convert_to_double(obj,val)
            lval = logical(val);
            obj.convert_to_double_ = lval(1);
        end
        
        %-------------------------
        function obj = close(obj)
            obj.num_dim_ = 'uninitiated';
            obj.sqw_object_ = [];
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function [header,fid] = get_file_header(file,varargin)
            % open existing file for rw acces and get sqw file header,
            % allowing loaders to identify the type of the file format
            % stored within the file
            %
            [header,fid,message] = get_header_(file,varargin{:});
            if ~isempty(message)
                if fid>0
                    fclose(fid);
                end
                error('SQW_FILE_INTERFACE:io_error',['Error: ',message]);
            end
            % try to interpret input binary stream as horace header and
            % convert data stream into structure describing horace format
            [header,mess] = get_hor_version_(header);
            if ~isempty(mess)
                error('SQW_FILE_INTERFACE:runtime_error',['Error: ',message]);
            end
        end
        %
        function  val = do_convert_to_double(val)
            % convert all numerical types of the structure into double
            if iscell(val)
                for i=1:numel(val)
                    val{i} = dnd_file_interface.do_convert_to_double(val{i});
                end
            elseif isstruct(val)
                fn = fieldnames(val);
                for i=1:numel(fn)
                    val.(fn{i}) = dnd_file_interface.do_convert_to_double(val.(fn{i}));
                end
            elseif isnumeric(val)
                val = double(val);
            end
        end
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
    end
    methods
        %
    end
end
