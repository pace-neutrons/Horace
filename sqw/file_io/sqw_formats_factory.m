classdef sqw_formats_factory < handle
    % The class responsible for providing and initiating requested sqw file/read-writer on
    % demand
    %
    %
    % $Revision$ ($Date$)
    %
    
    
    properties(Access=private) %
        % Registered file accessors:
        % Add all new file readers which inherit from sqw_file_interface to this list in the order
        % of expected frequency for their appearance.
        supported_accessors_ = {faccess_sqw_v3(),faccess_sqw_v2(),faccess_dnd_v2(),faccess_sqw_prototype()};
        supported_types_ = {'sqw','dnd','d0d','d1d','d2d','d3d','d4d'};
        access_to_type_ind_ = {1,3,3,3,3,3,3};
        types_map_ ;
    end
    properties(Dependent)
    end
    
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function obj = sqw_formats_factory()
            % Initialise your custom properties.
            obj.types_map_= containers.Map(obj.supported_types_,...
                obj.access_to_type_ind_);
            
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
            % read initial bytes of binary file and interpret them as Hoeace headers to to identify file format.
            % Return header block and open file handle not to open it again
            [bytes_block,fh] = dnd_file_interface.get_file_header(full_data_name);
            
            for i=1:numel(obj.supported_accessors_)
                loader = obj.supported_accessors_{i};
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
        function loader = get_pref_access(obj,varargin)
            % return the version of the accessor recommended for use with
            % particular type of sqw object.
            %
            % Assuming working with sqw object by default
            %
            if nargin == 1
                loader = obj.supported_accessors_{1};
            else
                if isa(varargin{1},'sqw')
                    loader = obj.supported_accessors_{1};
                else
                    type = class(varargin{1});
                    if obj.types_map_.isKey(type)
                        ld_num = obj.types_map_(type);
                        loader = obj.supported_accessors_{ld_num};
                    else
                        error('SQW_FORMATS_FACTORY:get_pref_loader',...
                            'the class %s does not have registered accessor',...
                            type)
                    end
                    
                end
            end
        end
        
        
    end
end
