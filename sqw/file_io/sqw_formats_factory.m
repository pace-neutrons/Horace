classdef sqw_formats_factory < handle
    % Provides and initialises appropriate sqw file accessor
    % given sqw file name or preferred sqw file accessor
    % for given sqw/dnd object or sqw/dnd object type.
    %
    % sqw file accessor is used to read/write the whole or partial sqw data
    % from/to a various sqw format file(s).
    %
    % Usage:
    %>> accessor = sqw_formats_factory.instance().get_loader(filename)
    % Get appropriate accessor to read sqw/dnd data from disk
    % or:
    %>> accessor = sqw_formats_factory.instance().get_pref_access(sqw/dnd object)
    % Get appropriate accessor to write sqw/dnd data to hdd.
    % The accessor has to be initialized later (see details in the method description
    % and accessors init method.)
    %
    %sqw_formats_factory Methods:
    % instance      - main method to access unique instance of the factory
    %                  (singleton).
    %
    %User methods:
    % get_loader  -     returns loader suitable for to get data from the file
    %                   with the name provided.
    % get_pref_access - returns non-initialized accessor appropriate to
    %                   save the type of data provided as input.
    %
    %Developers method:
    % check_compatibility - verifies if position info from one sqw file accessor can be
    %                       used to initialize another accessor.
    %
    %
    % $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
    %
    properties(Access=private) %
        % List of registered file accessors:
        % Add all new file readers which inherit from sqw_file_interface and dnd_file_interface
        % to this list in the order of expected frequency of their appearance.
        supported_accessors_ = {faccess_sqw_v3(),faccess_sqw_v3_2(),...
            faccess_sqw_v2(),faccess_dnd_v2(),faccess_sqw_prototype()};
        %
        % Old class interface:
        % classes to load/save
        % sqw2 corrseponds to sqw file in indirect mode with varying efixed
        written_types_ = {'sqw','sqw2','dnd','d0d','d1d','d2d','d3d','d4d'};
        % number of loader in the list of loaders to use with correspondent class
        access_to_type_ind_ = {1,2,4,4,4,4,4,4};
        types_map_ ;
    end
    
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton pattern.
        function obj = sqw_formats_factory()
            %sqw_formats_factory constructor: Initialise your custom properties.
            obj.types_map_= containers.Map(obj.written_types_ ,...
                obj.access_to_type_ind_);
        end
    end
    
    methods(Static)
        % Concrete implementation.
        function obj = instance()
            % return single global initialized instance of this class
            % (singleton instance)
            %
            % The class is a singleton and calling this function is
            % the only way to access the public class methods.
            % e.g.:
            %>>ld = sqw_formats_factory.instance().get_loader(filename)
            %
            % returns initialized loader
            %
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
            % Returns initiated loader which can load the data from the specified data file.
            %
            %Usage:
            %>>loader=loaders_factory.instance().get_loader(sqw_file_name);
            %
            % where:
            %>>data_file_name  -- the name of the file, which is the source of the data
            %                     or the cellarray of such names.
            %                     If cellarray of the names provided, the method returns
            %                     cellarray of loaders.
            %
            % On error throws SQW_FILE_IO:runtime_error exception with message, explaining the reason for error.
            %                    The errors are usually caused by missing or not-recognized (non-sqw) input files.
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
            % Returns the version of the accessor recommended to use for writing sqw files
            % by default or accessor necessary for writing the particular class provided as
            % input.
            %
            %Usage:
            %>>loader = sqw_formats_factory.instance().get_pref_access();
            %           -- returns default accessor suitable for most files.
            %>>loader = sqw_formats_factory.instance().get_pref_access('dnd')
            % or
            %>>loader = sqw_formats_factory.instance().get_pref_access('sqw')
            %         -- returns preferred accessor for dnd or sqw object
            %            correspondingly
            %
            %>>loader = sqw_formats_factory.instance().get_pref_access(object)
            %         -- returns preferred accessor for the object of type
            %             provided, where allowed types are sqw,dnd,d0d,d1d,d2d,d3d,d4d.
            %
            %            Throws 'SQW_FILE_IO:invalid_argument' if the type
            %            is not among the types specified above.
            %
            if ischar(varargin{1})
                the_type = varargin{1};
            else
                the_type = class(varargin{1});
                if isa(varargin{1},'sqw')
                    sobj = varargin{1};
                    header =sobj.header;
                    if iscell(header)
                        header = header{1};
                    end
                    emode = header.emode;                    
                    if emode == 2
                        nefix = numel(header.efixed);
                        if nefix>1
                            the_type = 'sqw2';
                        end
                    end
                end
            end
            if obj.types_map_.isKey(the_type)
                ld_num = obj.types_map_(the_type);
                loader = obj.supported_accessors_{ld_num};
            else
                error('SQW_FILE_IO:invalid_argument',...
                    'get_pref_access: input class %s does not have registered accessor',...
                    the_type)
            end
        end
        %
        function is_compartible = check_compatibility(obj,obj1,obj2)
            % Check if second loader can be used to upgrade the first one
            %
            %Usage:
            %is_com =sqw_formats_factory.instance().check_compatibility(obj1,obj2)
            %        where obj1 and obj2 are the instances of sqw-file
            %        accessors, known to the factory.
            %
            % is_com is true if position info of obj1 is compatible with
            %        pos_info stored in obj2 and is subset of position
            %        info of object 2
            %
            % currently returns true either for the same type of
            % accessors (class(obj1)==class(obj2)) or when
            % class(obj1) == 'faccess_sqw_v2' and class(obj2) == 'faccess_sqw_v3'.
            % 
            %NOTE: 
            % faccess_sqw_v3 is not compartible with faccess_sqw_v3_2 as
            % contains different information about detectors.
            if isa(obj2,class(obj1))
                is_compartible = true;
                return
            end
            if isa(obj1,'faccess_sqw_v2') && isa(obj2,'faccess_sqw_v3')
                is_compartible = true;
            else
                is_compartible = false;
            end
        end
        
    end
end
