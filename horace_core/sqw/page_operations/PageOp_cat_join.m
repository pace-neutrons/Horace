classdef PageOp_cat_join < PageOpBase
    % Single page pixel operation and main gateway for
    % cat/join/combine_sqw algorithms.
    %
    %
    properties
        % cellarrsy of the input objects to process. The objects may be
        % PixelData, sqw objects or list of files, containing sqw objects
        in_objects;
        npix_tot;   % Total number of
    end
    properties(Access = private)
        page_size_;
        % the position of pixels in every pixel block
        pix_block_start_;
        % indixes of pages in the npix array, produced by split_into_pages
        block_chunks_
    end
    methods
        function obj = PageOp_cat_join(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'cat_pixels';
            obj.split_at_bin_edges = false;
        end

        function obj = init(obj,varargin)
            % Initialize cat operation:

            obj = obj.init_pix_only_data_obj(varargin{:});

            [pf,mem_chunk_size] = config_store.instance().get_value( ...
                'hor_config','mem_chunk_size','fb_scale_factor');
            fb_pix_limit = pf*mem_chunk_size;
            obj.page_size_ = mem_chunk_size;
            if obj.npix_tot > fb_pix_limit
                in_obj = PixelDataFileBacked();
            else
                in_obj = PixelDataMemory();
            end
            obj = init@PageOpBase(obj,in_obj);
        end
        function[npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % overload of split_into_pages as we also need npix_chunks to
            % process pages in this case.
            [npix_chunks, npix_idx,obj] = split_into_pages@PageOpBase(obj,npix,chunk_size);
            obj.block_chunks_ = npix_chunks;
        end

        function obj = get_page_data(obj,page_idx,npix_blocks)
            % return block of data used in page operation
            %
            % here we redefine the meaning of npix; Unlike
            % general case, where npix describes the distribution of pixels
            % over bins, here each npix element contains number of pixels
            % in input pixel dataset and idx define how many datasets the
            % pixels occupy.
            %


            chunks  = npix_blocks{page_idx};
            n_chunks = numel(chunks);
            npix_idx = obj.block_chunks_(page_idx); % first and last index of the block within the npix array
            if n_chunks == 1 % one or more obj.page_data_ per PixelData object
                pix_idx_start = obj.pix_block_start_(npix_idx(1));
                pix_idx_end   = pix_idx_start+chunks(1)-1;
                obj.pix_block_start_(npix_idx(1)) = pix_idx_start+pix_idx_end+1;
                obj.page_data_ = obj.in_objects{npix_idx(1)}.get_pixels( ...
                    obj.pix_idx_starts_:pix_idx_end,'-raw');                
            else % more then one PixelData object per obj.page_data_
                obj.page_data_ = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,obj.page_size_);                
                pix_idx_start = obj.pix_block_start_(npix_idx(1));
                for i=1:n_chunks
                    edn
            end

            for i=1:n_chunks
                pix_idx_start = obj.pix_block_start_(block1_num);
                pix_idx_end    = pix_idx_start+npix_block-1;
                block_size = pix_idx_end-pix_idx_start   +1;
                if block_size>npix_block
                    block_size = npix_block
                end

            end

            if obj.split_at_bin_edges_
                % knowlege of all pixel coordinates in a cell.
                npix_block    = npix_blocks{idx};
                npix_in_block = sum(npix_block(:));
                pix_idx_end   = obj.pix_idx_starts_+npix_in_block-1;
                obj.page_data_ = obj.pix_.get_pixels( ...
                    obj.pix_idx_starts_:pix_idx_end,'-raw');
                obj.pix_idx_starts_ = pix_idx_end+1;
            else
                obj.pix_.page_num = idx;
                obj.page_data_ = obj.pix_.data;
            end
        end


        function obj = apply_op(obj,npix_block,npix_idx)

            % keep what is selected
            obj.page_data_ = obj.page_data_(:,keep_pix);
            if obj.changes_pix_only
                return;
            end
            % calculate changes in npix:
            nbins = numel(npix_block);
            ibin  = repelem(1:nbins, npix_block(:))';
            npix_block = accumarray(ibin(keep_pix), ones(1, sum(keep_pix)), [nbins, 1]);

            % retrieve masked signal and error
            signal = obj.page_data_(obj.signal_idx,:);
            error  = obj.page_data_(obj.var_idx,:);
            % update image accumulators:
            [s_ar, e_ar] = compute_bin_data(npix_block,signal,error,true);
            obj.npix_acc(npix_idx(1):npix_idx(2))    = ...
                obj.npix_acc(npix_idx(1):npix_idx(2)) + npix_block(:);
            obj.sig_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.sig_acc_(npix_idx(1):npix_idx(2)) + s_ar(:);
            obj.var_acc_(npix_idx(1):npix_idx(2))    = ...
                obj.var_acc_(npix_idx(1):npix_idx(2)) + e_ar(:);
        end
        %
        function [out_obj,obj] = finish_op(obj,out_obj)
            if ~obj.changes_pix_only
                obj = obj.update_image(obj.sig_acc_,obj.var_acc_,obj.npix_acc);
                %
                if numel(obj.unique_run_id_) == out_obj.experiment_info.n_runs
                    obj.check_runid = false; % this will not write experiment info
                    % again as it has not changed
                else
                    % it always have to be less or equal, but some tests do not
                    % have consistent Experiment
                    if numel(obj.unique_run_id_) < out_obj.experiment_info.n_runs
                        out_obj.experiment_info = ...
                            out_obj.experiment_info.get_subobj(obj.unique_run_id_);
                    end
                end
            end
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end
        %
    end
    methods(Static,Access=private)
        function npix = cell_contents(cellarray,cell_idx)
            if numel(cellarray)> cell_idx
                npix  = 0;
            else
                npix = cellarray{cell_idx};
            end
        end
    end
    methods(Access=protected)
        function obj = init_pix_only_data_obj(obj,varargin)
            % process and prepare for operations input array of pixel data
            % objects.
            n_inputs = numel(varargin);
            obj.in_objects = cell(1,n_inputs);
            obj.npix = zeros(1,n_inputs);
            obj.pix_idx_starts_ = ones(1,n_inputs);
            npix_tot_ = 0;
            for i=1:n_inputs
                obj.in_objects{i}  = varargin{i};
                npix = varargin{i}.num_pixels;
                obj.npix(i) = npix ;
                npix_tot_ = npix_tot_ + npix;
            end
            obj.npix_tot = npix_tot_;
        end

    end
end