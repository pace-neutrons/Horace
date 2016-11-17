classdef faccess_dnd_v2 < dnd_binfile_common
    % Class to access Horace dnd files written by Horace v1-v2
    %
    % The current sqw file format comes in two variants:
    %   - Horace version 1 and version 2: file format '-v2'
    %   (Autumn 2008 onwards). Does not contain instrument and sample fields in the header block.
    %
    %
    %
    % $Revision$ ($Date$)
    %
    %
    properties(Access = protected)
    end
    properties(Dependent)
    end
    
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
        function [should,objinit,mess]= should_load_stream(obj,stream,fid)
            % Check if this loader should load input data
            % Currently should any dnd object
            %Usage:
            %
            %>> [should,obj_init,mess] = obj.should_load_stream(datastream,fid)
            % where
            % datastream:  structure returned by get_file_header function
            % Returns:
            % true if the loader can load these data, or false if not
            % with message explaining the reason for not loading the data
            % of should, object is initiated by appropriate file identified
            mess = '';
            if isstruct(stream) && all(isfield(stream,{'sqw_type','version'}))
                if ~stream.sqw_type
                    objinit = obj_init(fid,double(stream.num_dim));
                    should = true;
                else
                    should = false;
                    mess = ['not Horace dnd  ',obj.file_version,' file'];
                    objinit  =obj_init();
                end
            else
                error('SQW_FILE_IO:invalid_argument',...
                    'FACCESS_DND_V2::should_load_stream: the input structure for this function does not have correct format');
            end
        end
        %
        %
    end
    
end
