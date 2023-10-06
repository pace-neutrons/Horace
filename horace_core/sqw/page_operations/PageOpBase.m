classdef PageOpBase
    % PAGEOPBASE class defines interface to a generic operation, performed
    % on chunk of pixels located in memory by apply method of sqw/PixelData
    % objects.
    %
    % Operations are functions which modify pixels directly, e.g.
    % recalculating or modifying signal/variance.
    % PageOpBase does the work of calculating appropriate changes
    % to the image and providing a unified interface for
    % memory-/file-backed data.
    %
    % IMPORTANT:
    % The operations can only be used by algorithms which do not change
    % the size and shape of the image.
    % In addition, the operation must not change pixel coordinates in a
    % way which would violate the relation between image and the pixels
    % i.e. alter which image bin a pixel would contribute 
    % i.e. require rebinning or reordering of pixels behind bins boundaries.
    properties(Dependent)
        % true if operation modifies PixelData only and does not affect
        % image. The majority of operations modify both pixels and image
        % Pixels only change in tests and in some pix-only operations
        % e.g. mask(Pixels)
        changes_pix_only;
        % while page operations occur, not every page operation should be
        % reported, as it could be too many logs. The property defines
        % how many pages should be omitted until page progress is reported
        log_split_ratio
        % if provided, used as the name of the file for filebacked
        % operations
        outfile

        signal_idx;
        var_idx;
        coord_idx;
    end
    properties(Dependent,Hidden)
        % special property, containing pixels ordering when masking pixels
        % only
        npix
    end


    properties(Access=protected)
        % holder for the pixel object, affected by the operation
        pix_;
        % holder for the image, modified by the operation.
        img_;
        % initial pixel range, recalculaed according to the operation
        pix_data_range_ = PixelDataBase.EMPTY_RANGE;
        %
        outfile_   = '';
        changes_pix_only_ = false;
        log_split_ratio_  = 10;

        signal_idx_;
        var_idx_;
        coord_idx_;

        npix_ = [];
    end
    methods(Abstract)
        % Specific apply operation method, which need overloading
        % over
        [obj,page_data] = apply_op(obj,npix_block,npix_idx,pix_id_first,pix_id_last);
        %
        % page_data -- block of pixel data modified by the operation
    end

    methods
        function obj = PageOpBase(varargin)
            % Constructor for page operations
            %
            if nargin == 0
                return;
            end
            obj = obj.init(varargin{:});
        end
        function [obj,in_obj] = init(obj,in_obj)
            if nargin == 1
                return;
            end
            crd_idx = PixelDataBase.field_index({'coordinates','signal','variance'});
            obj.signal_idx_ = crd_idx(end-1);
            obj.var_idx_    = crd_idx(end);
            obj.coord_idx_  = crd_idx(1:end-2);

            %
            in_obj = in_obj.get_new_handle(obj.outfile);
            if isa(in_obj ,'PixelDataBase')
                obj.changes_pix_only_ = true;
                obj.pix_              = in_obj;
            elseif isa(in_obj,'sqw')
                obj.changes_pix_only_ = false;
                obj.img_              = in_obj.data;
                obj.pix_              = in_obj.pix;
            else
                error('HORACE:PageOpBase:invalid_argument', ...
                    'Init method accepts PixelData or SQW object input only. Provided %s', ...
                    class(in_obj))
            end
        end
        %
        function obj = common_page_op(obj,page_data)
            % method performed for any page operations.
            %
            % Input:
            % page_data -- array of PixelData
            %
            obj.pix_data_range_ = PixelData.pix_minmax_ranges(page_data, ...
                obj.pix_data_range_);
            obj.pix_ = obj.pix_.format_dump_data(page_data);
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            % Finalize page operations.
            % Input:
            % obj     -- instance of the page operations
            % in_obj  -- sqw object-source of the operation
            %
            % Returns:
            % out_obj -- sqw object created as the result of the operation
            % obj     -- nullified PageOp object.

            pix = obj.pix_;
            % clear alignment as it has been applied during page
            % operation(s)
            pix     = pix.clear_alignment();
            pix     = pix.set_data_range(obj.pix_data_range_);
            pix     = pix.finish_dump();

            if isempty(obj.img_)
                out_obj = pix.copy();
            else
                out_obj = in_obj.copy();
                out_obj.pix  = pix;
                out_obj.data = obj.img_;
                if ~isempty(pix.full_filename)
                    out_obj.full_filename = pix.full_filename;
                end
            end
            obj.pix_  = [];
            obj.img_  = [];
            obj.npix_ = [];
        end
        %
    end
    %======================================================================
    % properties setters/getters
    methods
        function does = get.changes_pix_only(obj)
            does = obj.changes_pix_only_;
        end
        %
        function name = get.outfile(obj)
            name = obj.outfile_;
        end
        function obj = set.outfile(obj,val)
            if isempty(val)
                obj.outfile_ = '';
                return
            end
            if ~istext(val)
                error('HORACE:PageOpBase:invalid_argument', ...
                    'outfile type can be only string or char. Provided: %s', ...
                    class(val));
            end
            obj.outfile_ = val;
        end
        %
        function idx = get.signal_idx(obj)
            idx = obj.signal_idx_;
        end
        function idx = get.var_idx(obj)
            idx = obj.var_idx_;
        end
        function idx = get.coord_idx(obj)
            idx = obj.coord_idx_;
        end
        %
        function does = get.log_split_ratio(obj)
            does = obj.log_split_ratio_;
        end
        function obj = set.log_split_ratio(obj,val)
            if ~isnumeric(val)
                error('HORACE:PageOpBase:invalid_argument', ...
                    'log_split_ratio can have only numeric value. Provided: %s', ...
                    class(val))
            end
            obj.log_split_ratio_ = round(abs(val));
            if obj.log_split_ratio_ <1
                obj.log_split_ratio_ = 1;
            end
        end
        %------------------------------------------------------------------
        function npix = get.npix(obj)
            if isempty(obj.npix_)
                if isempty(obj.pix_)
                    npix = [];
                else
                    npix = obj.pix_.num_pixels;
                end
            else
                npix = obj.npix_;
            end
        end
        function obj = set.npix(obj,val)
            obj.npix_ = val;
        end
    end
end