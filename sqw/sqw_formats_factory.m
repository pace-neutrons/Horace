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
        supported_accessors = {faccess_sqw_v3(),faccess_sqw_v2(),faccess_dnd_v2(),faccess_sqw_prototype()};
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
        function loader = get_loader(obj,sqw_file_name)
            % return initiated loader which can load the data from the specified data file
            %
            %Usage:
            %>>loader=loaders_factory.instance().get_reader(sqw_file_name);
            %
            % where:
            %>>data_file_name  -- the name of the file, which is the source of the data
            %
            if ~isnumeric(sqw_file_name)
                [ok,mess,full_data_name] = check_file_exist(sqw_file_name,'*');
            end
            if ~ok
                mess = regexprep(mess,'[\\]','/');
                error('SQW_FORMATS_FACTORY:runtime_error','get_loader: %s',mess);
            end
            % get first 1044 bytes of binary file to identify file format.
            % Return bytes block and open file handle not to open it again
            [bytes_block,fh] = dnd_file_interface.get_file_header(full_data_name);
            
            for i=1:numel(obj.supported_accessors)
                loader = obj.supported_accessors{i};
                % check if loader should load the file. Initiate loaders
                % with open file handle if loader recognizes file format 
                % as its own.
                [ok,loader] = loader.should_load_stream(bytes_block,fh);
                if ok
                    % if loader can load, initialize loader to be able 
                    % to read the file.
                    try
                        loader=loader.init();
                    catch ME
                        error('SQW_FORMATS_FACTORY:runtime_error',...
                            ['get_loader: Error initializing selected loader: %s : %s\n',...
                            'invalid file format or damaged file?'],...
                            class(loader),ME.message)
                    end
                    return
                end
            end
            % better failure diagnostics
            fclose(fh);
            [ok,~] = obj.last_loader().check_if_horace(bytes_block);
            if ok
                error('SQW_FORMATS_FACTORY:runtime_error',...
                    ['get_loader: this Horace version do not support %s file version.\n',...
                    ' Update your Horace installation'],...
                    full_data_name);
            else
                error('SQW_FORMATS_FACTORY:runtime_error',...
                    ['get_loader: Existing readers can not understand format of file: %s\n',...
                    ' Is it not a sqw file?'],...
                    full_data_name);
            end            
            
        end
        %
        function ld = last_loader(obj)
            % returns the most recent data access format recommended to
            % usee
            % 
            ld = obj.supported_accessors{1};
        end
        
    end
    
    
end
