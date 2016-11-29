classdef sqw_formats_factory < handle
    % The class responsible for providing and initiating appropriate sqw file/read-writer
    % given sqw file name or preferred sqw file/read-writer given sqw
    % object or sqw or dnd oject name.
    %
    %
    % $Revision$ ($Date$)
    %
    
    
    properties(Access=private) %
        % Registered file accessors:
        % Add all new file readers which inherit from sqw_file_interface to this list in the order
        % of expected frequency for their appearance.
        supported_accessors_ = {faccess_sqw_v3(),faccess_sqw_v2(),faccess_dnd_v2(),faccess_sqw_prototype()};
        %
        % Old class interface:
        % classes to load/save
        written_types_ = {'sqw','dnd','d0d','d1d','d2d','d3d','d4d'};
        % number of loader in the list of loaders to use with correspondent class
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
            obj.types_map_= containers.Map(obj.written_types_ ,...
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
            %>>loader=loaders_factory.instance().get_loader(sqw_file_name);
            %
            % where:
            %>>data_file_name  -- the name of the file, which is the source of the data
            %                     or the celarray of such names.
            %
            if iscell(sqw_file_name) % process range of files
                loader = cellfun(@(x)(obj.get_loader(x)),sqw_file_name,...
                    'UniformOutput',false);
                return;
            end
            if ~isnumeric(sqw_file_name)
                [ok,mess,full_data_name] = check_file_exist(sqw_file_name,'*');
            end
            if ~ok
                mess = regexprep(mess,'[\\]','/');
                error('SQW_FILE_IO:runtime_error','get_loader: %s',mess);
            end
            % read initial bytes of binary file and interpret them as Horace headers to identify file format.
            % Returns header block and open file handle not to open file again
            [head_struc,fh] = dnd_file_interface.get_file_header(full_data_name);
            
            for i=1:numel(obj.supported_accessors_)
                loader = obj.supported_accessors_{i};
                % check if loader should load the file. Initiate loaders
                % with open file handle if loader recognizes file format
                % as its own.
                [ok,objinit] = loader.should_load_stream(head_struc,fh);
                if ok
                    % if loader can load, initialize loader to be able
                    % to read the file.
                    try
                        loader=loader.init(objinit);
                        return
                    catch ME
                        error('SQW_FILE_IO:runtime_error',...
                            ['get_loader: Error initializing selected loader: %s : %s\n',...
                            'invalid file format or damaged file?'],...
                            class(loader),ME.message)
                    end
                    return
                end
            end
            % no appropriate loader found.
            fclose(fh);
            if strcmp(head_struc.name,'horace')
                error('SQW_FILE_IO:runtime_error',...
                    ['get_loader: this Horace package does not support the sqw',...
                    ' file version %d found in file: %s\n',...
                    ' Update your Horace installation.'],...
                    head_struc.version,full_data_name);
            else
                error('SQW_FILE_IO:runtime_error',...
                    ['get_loader: Existing readers can not understand format of file: %s\n',...
                    ' Is it not a sqw file?'],...
                    full_data_name);
            end
            
        end
        %
        function loader = get_pref_access(obj,varargin)
            % return the version of the accessor recommended to write by
            % default or with particular type of sqw object provided as
            % argument
            %Usage:
            %>>loader = sqw_formats_factory.instance().get_pref_access();
            %           -- returns default accessor
            %>>loader = sqw_formats_factory.instance().get_pref_access('dnd')
            % or
            %>>loader = sqw_formats_factory.instance().get_pref_access('sqw')
            %         -- returns preferred accessor for dnd or sqw object
            %            correspondingly
            %
            %>>loader = sqw_formats_factory.instance().get_pref_access(object)
            %         -- returns preferred accessor for the object of type
            %            provided, where allowed types are sqw,dnd,d0d,d1d,d2d,d3d,d4d.
            %           Throws if type is not among the specified types.
            %
            [ok,mess,is_dnd,is_sqw,argi] =parse_char_options(varargin,{'dnd','sqw'});
            if ~ok
                error('SQW_FILE_IO:invalid_argument',mess);
            else
                if is_dnd && is_sqw
                    error('SQW_FILE_IO:invalid_argument',...
                        'get_pref_access: only "dnd" or "sqw" option can be provided but got both');
                end
                if ~is_dnd && ~is_sqw
                    is_sqw = true;
                end
            end
            if isempty(argi)
                if is_sqw
                    loader = obj.supported_accessors_{1};
                else
                    ld_num = obj.types_map_('dnd');
                    loader = obj.supported_accessors_{ld_num};
                end
            else
                if isa(argi{1},'sqw')
                    loader = obj.supported_accessors_{1};
                else
                    type = class(varargin{1});
                    if obj.types_map_.isKey(type)
                        ld_num = obj.types_map_(type);
                        loader = obj.supported_accessors_{ld_num};
                    else
                        error('SQW_FILE_IO:invalid_argument',...
                            'get_pref_access: input class %s does not have registered accessor',...
                            type)
                    end
                    
                end
            end
        end
        %
        function is_compartible = check_compartibility(obj,class1,class2)
            % check if second loader can be used to upgrade the first one
            %
            if isa(class2,class(class1))
                is_compartible = true;
                return
            end
            %type1 = class(class1);
            %type2 = class(class2);
            if isa(class1,'faccess_sqw_v2') && isa(class2,'faccess_sqw_v3')
                is_compartible = true;
            else
                is_compartible = false;
            end
        end
        
    end
end
