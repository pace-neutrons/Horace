classdef pix_data < serializable
    %PIX_DATA The class wraps pixel_data arrays and is used for serializing
    % PixelData into sqw binary files or matlab .mat files
    %
    % The purpose of this class is to help in storing/restoring pixel data
    % into custom binary file using different pixel file formats.
    %
    properties(Dependent)
        npix;   % Number of pixels, stored in the the pixels data block
        n_rows  % Number of rows in pixel data array
        data;  % data array block
        offset;
    end

    properties(Access=protected)
        npix_;
        num_pix_fields_ = 9;
        data_ = [];
        offset_ = 0;
    end


    methods
        function obj = pix_data(varargin)
            %PIX_DATA Construct an instance of pix_data class
            %
            % the pix_data class can be constructed from input
            % field values (standard serializable constructor) or from
            % instance of PixelDataBase class
            if nargin == 0
                return;
            elseif nargin == 1
                remains = {};
                inputs = varargin{1};
                if isa(varargin{1},'PixelDataMemory')
                    obj.data = inputs.data;
                elseif isa(varargin{1},'PixelDataFileBacked')
                    obj.npix = inputs.num_pixels;
                    obj.data = inputs.full_filename;
                    obj.offset = inputs.offset;
                elseif isa(varargin{1},'pix_combine_info')
                    obj.npix = inputs.num_pixels;
                    obj.data = inputs.full_filename;
                else
                    remains = inputs;
                end
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

        function rd = get.n_rows(obj)
            rd = obj.num_pix_fields_;
        end

        function obj = set.n_rows(obj,val)
            if ~(isnumeric(val)&&isscalar(val)&&val>=0)
                error('HORACE:pix_metadata:invalid_argument', ...
                    'The number of pixels rows should be single non-negative number. It is: %s', ...
                    disp2str(val));
            end
            obj.num_pix_fields_ = val;
        end

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

        function dat = get.data(obj)
            dat  = obj.data_;
        end

        function obj = set.data(obj,val)
            % should be also setter from filename, used for setting
            % filebased data
            if isnumeric(val)
                if isempty(val)
                    obj.npix_ = 0;
                    obj.data_ = [];
                else
                    obj.data_ = val;
                    obj.num_pix_fields_ = size(val,1);
                    obj.npix_           = size(val,2);
                end
            elseif ischar(val)||isstring(val)
                obj.data_ = val;
            else
                error('HORACE:pix_metadata:invalid_argument', ...
                    'The data field should be either numeric array describing pixel data in memory or character string, describing the location of filebased class. Actually, its class is: %s, size: %s', ...
                    class(val),disp2str(size(val)));
            end
        end

        function np = get.offset(obj)
            np = obj.offset_;
        end

        function obj = set.offset(obj,val)
            if ~(isnumeric(val) && isscalar(val) && val>=0)
                error('HORACE:pix_metadata:invalid_argument', ...
                    'The offset should be a non-negative scalar number. It is: %s', ...
                    disp2str(val));
            end
            obj.offset_ = val;
        end


    end

    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function ver  = classVersion(~)
            ver = 1;
        end

        function flds = saveableFields(obj)
            % Return cellarray of public property names, which fully define
            % the state of a serializable object, so when the field values are
            % provided, the object can be fully restored from these values.
            %
            flds = {'data','npix','n_rows','offset'};
        end
    end
end
