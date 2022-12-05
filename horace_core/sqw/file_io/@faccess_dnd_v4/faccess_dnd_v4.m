classdef faccess_dnd_v4 < binfile_v4_common
    % Class to access Horace dnd files written by Horace v4
    %
    % Majority of class properties and methods are inherited from <a href="matlab:help('dnd_binfile_common');">dnd_binfile_common</a>
    % class.
    %
    % Usage:
    % 1)
    %>>dnd_access = faccess_dnd_v4(filename)
    % or
    % 2)
    %>>dnd_access = faccess_dnd_v4(sqw_dnd_object,filename)
    %---------------------------------------------------------------
    %
    % 1)------------------------------------------------------------
    % First form initializes accessor to existing dnd file where
    % filename  :: the name of existing dnd file.
    %
    % Throws if file with filename is missing or is not written in dnd v1-v2 format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw file,
    % access to existing sqw files should be organized using sqw format factory
    % namely:
    %
    % >> accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is dnd v1 or v2 sqw file, the sqw format factory will
    % return instance of this class, initialized for reading the file.
    % The initialized object allows to use all get/read methods described by dnd_file_interface.
    %
    % 2)------------------------------------------------------------
    % Second form used to initialize the operation of writing new or updating existing dnd file.
    % where:
    % sqw_dnd_object:: existing fully initialized sqw or dnd object in memory.
    % filename      :: the name of a new or existing dnd object on disc
    %
    % Update mode is initialized if the file with name filename exists and can be updated,
    % i.e. has the same number of dimensions, binning and  axis. In this case you can modify
    % dnd metadata.
    %
    % if existing file can not be updated, it will be open in write mode.
    % If file with filename does not exist, the object will be open in write mode.
    %
    % Initialized faccess_dnd_v2 object allows to use write/update methods of dnd_format_interface
    % and all read methods if the proper information already exists in the file.
    %
    %
    %
    %
    methods
        function obj=faccess_dnd_v4(varargin)
            % constructor, to build sqw reader/writer version 2
            %
            % Usage:
            % ld = faccess_dnd_v4() % initialize empty sqw reader/writer version 2
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_dnd_v4(filename) % initialize sqw reader/writer  version 2
            %                       to load sqw file version 2.
            %                       Throw error if the file version is not sqw
            %                       version 2.
            % ld = faccess_dnd_v4(dnd_object) % initialize sqw reader/writer version 2
            %                       to save dnd object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            %
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end        
        %
    end
    methods(Access=protected)
        function is_sqw = get_sqw_type(~)
            % Main part of get.sqw_type accessor
            % return true if the loader is intended for processing sqw file
            % format and false otherwise
            is_sqw = true;
        end
        
    end
    
end
