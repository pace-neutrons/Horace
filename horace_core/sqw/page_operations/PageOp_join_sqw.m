classdef PageOp_join_sqw < PageOpBase
    % Single page pixel operation and main driver for
    % sqw.join and write_nsqw_to_sqw  algorithms.
    %
    properties
        % property which contains MultipixBase class, describing
        % pixels in multiple datasets to be combined
        pix_combine_info;
    end
    %
    properties(Access = protected)
        % holder for array of split block indices (npix_idx), produced by
        % split_into_pages routine
        block_idx_;
        % the array of positions each combined page occupies in target
        % dataset. Not very useful in serial mode but may be necessary in
        % parallel mode if parallel_write is available.
        page_start_pos_;
        % array of current positions of all contributing pixel datasets
        current_page_pix_pos_;
    end
    methods
        function obj = PageOp_join_sqw(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'join_sqw';
            obj.split_at_bin_edges = true;
        end

        function [obj,in_sqw] = init(obj,in_sqw)
            % initialize join_sqw algorithm.
            % Input:
            % in_sqw         -- special sqw object to join, prepared by
            %                   collect_sqw_metadata algorithm.
            if ~isa(in_sqw.pix,'MultipixBase')
                error('HORACE:PageOp_join_sqw:invalid_argument', ...
                    'Input sqw object does not contain information on how to combine input data')
            end
            % Transfer input MultipxBase object as source of data in the
            % operation
            obj.pix_combine_info = in_sqw.pix;
            in_sqw.pix = PixelDataMemory();
            %
            obj = init@PageOpBase(obj,in_sqw);
            % clear signal accumulator to save memory; it will not be used
            % here.
            obj.sig_acc_  = [];
            % initialize input datasets for read access
            obj.pix_combine_info  = obj.pix_combine_info.init_pix_access();
            obj.current_page_pix_pos_ = ones(1,obj.pix_combine_info.nfiles);
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % Overload of split method allowing to define large target chink
            % and store npix_idx for internal usage
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
            fb = config_store.instance().get_value( ...
                'hor_config','fb_scale_factor');
            % do large chunk to decrease number of sub-calls to each data
            % pixels
            large_chunk = chunk_size*fb;
            [npix_chunks, npix_idx,obj] = split_into_pages@PageOpBase(obj,npix,large_chunk);
            obj.block_idx_ = npix_idx;
            page_sizes = cellfun(@(x)sum(x(:)),npix_chunks);
            page_pos = cumsum(page_sizes);
            obj.page_start_pos_ = [1,page_pos(1:end-1)];
        end

        function obj = get_page_data(obj,idx,npix_blocks)
            % join-specific access to block of page data
            %
            % reads data from mutiple sources and combines them together
            % into single page of data.
            %
            bin_start = cumsum(npix_blocks{idx});
            page_size = bin_start(end);
            % the positions of empty bins to place pixels
            bin_start = [0,bin_start(1:end-1)];
            page_data = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,page_size);
            multi_data   = obj.pix_combine_info;
            n_datasets = multi_data.nfiles;
            for i=1:n_datasets
                % get particular dataset's page data
                [contr_page_data,page_bin_distr] = multi_data.get_dataset_page( ...
                    i,obj.current_page_pix_pos_(i),obj.block_idx_(:,idx));
                % advance initial page position for the particular dataset
                n_page_pix = size(contr_page_data,2);
                obj.current_page_pix_pos_(i) = ...
                    obj.current_page_pix_pos_(i)+n_page_pix;

                % find indexes of i-th dataset's page pixels in the target's
                % dataset page
                targ_bin_pos   = repelem(bin_start,page_bin_distr);
                targ_bin_idx   = targ_bin_pos+(1:n_page_pix);

                % place page pixel data into appropriate places of combined
                % dataset
                page_data(:,targ_bin_idx) = contr_page_data;
                % advance empty bin positions to point to free bin spaces
                bin_start = bin_start+page_bin_distr(:)';
            end
            obj.page_data_ = page_data;
        end

        function obj = apply_op(obj,varargin)
            %does nothing data redistribution have occured at get_page_data
        end
        %
    end
    %======================================================================
    methods(Access =protected)
        function is = get_exp_modified(~)
            % is_exp_modified controls calculations of unique runid-s
            % during page_op.
            %
            % Here we calculate unique run_id differently, so always false
            is = false;
        end
        function  does = get_changes_pix_only(~)
            % this operation changes pixels only regardless of image
            does = true;
        end

        %
    end
end
