classdef sqw_formats_factory < handle
    % Provides and initializes appropriate sqw file accessor
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
    %
    properties(Access=private) %
        % List of registered file accessors:
        % Add all new file readers which inherit from sqw_file_interface and horace_binfile_interface
        % to this list in the order of expected frequency of their appearance.
        supported_accessors_ = { ...
            faccess_sqw_v4_1(),...
            faccess_sqw_v4(),...
            faccess_dnd_v4(),...
            faccess_sqw_v3_3(), ...
            faccess_sqw_v3(), ...
            faccess_sqw_v3_21(), ...
            faccess_sqw_v2(), ...
            faccess_dnd_v2(), ...
            faccess_sqw_v3_2(), ...
            faccess_sqw_prototype()};
        %------------------------------------------------------------------
        % Loader selection rules:
        %------------------------------------------------------------------
        % Number (in the registered accessors list) of file accessor
        % to choose for new binary files by defaul, when no input object is
        % provided
        preferred_accessor_num_ = 1;
        % Rules for saving different classes, defines the preferred loader
        % for saving the class from the list. The same as above but when a
        % object provided as input.
        written_types_ = {'DnDBase','sqw','sqw2','dnd','d0d','d1d','d2d','d3d','d4d'};
        % sqw2 corresponds to sqw file in indirect mode with efixed being
        % array.
        % number of loader in the list of loaders above to use for saving
        % class, defined by written_types_ string.
        access_to_type_ind_ = {3,1,1,3,3,3,3,3,3};
        types_map_ ;
    end
    properties(Dependent)
        % return list of the non-initialized accessor classes subscribed to
        % the factory
        supported_accessors
    end

    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton pattern.
        function obj = sqw_formats_factory()
            %sqw_formats_factory constructor: Initialize your custom properties.
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
        function loader = get_loader(obj,sqw_file_name,varargin)
            % Returns initiated loader which can load the data from the specified data file.
            %
            %Usage:
            %>>loader=loaders_factory.instance().get_loader(sqw_file_name);
            %>>loader=loaders_factory.instance().get_loader(sqw_file_name,'-update');
            %
            % where:
            %>>data_file_name  -- the name of the file, which is the source of the data
            %                     or the cellarray of such names.
            %                     If cellarray of the names provided, the method returns
            %                     cellarray of loaders.
            % Optional:
            % '-update'        -- if provided, open file for read/write/update
            %                     operations, unlike default opening file
            %                     for read access only
            %
            %
            % On error:      throws
            % HORACE:file_io:runtime_error exception with
            %                message, explaining the reason for error.
            %                The errors are usually caused by missing or
            %                not-recognized (non-sqw) input files.
            %
            loader = get_loader_(obj,sqw_file_name,varargin{:});
        end
        %
        function ver = last_version(obj)
            % return the version number of file accessor to use for new sqw
            % files.
            ver = obj.supported_accessors_{obj.preferred_accessor_num_}.faccess_version;
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
            loader = get_pref_access_(obj,varargin{:});
        end

        function set_pref_access(obj,type,facc_name)
            % method allows manually set preferable accessor for specific
            % object type. New accessor will be used until sqw_formats_factory is
            % loaded in memory and have not been updated.
            % Inputs:
            % obj     --  Instance of sqw_formats_factory
            % type    --  the class or the name of the class, one wants to
            %             set accessor for.
            %             The name of the class needs to be among the
            %             classes factory know how to save
            % facc_name
            %         -- name of file-accessor class to set as saver for
            %            the type provided or instance of this class.
            %            The class name have to be among the
            %            names of the registered accessors (classes present
            %            in obj.supported_accessors_ list.)
            % Empty facc_name string resets factory to its default values.
            %
            % Returns:
            % Modified sqw_formats_factory singleton with new file accessor
            % set as default for input type.
            % get_pref_access method invoked without parameters would also
            % return the file accessor, specified as input of this method.
            set_pref_accessor_(obj,type,facc_name);
        end
        %
        function is_compartible = check_compatibility(~,obj1,obj2)
            % Check if second loader can be used to upgrade the first one
            %
            %Usage:
            %is_com =sqw_formats_factory.instance().check_compatibility(obj1,obj2)
            %        where obj1 and obj2 are the instances of sqw-file
            %        accessors, known to the factory.
            %Returns:
            % is_compartible  -- true if position info of obj1 is compatible
            %        with pos_info stored in obj2 and is subset of position
            %        info of object 2
            %
            % currently returns true either for the same type of
            % accessors (class(obj1)==class(obj2))
            % or when
            % class(obj1) == 'faccess_sqw_v2' and class(obj2) == 'faccess_sqw_v3'.
            % or
            % when class(obj1) == faccess_sqw_v3_2 and class(obj2) == 'faccess_sqw_v3_21'.
            %
            %NOTE:
            % faccess_sqw_v3 is not compatible with faccess_sqw_v3_2 as
            % contains different information about detectors incident energies.
            if isa(obj2,class(obj1))
                is_compartible = true;
                return
            end
            if (isa(obj1,'faccess_sqw_v3')||isa(obj1,'faccess_sqw_v3.3')) ...
                    && isa(obj2,'faccess_sqw_v3_2')
                is_compartible = false;
            else
                is_compartible = true;
            end
        end
        %
        function obj_list = get.supported_accessors(obj)
            obj_list = obj.supported_accessors_;
        end
    end
    methods(Static)
        function [in_type,orig_type] = get_sqw_type(in_obj)
            % determine the type of sqw object based on data in the header
            % return value options are:
            %      in_type == 'none' - the header is empty, there is no efix/emode
            %                          data to determine the type
            %      in_type == 'sqw2' - the header has emode==2 and
            %                          numel(efix)>1
            %      in_type == 'sqw'  - none of the above so using the
            %                          class of obj i.e. sqw
            [in_type,orig_type] = get_sqw_type_(in_obj);
        end
    end
end
