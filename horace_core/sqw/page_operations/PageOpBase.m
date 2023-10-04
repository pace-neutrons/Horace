classdef PageOpBase
    %PAGEOPBASE class defines generic operation, performed on chunk of pixels
    % located in memory.
    %
    % An operation normally consists of doing something with pixels and
    % calculating appropriate avarages to image.
    properties(Dependent)
        % true if operation modifies PixelData only and does not affect
        % image. The majority of operations modify both pixels and image
        % Pixels only change in tests and in some pix-only operations
        % e.g. recalc_pix_range
        changes_pix_only;
        % while page operations occur, not every page operation should be
        % reported, as it could be too many logs. The property defines
        % how many pages should be omitted until page progress is reported
        split_log_ratio
        % if provided, used as the name of the file for filebacked
        % operations
        outfile
        % number of page to operate over
        page_num
    end
    properties(Dependent,Hidden)
        % npix array (the same as img_.npix), containing the pixel distribution
        % over binning. If no binning is provided it is single number equal
        % to number of pixels
        npix

        % caches for some indices, defined in PixelDataBase, and used to
        % extract appropriate fieds from PixelData. Often used.
        signal_idx;
        var_idx;
        coord_idx;
    end


    properties(Access=protected)
        % holder for the pixel object, which is source/target for the
        % operation
        pix_ = PixelDataMemory();
        % holder for the image, beeing modified by the operation(s).
        img_;
        % initial pixel range, recalculaed according to the operation
        pix_data_range_ = PixelDataBase.EMPTY_RANGE;
        %
        outfile_   = '';
        split_log_ratio_  = 10;

        % caches for some indices, defined in PixelDataBase, and used to extract
        % appropriate fieds from PixelData
        signal_idx_;
        var_idx_;
        coord_idx_;

        % holder for npix value, defining the ordering of the pixels
        % according to bins
        npix_ = [];

        % the data holder for a page of operation-modified pixels data
        page_data_;
        % accumulator for processed signal. All operations change signal
        % some may define more accumulators
        sig_acc_
        % variance accumulator. Many operations recalculate variance.
        % Do not forget to nullify it if your particular operation does it
        var_acc_
    end
    methods(Abstract)
        % Specific apply operation method, which need overloading
        % over
        [obj,page_data] = apply_op(obj,npix_block,npix_idx);
        %
    end

    methods
        function obj = PageOpBase(varargin)
            % Constructor for page operations
            %
            obj = obj.init(varargin{:});
        end
        function [obj,in_obj] = init(obj,in_obj)
            % initialize page operation using parts of input sqw or
            % PixelData object as the target for the operation.
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
                obj.pix_              = in_obj;
                obj.img_              = [];
            elseif isa(in_obj,'sqw')
                obj.img_              = in_obj.data;
                obj.pix_              = in_obj.pix;
                obj.npix_             = obj.img_.npix;
                %
                obj.sig_acc_ = zeros(numel(obj.img_.npix),1);
            else
                error('HORACE:PageOpBase:invalid_argument', ...
                    'Init method accepts PixelData or SQW object input only. Provided %s', ...
                    class(in_obj))
            end
        end
        %
        function obj = common_page_op(obj)
            % Method contains the code which runs for any page operation,
            % inheriting from this one. 
            %
            % Input:
            % obj   -- pageOp object, containing modified pixel_data page
            %          to analyze.
            %
            % Thought: May be should be implemented as page_op, which needs
            %          to be overloaded and invoked as part of more complex
            %          page operation. 
            %
            obj.pix_data_range_ = PixelData.pix_minmax_ranges(obj.page_data_, ...
                obj.pix_data_range_);
            obj.pix_ = obj.pix_.format_dump_data(obj.page_data_);
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            % Finalize page operations. 
            % 
            % Contains common code to transfer data from operation to
            % out_obj and  Need overloading for correct image calculations
            %
            % Input:
            % obj     -- instance of the page operations
            % in_obj  -- sqw object-source of the operation
            %
            % Returns:
            % out_obj -- sqw object created as the result of the operation
            % obj     -- nullified PageOp object.

            pix = obj.pix_;
            % clear alignment (if any) as alignment has been applied during
            % page operation(s)
            pix = pix.clear_alignment();
            %
            pix     = pix.set_data_range(obj.pix_data_range_);
            pix     = pix.finish_dump();

            if isempty(obj.img_)
                out_obj = pix.copy();
            else
                out_obj = in_obj.copy();
                out_obj.pix  = pix;
                % image should be recaculated by method overload.
                out_obj.data = obj.img_;
                if ~isempty(pix.full_filename)
                    out_obj.full_filename = pix.full_filename;
                end
            end
            obj.pix_  = PixelDataMemory();
            obj.img_  = [];
            obj.npix_ = [];
        end
        %
    end
    %======================================================================
    % properties setters/getters
    methods
        function does = get.changes_pix_only(obj)
            does = isempty(obj.img_);
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
        function does = get.split_log_ratio(obj)
            does = obj.split_log_ratio_;
        end
        function obj = set.split_log_ratio(obj,val)
            if ~isnumeric(val)
                error('HORACE:PageOpBase:invalid_argument', ...
                    'log_split_ratio can have only numeric value. Provided: %s', ...
                    class(val))
            end
            obj.split_log_ratio_ = max(1,round(abs(val)));
        end
        %------------------------------------------------------------------
        function npix = get.npix(obj)
            if isempty(obj.npix_)
                npix = obj.pix_.num_pixels;
            else
                npix = obj.npix_;
            end
        end
        function obj = set.npix(obj,val)
            if ~isnumeric(val)
                error('HORACE:PageOpBase:invalid_argument', ...
                    'npix value have to be numeric. It is: %s', ...
                    class(val));
            end
            obj.npix_ = val;
        end
        %
        function np = get.page_num(obj)
            np = obj.pix_.page_num;
        end
        function obj = set.page_num(obj,val)
            obj.pix_.page_num = val;
        end
    end
end