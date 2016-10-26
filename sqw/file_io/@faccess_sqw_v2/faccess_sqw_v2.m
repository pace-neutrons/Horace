classdef faccess_sqw_v2 < sqw_binfile_common
    % Class to access sqw Horace files written by Horace v1-v2
    %
    % The current sqw file format comes in two variants:
    %   - Horace version 1 and version 2: file format '-v2'
    %   (Autumn 2008 onwards). Does not contain instrument and sample fields in the header block.
    %
    %
    %
    % $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
    %
    %
    properties(Access = protected)
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
            if nargin>0
                obj = obj.init(varargin{:});
            end
        end
        
        %
        %
    end
    
end

