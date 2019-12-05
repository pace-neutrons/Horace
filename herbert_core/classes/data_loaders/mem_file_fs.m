classdef mem_file_fs < handle
    % The class provides file system type interface for saving/storing memfiles
    % in memory
    %
    %
    % $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
    %
    
    properties(Access=private) %
        % list of memfiles, stored in the filesystem
        existing_files = [];
    end
    
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function newObj = mem_file_fs()
            % Initialise your custom properties.
            newObj.existing_files=containers.Map;
        end
    end
    
    methods(Static)
        % Concrete implementation.  See Singleton superclass.
        function obj = instance()
            persistent uniqueMemfilesFS_instance;
            if isempty(uniqueMemfilesFS_instance)
                obj = mem_file_fs();
                uniqueMemfilesFS_instance = obj;
            else
                obj = uniqueMemfilesFS_instance;
            end
        end
    end
    
    %*** Define your own methods for the Singleton.
    methods % Public Access
        function isit=file_exist(this,file_name)
            % check if the file with given name exist
            [dummy,fname,fext]=fileparts(file_name);
            if ~isempty(fext) && ~strcmp('.mem',fext)
                isit = false;
                return
            end
            isit = this.existing_files.isKey(fname);
        end
        function n_files=get_numfiles(this)
            % return number of files stored in the memory file system
            n_files = this.existing_files.length;
        end
        function fnames = ls(this)
            % return cellarray of the file names stored in the filesystem
            fnames = this.existing_files.keys();
        end
        function this=save_file(this,file_name,file_obj)
            % method to save a memfile in the file system
            if isa(file_obj,'memfile')
                [dummy,fname,fext]=fileparts(file_name);
                if ~isempty(fext) && ~strcmp('.memfile',fext)
                    error('MEMFILE_FS:save_file','memfiles can be stored only in files with extension .memfile and got %s',fext);
                end
                this.existing_files(fname)=file_obj;
            else
                error('MEMFILE_FS:save_file',' filesystem supports storing memfiles only');
            end
        end
        function fcont=load_file(this,file_name)
            % method to load a memfile from the file system
            [dummy,fn,fext] = fileparts(file_name);
            if this.existing_files.isKey(fn)
                fcont = this.existing_files(fn);
            else
                error('MEMFILE_FS:load_file','File %s does not exist',file_name);
            end
        end
        function this=format(this)
            % remove all files from the filesystem
            fnames = this.existing_files.keys();
            this.existing_files.remove(fnames);
        end
    end
    
end

