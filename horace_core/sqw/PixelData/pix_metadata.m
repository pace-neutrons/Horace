classdef pix_metadata < serializable
    %PIX_METADATA The class contains information about sqw file pixels
    % including the way, pixels are stored on hdd
    %
    % The purpose of this class is help in storing pixel information
    % into custom binary file using different pixel file formats.
    %
    properties(Dependent)
        % Actual information, describing particular pixel data
        full_filename;   % full file name of the sqw file containing the pixels
        npix;
        pix_range; % 2x4 range of pixel coordinates, first part of data_range, left for compartibility
        data_range; % 2x9 range of all pixel data 
    end
    properties(Access=protected)
        full_filename_;
        npix_;
        data_range_ = PixelDataBase.EMPTY_RANGE;
        %
    end

    methods
        function obj = pix_metadata(varargin)
            %PIX_METADATA Construct an instance of metadata class
            %
            % the pix_metadata class can be constructed from input
            % field values (standard serializable constructor) or from
            % instance of PixelDataBase class
            if nargin == 0
                return;
            end
            if nargin == 1 && isa(varargin{1},'PixelDataBase')
                inputs = varargin{1};
                remains = varargin(2:end);
                obj.npix = inputs.num_pixels;
                obj.data_range     = inputs.data_range;
                obj.full_filename = inputs.full_filename;
            else
                flds = obj.saveableFields();
                [obj,remains] = obj.set_positional_and_key_val_arguments(...
                    flds,false,varargin{:});
            end
            if ~isempty(remains)
                error('HORACE:pix_metadata:invalid_argument',...
                    ' Class constructor has been invoked with non-recognized parameters: %s',...
                    disp2str(remains));
            end

        end
        %------------------------------------------------------------------
        function fn = get.full_filename(obj)
            % full name of the sqw file been accessed
            fn = obj.full_filename_;
        end
        function obj = set.full_filename(obj,val)
            % Name of sqw file that is being read, excluding path.
            if ~(ischar(val)||isstring(val))
                error('HORACE:pix_metadata:invalid_argument', ...
                    'The full_filename should be a string, describing path to the file. It is: %s', ...
                    disp2str(val));
            end
            obj.full_filename_ = val;
        end
        %
        function np = get.npix(obj)
            np = obj.npix_;
        end
        function obj = set.npix(obj,val)
            if ~(isnumeric(val)&&isscalar(val)&&val>=0)
                error('HORACE:pix_metadata:invalid_argument', ...
                    'The number of pixels should be single non-negative number. It is: %s', ...
                    disp2str(val));
            end
            obj.npix_ = val;
        end
        %
        function pr = get.pix_range(obj)
            pr = obj.data_range_(:,1:4);
        end
        function obj = set.pix_range(obj,val)
            if any(size(val) ~= [2,4])
                error('HORACE:pix_metadata:invalid_argument',...
                    'pixel_range should be [2x4] array');
            end
            obj.data_range_(:,1:4) = val;
        end
        function pr = get.data_range(obj)
            pr = obj.data_range_;
        end
        function obj = set.data_range(obj,val)
            if any(size(val) ~= [2,9])
                error('HORACE:pix_metadata:invalid_argument',...
                    'data_range should be [2x9] array');
            end
            obj.data_range_ = val;
        end

        %
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function flds = saveableFields(~)
            % Return cellarray of public property names, which fully define
            % the state of a serializable object, so when the field values are
            % provided, the object can be fully restored from these values.
            %
            flds = {'full_filename','npix','data_range'};
        end
    end
end