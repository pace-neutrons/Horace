classdef faccess_sqw_v2 < sqw_binfile_common
    % Class to access sqw Horace files written by Horace v1-v2
    %
    %
    % Usage:
    %1)
    %>>sqw_access = faccess_sqw_v2(filename)
    % or
    % 2)
    %>>sqw_access = faccess_sqw_v2(sqw_dnd_object,filename)
    %
    % 1)
    % First form initializes accessor to existing sqw file where
    % @param filename  :: the name of existing sqw file written in sqw v2 format.
    %
    % Throws if file with filename is missing or is not written in sqw v1-v2 format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw file,
    % access to existing sqw files should be organized using sqw format factory
    % namely:
    %
    % >>accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is sqw v2 sqw file (or v3.0, see note below), the
    % sqw_formats_factory will return instance of this class, initialized for reading this file.
    %
    % The initialized object allows to use all get/read methods described by sqw_file_interface
    % and dnd_file_interface
    %
    % 2)
    % Second form used to initialize the operation of writing new or updating existing sqw file.
    % where:
    %@param sqw_dnd_object:: existing fully initialized sqw object in memory.
    %@param filename      :: the name of a new or existing sqw object on disc
    %
    % Update mode is initialized if the file with name filename exists and can be updated,
    % i.e. has the same number of dimensions, binning axis and pixels. In this case you can modify
    % dnd or sqw methadata or explicitly overwrite pixels.
    %
    % If existing file can not be updated, it will be open in write mode.
    % If file with filename does not exist, the object will be open in write mode.
    %
    % Initialized faccess_sqw_v2 object allows to use write/update methods of dnd_file_interface
    % or sqw_file_interface and all read methods of these interfaces if the proper information
    % already exists in the file.
    %
    % Note:
    % The current sqw file format comes in two variants:
    %   - Horace version 1 and version 2: file format '-v2'
    %   (Autumn 2008 onwards). Does not contain instrument and sample fields in the header block.
    %
    % There also transitional v3.0 sqw files, which contain the same as v2 files information and
    % are treated as v2 format files. sqw_formats_factory returns this loader to access such files.
    %
    %
    % $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
    %
    %
    properties(Access = protected)
    end
    methods(Access=protected)
    end
    
    methods
        function obj=faccess_sqw_v2(varargin)
            % constructor, to build sqw reader/writer version 2
            %
            % Usage:
            % ld = faccess_sqw_v2() % initialize empty sqw reader/writer version 2
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_sqw_v2(filename) % initialize sqw reader/writer  version 2
            %                       to load sqw file version 2.
            %                       Throw error if the file version is not sqw
            %                       version 2.
            % ld = faccess_sqw_v2(sqw_object) % initialize sqw reader/writer version 2
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            %
            obj.sqw_type_ = true;
            if nargin >0
                obj = obj.init(varargin{:});
            end
        end
        %
        function [should,objinit,mess]= should_load_stream(obj,header,fid)
            % Check if faccess_sqw_v2 loader should process selected input data
            % file.
            %
            %Usage:
            %>> [should,objinit,mess] = obj.should_load_stream(head_struc,fid)
            % where:
            % head_struc:  structure returned by dnd_file_interface.get_file_header
            %              static method and containing sqw/dnd file info, stored in
            %              the file header
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
            if isstruct(header) && all(isfield(header,{'sqw_type','version'}))
                if header.sqw_type && ( header.version == 2 || header.version == 3 || header.version==1)
                    objinit = obj_init(fid,double(header.num_dim));
                    should = true;
                    if header.version == 3
                        warning('SQW_FILE_IO:legacy_data',...
                            ['should_load_stream -- Legacy sqw file version 3.0 has been discovered.\n'...
                            'Loading it as sqw version 2 file with instrument/sample block ignored'])
                    end
                else
                    should = false;
                    objinit  = obj_init();
                    mess = ['not Horace sqw  ',obj.file_version,' file'];
                end
            else
                error('SQW_FILE_IO:invalid_argument',...
                    'should_load_stream -- The input structure does not have correct format');
            end
        end
        %
        function new_obj = upgrade_file_format(obj)
            % Upgrade file from format 2 to format 3
            new_obj = upgrade_file_format_(obj);
        end
        
        
        %
        %
    end
    
end
