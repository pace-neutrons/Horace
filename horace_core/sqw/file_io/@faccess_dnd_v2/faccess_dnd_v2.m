classdef faccess_dnd_v2 < dnd_binfile_common
    % Class to access Horace dnd files written by Horace v1-v2
    %
    % Majority of class properties and methods are inherited from <a href="matlab:help('dnd_binfile_common');">dnd_binfile_common</a>
    % class.
    %
    % Usage:
    % 1)
    %>>dnd_access = faccess_dnd_v2(filename)
    % or
    % 2)
    %>>dnd_access = faccess_dnd_v2(sqw_dnd_object,filename)
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
    % $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
    %
    %
    methods
        function obj=faccess_dnd_v2(varargin)
            % constructor, to build sqw reader/writer version 2
            %
            % Usage:
            % ld = faccess_dnd_v2() % initialize empty sqw reader/writer version 2
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_dnd_v2(filename) % initialize sqw reader/writer  version 2
            %                       to load sqw file version 2.
            %                       Throw error if the file version is not sqw
            %                       version 2.
            % ld = faccess_dnd_v2(dnd_object) % initialize sqw reader/writer version 2
            %                       to save dnd object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            %
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        %
        function [should,objinit,mess]= should_load_stream(obj,head_struc,fid)
            % Check if faccess_dnd_v2 loader should process selected input data
            % file.
            %
            %Usage:
            %>> [should,objinit,mess] = obj.should_load_stream(head_struc,fid)
            % where:
            % head_struc:: structure returned by dnd_file_interface.get_file_header
            %              static method and containing sqw/dnd file info, stored in
            %              the file header.
            % fid       :: file identifier of already opened binary sqw/dnd file where
            %              head_struct has been read from.
            %
            % Returns:
            % should  :: boolean equal to true if the loader can load these data,
            %            or false if not.
            % objinit :: initialized helper obj_init class, containing information,
            %            necessary to initialize the loader.
            % message :: if false, contains detailed information on the reason
            %            why this file should not be loaded by this loader.
            %            Empty, if should == true.
            mess = '';
            if isstruct(head_struc) && all(isfield(head_struc,{'sqw_type','version'}))
                if ~head_struc.sqw_type
                    objinit = obj_init(fid,double(head_struc.num_dim));
                    should = true;
                else
                    should = false;
                    mess = ['not Horace dnd  ',obj.file_version,' file'];
                    objinit  =obj_init();
                end
            else
                error('SQW_FILE_IO:invalid_argument',...
                    'should_load_stream: the input structure for this function does not have correct format');
            end
        end
        %
        %
    end
    
end

