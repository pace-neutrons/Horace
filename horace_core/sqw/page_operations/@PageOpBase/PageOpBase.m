classdef PageOpBase
    % PAGEOPBASE class defines interface to a generic operation, performed
    % on chunk of pixels located in memory by apply method of sqw/PixelData
    % objects.
    %
    % Operations are functions which modify pixels directly, e.g.
    % recalculating or modifying signal/variance.
    % PageOpBase does the work of calculating appropriate changes
    % to the image and providing a unified interface for
    % memory-/file-backed operations.
    %
    % IMPORTANT:
    % The operations can only be used by algorithms which do not change
    % the size and shape of the image.
    % In addition, the operation must not change pixel coordinates in a
    % way which would violate the relation between image and the pixels
    % i.e. alter which image bin a pixel would contribute.
    % i.e. require rebinning or reordering of pixels behind bins boundaries.
    properties(Dependent)
        % true if method should not create the copy of filebacked object
        % and does not change pixels.
        % TODO: Disabled, See Re #1319 to enable
        inplace
        % true if operation modifies PixelData only and does not affect
        % image. The majority of operations modify both pixels and image
        % Pixels only change in tests and in some pix-only operations
        % e.g. mask(Pixels)
        changes_pix_only;
        % while page operations occur, not every page operation should be
        % reported, as it could print too many logs. The property defines
        % how many page operations should be omitted until operation progress
        % is reported
        split_log_ratio
        % if provided, used as the name of the file for filebacked
        % operations
        outfile
        % property used in logs and returning the file name of the source data
        source_filename

        % number of page to operate over
        page_num
        % The name of the operation included in the progress log for slow
        % operations
        op_name
    end
    properties(Dependent,Hidden)
        % npix array (the same as img_.npix), containing the pixel distribution
        % over binning. If no binning is provided it is a single number equal
        % to number of pixels (all pixels in one bin)
        npix

        % caches for some indices, defined in PixelDataBase, and used to
        % extract appropriate fields from PixelData. Often used.
        signal_idx;
        var_idx;
        run_idx;
        coord_idx;
        % Exposes is_range_valid method of the pix_ field
        is_range_valid
        % if true, page operations should validate run_id and
        % avoid retaining runs, which do not contribute into pixels, which
        % was ocasionally happened with old file formats
        old_file_format
        %
        write_handle
        % An algorithm applied to a sqw object with missing data range
        % should issue warning that range is recalculated unless the
        % algorithm is the one which actually recalculates missing range.
        % No range warning should be generated for pixels only too.
        do_missing_range_warning;
    end


    properties(Access=protected)
        % true if operation should not create the copy of a filebacked
        % object
        inplace_ = false;
        % holder for the pixel object, which is source/target for the
        % operation
        pix_ = PixelDataMemory();
        % holder for the image, being modified by the operation(s).
        img_;
        % initial pixel range, recalculated according to the operation
        pix_data_range_ = PixelDataBase.EMPTY_RANGE;
        %
        outfile_   = '';
        op_name_ = '';
        split_log_ratio_ = [];

        % caches for some indices, defined in PixelDataBase, and used to
        % extract appropriate fields from PixelData
        signal_idx_;
        var_idx_;
        run_idx_;
        coord_idx_;

        % property holding the class used for writing modified data
        % into target location
        write_handle_ = [];

        % true, if data are loaded from old file format and need unique
        % pixel id recalculation during page operations.
        old_file_format_ = false;
        % result of unique pixel id recalculations
        unique_run_id_   = [];
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
    %======================================================================
    % Main operation methods
    methods
        function obj = PageOpBase(varargin)
            % Constructor for page operations
            %
            crd_idx = PixelDataBase.field_index({ ...
                'coordinates','run_idx','signal','variance'});
            obj.var_idx_    = crd_idx(end);
            obj.signal_idx_ = crd_idx(end-1);
            obj.run_idx_    = crd_idx(end-2);

            obj.coord_idx_  = crd_idx(1:end-3);

            if nargin == 0
                return;
            end
            obj = obj.init(varargin{:});
        end
        %
        function obj = init(obj,in_obj)
            % initialize page operation using parts of input sqw or
            % PixelData object as the target for the operation.
            if nargin == 1
                return;
            end
            obj = init_(obj,in_obj);
        end
        %
        function obj = common_page_op(obj)
            % Method contains the code which runs for any page operation,
            % inheriting from this one.
            %
            % Input:
            % obj   -- pageOp object, containing modified pixel_data page
            %          to analyse.
            %
            % Thought: May be should be implemented as apply_op, which needs
            %          to be overloaded and invoked as part of more complex
            %          page operation.
            %
            obj.pix_data_range_ = PixelData.pix_minmax_ranges(obj.page_data_, ...
                obj.pix_data_range_);
            if obj.old_file_format_
                obj.unique_run_id_ = unique([obj.unique_run_id_, ...
                    obj.page_data_(obj.run_idx_,:)]);
            end
            if ~obj.inplace_
                obj.pix_ = obj.pix_.store_page_data(obj.page_data_,obj.write_handle_);
            end
        end
        function obj = get_page_data(obj,idx,varargin)
            % return block of data used in page operation
            %
            % This is most common form of the operation. Some operations
            % will request overloading
            obj.pix_.page_num = idx;
            obj.page_data_ = obj.pix_.data;
        end
        %
        function [out_obj,obj] = finish_op(obj,in_obj)
            % Finalize page operations.
            %
            % Contains common code to transfer data changed by operation to
            % out_obj.   Need overloading for correct image calculations
            % and specifics of particular operation
            %
            % Input:
            % obj     -- instance of the page operations
            % in_obj  -- sqw object-source of the operation
            %
            % Returns:
            % out_obj -- sqw object created as the result of the operation
            % obj     -- nullified PageOp object.
            [out_obj,obj] = finish_op_(obj,in_obj);
        end
        %
        function [npix_chunks, npix_idx] = split_into_pages(~,npix,chunk_size)
            % Method used to split input npix array into pages
            % Inputs:
            % npix  -- image npix array, which defines the number of pixels
            %           contributing into each image bin and the pixels
            %           ordering in the linear array
            % chunk_size
            %       -- sized of chunks to split pixels
            % Returns:
            % npix_chunks -- cellarray, containing the npix parts
            % npix_idx    -- [2,n_chunks] array of indices of the chunks in
            %                the npix array.
            % See split procedure for more details
            [npix_chunks, npix_idx] = split_vector_fixed_sum(npix, chunk_size);
        end

    end
    %======================================================================
    % properties setters/getters
    methods
        function does = get.changes_pix_only(obj)
            does = get_changes_pix_only(obj);
        end
        function obj = set.changes_pix_only(obj,val)
            obj = set_changes_pix_only(obj,val);
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
        function in = get.inplace(obj)
            in = obj.inplace_;
        end
        function obj = set.inplace(obj,val)
            obj.inplace_ = logical(val);
        end
        %
        function does = get.split_log_ratio(obj)
            if isempty(obj.split_log_ratio_)
                does = config_store.instance().get_value( ...
                    'hor_config', 'fb_scale_factor');
            else
                does = obj.split_log_ratio_;
            end
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
            obj.npix_ = val(:)';
        end
        %
        function np = get.page_num(obj)
            np = obj.pix_.page_num;
        end
        function obj = set.page_num(obj,val)
            obj.pix_.page_num = val;
        end
        %------------------------------------------------------------------
        function fn = get.source_filename(obj)
            [~,fn,fe] = fileparts(obj.pix_.full_filename);
            fn = [fn,fe];
        end
        %
        function name = get.op_name(obj)
            name = obj.op_name_;
        end
        function obj = set.op_name(obj,val)
            if ~istext(val)
                error('HORACE:PageOpBase:invalid_argument', ...
                    'op_name can be a text string only. Provided %s', ...
                    class(val));
            end
            obj.op_name_ = val;
        end
        %
        function is  = get.is_range_valid(obj)
            is = obj.pix_.is_range_valid();
        end
        %
        function is = get.old_file_format(obj)
            is = obj.old_file_format_;
        end
        function wh = get.write_handle(obj)
            wh = obj.write_handle_;
        end
        %
        function do = get.do_missing_range_warning(obj)
            do = get_do_missing_range_warning(obj);
        end
    end
    %======================================================================
    methods(Static)
        function print_range_warning(op_name,infile_name,is_old_file_format)
            % print the warning informing user that the source file
            % contains invalid data range and file format should be
            % upgraded.
            % Input:
            % op_name     -- the name of operation which performs calculations
            % infile_name -- the name of the file-source of filebacked sqw
            %                object, which does not contain correct data
            %                range 
            % is_old_file_format
            %             -- true or false specifying the reason why the
            %                file does not have correct range and message, 
            %                suggesting best way to upgrade. 
            %        true -- the file does not have correct range due to
            %                old file format
            %        false-- the file does not contain correct data range
            %                because it has been realigned
            print_range_warning_(op_name,infile_name,is_old_file_format);
        end
    end
    %======================================================================
    methods(Access=protected)
        function  does = get_changes_pix_only(obj)
            does = isempty(obj.img_);
        end
        function obj = set_changes_pix_only(obj,varargin)
            % generally, ignored and based on image.
            % left for possibility to overload in children
        end

        function do = get_do_missing_range_warning(obj)
            do  = ~isempty(obj.img_);
        end

        function obj = update_image(obj,sig_acc,var_acc,npix_acc)
            % The piece of code which often but not always used at the end
            % of an operation when modified data get transformed from
            % accumulators to the final image finalizing the image
            % processing.
            %
            % Inputs:
            % sig_acc -- array accumulating changed signal during
            %            operation(s)
            % var_acc -- array accumulating changed variance during
            %            operation(s)
            % Optional:
            % npix_acc -- array accumulating changes in npix during
            %             operation(s)
            % Returns:
            % obj      -- operation object containing modified image, if
            %             image have been indeed modified
            obj = update_image_(obj,sig_acc,var_acc,npix_acc);
        end
    end
end
