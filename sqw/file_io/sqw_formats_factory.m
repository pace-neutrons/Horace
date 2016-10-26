classdef sqw_formats_factory < handle
    % The class responsible for providing and initiating requested sqw file/read-writer on
    % demand
    %
    %
    % $Revision: 536 $ ($Date: 2016-09-26 16:02:52 +0100 (Mon, 26 Sep 2016) $)
    %
    
    
    properties(Access=private) %
        % Registered file accessors:
        % Add all new file readers which inherit from sqw_file_interface to this list in the order
        % of expected frequency for their appearance.
        supported_accessors = {faccess_v3(),faccess_v2(),faccess_prototype()};
    end
    properties(Dependent)
    end
    
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function newObj = sqw_formats_factory()
            % Initialise your custom properties.
            
            %nLoaders = numel(newObj.supported_readers);
        end
    end
    
    methods(Static)
        % Concrete implementation.
        function obj = instance()
            persistent uniqueLoaders_factory_Instance
            if isempty(uniqueLoaders_factory_Instance)
                obj = sqw_formats_factory();
                uniqueLoaders_factory_Instance = obj;
            else
                obj = uniqueLoaders_factory_Instance;
            end
        end
    end
    
    methods % Public Access
        function loader = get_reader(obj,sqw_file_name)
            % return initiated loader which can load the data from the specified data file
            %
            %Usage:
            %>>loader=loaders_factory.instance().get_reader(sqw_file_name);
            % where:
            % data_file_name  -- the name of the file, which is the source of the data
            if ~isnumeric(sqw_file_name)
                [ok,mess,full_data_name] = check_file_exist(sqw_file_name,'*');
            end
            if ~ok
                mess = regexprep(mess,'[\\]','/');
                error('SQW_FORMATS_FACTORY:get_reader',mess);
            end
            [ver,fh,mess] = sqw_file_interface.get_sqw_version(full_data_name);
            if isempty(ver)
                mess = regexprep(mess,'[\\]','/');
                error('SQW_FORMATS_FACTORY:get_reader',mess);
            else
                if~empty(mess)
                    warning('SQW_FORMATS_FACTORY:get_reader', ['Problem with input file format: ',mess])
                end
            end
            
            full_data_name = ver.file_name;
            
            for i=1:numel(obj.supported_accessors)
                loader = obj.supported_accessors{i};
                % check if loader can load the file. Return structure, containing
                % opened file handle and auxiliary information, read from the file
                % if it can load a file for init function not to read it again.
                [ok,loader] = loader.can_load(ver,fh);
                if ok
                    % if loader can load, initialize loader with the file.
                    try
                        loader=loader.init();
                    catch ME
                        error('SQW_FORMATS_FACTORY:get_reader',...
                            'Error initializing preferred loader %s : %s',...
                            class(loader),ME.message)
                    end
                    return
                end
            end
            fclose(fh);
            error('SQW_FORMATS_FACTORY:get_reader',' existing readers can not understand file %s',full_data_name);
        end
        %
    end
    
    
end
