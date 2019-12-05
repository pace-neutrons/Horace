classdef loaders_factory < handle
    % The class responsible for providing and initiating requested file loader on
    % demand
    %
    %
    % $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
    %
    
    
    properties(Access=private) %
        % Registered file readers:
        % Add all new file readers which inherit from a_loader to this list in the order
        % of expected frequency for their appearance.
        supported_readers = {loader_nxspe(),loader_ascii(),memfile(),loader_speh5()};
        % field describes
        reader_descriptions_ = {};
        % supported filenames extensions;
        readers_fext_={};
    end
    properties(Dependent)
        % list of the supported readers names with their brief
        % descriptions        
        reader_descriptions;
        % returns list of file extensions, supported by current file
        % readers
        supported_file_extensions;
    end
    
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function newObj = loaders_factory()
            % Initialise your custom properties.
            
            nLoaders = numel(newObj.supported_readers);
            
            rd = cell(nLoaders,1);
            ext = cell(nLoaders,1);
            for i=1:nLoaders
                rd{i} = newObj.supported_readers{i}.get_file_description();
                ext{i}= newObj.supported_readers{i}.get_file_extension();
            end
            empty =  cellfun(@isempty,rd);
            newObj.reader_descriptions_=rd(~empty);
            newObj.readers_fext_ = ext(~empty);
        end
    end
    
    methods(Static)
        % Concrete implementation.  See Singleton superclass.
        function obj = instance()
            persistent uniqueLoaders_factory_Instance
            if isempty(uniqueLoaders_factory_Instance)
                obj = loaders_factory();
                uniqueLoaders_factory_Instance = obj;
            else
                obj = uniqueLoaders_factory_Instance;
            end
        end
    end
    
    methods % Public Access
        function descr_list=get.reader_descriptions(obj)
            % returns list of the supported readers names with their brief
            % descriptions
            descr_list = obj.reader_descriptions_;
        end
        function ext_list=get.supported_file_extensions(obj)
            % return the list of the file extensions, supported by the file reader
            ext_list=obj.readers_fext_;
        end
        function n_loaders=get_nLoaders(obj)
            %return number of registered data loaders
            n_loaders = numel(obj.supported_readers);
        end
        function loader = get_loader(obj,data_file_name,par_file_name)
            % return initiated loader which can load the data from the specified data file
            %
            %Usage:
            %>>loader=loaders_factory.instance().get_loader(data_file_name,[par_file_name]);
            % where:
            % data_file_name  -- the name of the file, which is the source of the data
            % par_file_name   -- if present the name of the ascii par or phx file
            %                    to load information from. If not present, loader
            %                    is not fully defined or expects to load detector
            %                    information from the main data file.
            %
            [ok,message,full_data_name] = check_file_exist(data_file_name,'*');
            if ~ok
                message = regexprep(message,'[\\]','/');
                error('LOADERS_FACTORY:get_loader',message);
            end
            for i=1:numel(obj.supported_readers)
                loader = obj.supported_readers{i};
				% check if loader can load the file. Return structure, containing 
				% opened file handle and auxiliary information, read from the file
				% if it can load a file for init function not to read it again. 
                [ok,fh] = loader.can_load(full_data_name);
                if ok
					% if loader can, initialize loader with the file.
                    if exist('par_file_name','var')
                        loader=loader.init(full_data_name,par_file_name,fh);
                    else
                        loader=loader.init(full_data_name,'',fh);
                    end
                    return
                end
            end
            error('LOADERS_FACTORY:get_loader',' existing loaders can not load file %s',full_data_name);
        end
    end
    
    
end

