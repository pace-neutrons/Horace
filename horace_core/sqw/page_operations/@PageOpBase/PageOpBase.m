classdef PageOpBase
    % PAGEOPBASE class defines interface to a generic operation, performed
    % on chunk of pixels located in memory by apply_op method of sqw/PixelData
    % objects.
    %
    % Operations are functions which modify pixels directly, e.g.
    % recalculating or modifying signal/variance or adding/removing pixels
    % to existing bins.
    %
    % PageOpBase does the work of loading block of pixels in memory,
    % calculating appropriate changes to the image and storing the result
    % within correct parts of the target object. It also provides a unified
    % interface for performing memory-/file-backed page operations.
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
        % Almost opposite to change_pix_only as PageOp modifies image only.
        % Pixels which may be modified by the operation are discarded and
        % only image, calculated from modified pixels is returned. The
        % operation itself would return dnd object constructed from sqw
        % object modified by operation.
        do_nopix
        % while page operations occur, not every page operation should be
        % reported, as it could print too many logs. The property defines
        % how many page operations should be omitted until operation progress
        % is reported
        split_log_ratio
        % if provided, used as the name of the file for filebacked
        % operations
        outfile
        % When pageop algorithm produces filebacked result and this option
        % is true it returns its result as filebacked sqw object. If this
        % option is set to false output is not initialized and return is
        % empty. Indirectly controls if output is tmp object, as if it is
        % false it should not be tmp which destroyed when out object goes
        % out of scope
        init_filebacked_output
        % property used in logs and returning the file name of the source data
        source_filename

        % The name of the operation included in the progress log for slow
        % operations
        op_name

        % npix array (the same as img_.npix, but 1D), containing the pixel
        % distribution over binning. If no binning is provided it is a
        % single number equal to number of pixels (all pixels in one bin)
        npix
        % Property defines necessary way to split pixels data. Many
        % algorithms reque pages to be divided on image bin boundaries,
        % which may lead to pages not fitting to memory, but some do not
        % need this, so you can cut into pages with equal number of pixels
        % and handle any bin distribution.
        split_at_bin_edges
    end
    properties(Dependent,Hidden)
        % number of page to operate over
        page_num

        % caches for some indices, defined in PixelDataBase, and used to
        % extract appropriate fields from PixelData. Often used.
        signal_idx
        var_idx
        run_idx
        coord_idx
        % Exposes is_range_valid method of the pix_ field
        is_range_valid
        % if true, page operations should validate run_id and
        % avoid retaining runs, which do not contribute into pixels, which
        % was ocasionally happened with old file formats or may occur for
        % algorithms, which reduce number of pixels (mask, section)
        old_file_format
        % true if algorithm modifies Experiment and new experiment should be
        % stored. Transient property. Something more generic should be
        % implemented with Re #1446
        exp_modified

        % variable containing class, responsible for write operations.
        write_handle
        % An algorithm applied to a sqw object with missing data range
        % should issue warning that range is recalculated unless the
        % algorithm is the one which actually recalculates missing range.
        % No range warning should be generated for pixels only too.
        do_missing_range_warning;
        % expose current page of data used/processed by  the algorithm
        % Used in tests
        page_data
        % if true, page_op completed on filebacked object prints the name
        % of the file backing this object.
        inform_about_target_file
        % read-only. expose source pixels array object, cached by the
        % operation
        pix
    end

    properties(Access=protected)
        % true if operation should not create the copy of a filebacked
        % object
        inplace_ = false;
        % true if user wants to get only modified dnd object, ignoring
        % changes in pixels
        do_nopix_ = false;
        % holder for the pixel object which is source and sometimes target
        % for the operation
        pix_ = PixelDataMemory();
        % holder for the target image, being modified by the operation(s).
        img_;
        % initial pixel range, recalculated according to the operation
        pix_data_range_ = PixelDataBase.EMPTY_RANGE;
        %
        outfile_   = '';
        op_name_ = '';
        split_log_ratio_ = 1;

        % caches for some frequently used indices, defined in PixelDataBase,
        % and used to extract appropriate fields from PixelData
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
        % some may define and use more accumulators
        sig_acc_
        % variance accumulator. Many operations recalculate variance.
        % Do not forget to initialize and nullify it if your particular
        % operation uses it.
        var_acc_
        % true if data need to be split at bin edges (and bins are
        % present)
        split_at_bin_edges_ = false;
        % counter of pix position when the operation is split at bin edges
        pix_idx_start_
        % if true, page_op completed on filebacked object prints the name
        % of the file backing this object.
        inform_about_target_file_ = true;
        % if true, intiialize filebacked output sqw object
        init_filebacked_output_ = false;
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
            obj.pix_idx_start_ = 1;
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
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
            if obj.split_at_bin_edges_
                [npix_chunks, npix_idx] = split_vector_max_sum(npix, chunk_size);
                chunk_sizes = cellfun(@(ch)sum(ch),npix_chunks);
                [mchs,fb] = config_store.instance().get_value( ...
                    'hor_config','mem_chunk_size','fb_scale_factor');
                mb_max = mchs*fb;
                if any(chunk_sizes>mb_max)
                    warning('HORACE:runtime_error', ['\n' ...
                        '*** The algorithm %s request input sqw object to be split on bin boundaries.\n' ...
                        '*** Unfortunately input object contans bins that are so large,\n' ...
                        '*** that even one bin may not fit to memory.\n' ...
                        '*** This algorithm will try but probably fail processing such bins.\n' ...
                        '*** Rebin input sqw object to smaller grid to be able to use this algorithm\n'], ...
                        obj.op_name);
                end
            else
                [npix_chunks, npix_idx] = split_vector_fixed_sum(npix, chunk_size);
            end
        end
        %
        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % This is most common form of the operation. Some operations
            % will request overloading
            if obj.split_at_bin_edges_
                % knowlege of all pixel coordinates in a cell.
                npix_block    = npix_blocks{idx};
                npix_in_block = sum(npix_block(:));
                pix_idx_end   = obj.pix_idx_start_+npix_in_block-1;
                obj.page_data_ = obj.pix_.get_pixels( ...
                    obj.pix_idx_start_:pix_idx_end,'-raw','-align');
                obj.pix_idx_start_ = pix_idx_end+1;
            else
                obj.pix_.page_num = idx;
                obj.page_data_    = obj.pix_.data;
            end
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
            % Returns:
            % obj   -- modified PageOp class, containing:
            %      a)  updated pix_data_range_ field, containing pixel data
            %          range (min/max values ) calculated accounting for
            %          recent page data
            %      b)  if exp_modified property of PageOp is true,
            %          modified unique_run_id_ field, updated with unique
            %          run-id-s contained in current data page
            %      c)  modified pix_ field modified with considering
            %          changes, done by apply_op method.
            %          Depending on pix_ location, it can be source pixel
            %          data, moved to new
            obj.pix_data_range_ = PixelData.pix_minmax_ranges(obj.page_data_, ...
                obj.pix_data_range_);
            if obj.exp_modified
                obj.unique_run_id_ = unique([obj.unique_run_id_, ...
                    obj.page_data_(obj.run_idx_,:)]);
            end
            if ~(obj.inplace_ || obj.do_nopix_)
                obj.pix_ = obj.pix_.store_page_data(obj.page_data_,obj.write_handle_);
            end
        end
        %
        function obj = update_img_accumulators(obj,npix_block,npix_idx, ...
                signal,variance)
            % Very often changes in image are recalculated from changes in
            % pixel data. This is generic code, that calculates changes
            % to image from changed pixels.
            % Inputs:
            % obj        --
            % npix_block -- part of npix array, which containing pixel
            %               distribution within the selected chunk of bins
            % npix_idx   -- indices of the selected cells of image to
            %               modify from pixels
            % s          -- modified pixels signal
            % variance   -- modified pixels variance
            % Returns:
            % obj        -- page_op object containing updated accumulators.
            %
            % Some operations overload update_img_accumulators method

            [s_ar, e_ar] = compute_bin_data(npix_block,signal,variance,true);
            if obj.split_at_bin_edges_
                obj.sig_acc_(npix_idx(1):npix_idx(2))        = s_ar(:);
                if ~isempty(variance)
                    obj.var_acc_(npix_idx(1):npix_idx(2))    = e_ar(:);
                end
            else
                obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                    obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
                if ~isempty(variance)
                    obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                        obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar(:);
                end
            end
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

            % Complete image modifications which would happen only if you
            % were processing the image and using accumulators
            obj = obj.update_image(obj.sig_acc_,obj.var_acc_);
            % transfer modifications of new image and pixels to the target object
            [out_obj,obj] = obj.finish_core_op(in_obj);
        end
        function [out_obj,obj] = finish_core_op(obj,in_obj)
            % The core part of finish_op
            %
            % Contains common code to transfer data changed by operation to
            % out_obj.
            %
            % Finalize core of the page operations transferring the modifications
            % of new image and pixels to the target object. Conatins major
            % part of finis_op code except update_image
            %
            %
            %
            % transfer modifications of new image and pixels to the target object
            [out_obj,obj] = finish_op_(obj,in_obj);
        end
        %
        function print_range_warning(obj,infile_name,is_old_file_format)
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
            print_range_warning_(obj,infile_name,is_old_file_format);
        end
        function report_on_target_files(obj,output_obj)
            % print information about result of pageOp
            % Inputs:
            % obj        -- initialized pageOp
            % output_obj -- the object produced by pageOp
            report_on_target_files_(obj,output_obj);
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
        function idx = get.run_idx(obj)
            idx = obj.run_idx_;
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
            does = get_info_split_log_ratio(obj);
        end
        function obj = set.split_log_ratio(obj,val)
            obj = set_info_split_log_ratio(obj,val);
        end
        %
        function do = get.exp_modified(obj)
            do = get_exp_modified(obj);
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
        %
        function pixd = get.pix(obj)
            pixd = obj.pix_;
        end
        function obj = set.pix(obj,val)
            % Set target pix data explicitly.
            %
            % Intended for use in tests only so should not be used in
            % production code.
            if ~isa(val,'PixelDataBase')
                error('HORACE:PixelDataBase:invalid_argument', ...
                    'Pix can be an object of PixelDatBase class only');
            end
            obj.pix_ = val;
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
        function do = get.inform_about_target_file(obj)
            do = obj.inform_about_target_file_;
        end
        function obj = set.inform_about_target_file(obj,val)
            obj.inform_about_target_file_ = logical(val);
        end
        %
        function do = get.split_at_bin_edges(obj)
            do = obj.split_at_bin_edges_;
        end
        function obj = set.split_at_bin_edges(obj,val)
            obj.split_at_bin_edges_ = logical(val);
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
        %
        function pd = get.page_data(obj)
            pd = obj.page_data_;
        end
        %
        function do =  get.init_filebacked_output(obj)
            do = obj.init_filebacked_output_;
        end
        function obj =  set.init_filebacked_output(obj,val)
            obj.init_filebacked_output_ = logical(val);
        end
        %
        function do = get.do_nopix(obj)
            do = obj.do_nopix_;
        end
        function obj = set.do_nopix(obj,val)
            obj.do_nopix_ = logical(val);
        end

    end
    %======================================================================
    methods(Access=protected)
        function is = get_exp_modified(obj)
            % is_exp_modified controls calculations of unique runid-s
            % during page_op.
            %
            % old_file format usually needs recalculation.
            is = obj.old_file_format_;
        end
        function  does = get_changes_pix_only(obj)
            % changes_pix only controls processing of image accumulators,
            % so if there image, we assime we want to calculate it.
            does = isempty(obj.img_);
        end
        function obj = set_changes_pix_only(obj,varargin)
            % generally, ignored and based on image.
            % left for possibility to overload in children
        end

        function do = get_do_missing_range_warning(obj)
            % Overloadable core of get.do_missing_range_warning method.
            %
            % usually range warning should not be issued for
            % operations with pixels only.
            do  = ~isempty(obj.img_);
        end

        function obj = update_image(obj,sig_acc,var_acc,varargin)
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
            % Optional
            % npix   -- array containing number of pixels in each bin
            %
            % Returns:
            % obj      -- operation object containing modified image, if
            %             image have been indeed modified
            if obj.changes_pix_only
                return;
            end
            if nargin < 4
                npix_acc = obj.npix(:);
            else
                npix_acc = varargin{1};
            end
            obj = update_image_(obj,sig_acc,var_acc,npix_acc);
        end
        %
        function mess = gen_old_file_message(~,infile_name)
            % message on how to upgrade old format file
            mess= sprintf([...
                '*** To upgrade original file run:\n' ...
                '*** >> upgrade_file_format(''%s'',"-upgrade_range")\n'],...
                infile_name);
        end
        function mess = gen_misaligned_file_message(~,infile_name)
            % message on how to upgrade quick-realigned file
            mess = sprintf([...
                '*** To upgrade original file run:\n' ...
                '*** >> fb_out = finalize_alignment(''%s'')\n'],...
                infile_name);
        end
        % Log frequency
        %------------------------------------------------------------------
        function rat = get_info_split_log_ratio(obj)
            rat = obj.split_log_ratio_;
        end
        function obj = set_info_split_log_ratio(obj,val)
            if ~isnumeric(val)
                error('HORACE:PageOpBase:invalid_argument', ...
                    'log_split_ratio can have only numeric value. Provided: %s', ...
                    class(val))
            end
            obj.split_log_ratio_ = max(1,round(abs(val)));
        end
    end
end
