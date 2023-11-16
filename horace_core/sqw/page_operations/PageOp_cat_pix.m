classdef PageOp_cat_pix < PageOpBase
    % Single page pixel operation and main gateway for
    % cat pixels algorithm. This version works for pixels only
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
        block_idx_
    end
    methods
        function obj = PageOp_cat_pix(varargin)
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
                obj.inform_about_target_file = true;
            else
                in_obj = PixelDataMemory();
                obj.inform_about_target_file = false;
            end
            obj = init@PageOpBase(obj,in_obj);
        end
        function[npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % overload of split_into_pages as we also need npix_chunks to
            % process pages in this case.
            [npix_chunks, npix_idx,obj] = split_into_pages@PageOpBase(obj,npix,chunk_size);
            obj.block_idx_ = npix_idx;
        end

        function obj = get_page_data(obj,page_idx,npix_blocks)
            % return block of data used in page operation
            %
            % here we redefine the meaning of npix; Unlike
            % general case, where npix describes the distribution of pixels
            % over bins, here each npix element contains number of pixels
            % in input pixel dataset and idx define how many datasets the
            % page of pixels occupy.
            %
            chunks  = npix_blocks{page_idx};
            n_chunks = numel(chunks);
            npix_idx = obj.block_idx_(:,page_idx); % first and last index of the block within the npix array
            if n_chunks == 1 % one or more obj.page_data_ per PixelData object
                pix_idx_start = obj.pix_block_start_(npix_idx(1));
                pix_idx_end   = pix_idx_start+chunks - 1;
                obj.page_data_ = obj.in_objects{npix_idx(1)}.get_pixels( ...
                    pix_idx_start:pix_idx_end,'-raw');

                obj.pix_block_start_(npix_idx(1)) = pix_idx_end+1;
            else % more then one PixelData object per obj.page_data_
                obj.page_data_ = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,obj.page_size_);
                page_idx_start = 1;
                n_accessor = npix_idx(1):npix_idx(2);
                for i=1:n_chunks
                    pix_idx_start  = obj.pix_block_start_(n_accessor(i));
                    pix_idx_end = pix_idx_start + chunks(i)-1;

                    accessor = obj.in_objects{n_accessor(i)};
                    page_idx_end = page_idx_start + chunks(i)-1;
                    obj.page_data_(:,page_idx_start:page_idx_end) = ...
                        accessor.get_pixels( ...
                        pix_idx_start:pix_idx_end,'-raw');
                    obj.pix_block_start_(n_accessor(i)) = pix_idx_end+1;
                    page_idx_start = page_idx_end+1;
                end
            end
        end

        function obj = apply_op(obj,varargin)
            % cat does not change pixels
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
            obj.pix_block_start_ = ones(1,n_inputs);
            npix_tot_ = 0;
            for i=1:n_inputs
                obj.in_objects{i}  = varargin{i};
                npix = varargin{i}.num_pixels;
                obj.npix(i) = npix ;
                npix_tot_ = npix_tot_ + npix;
            end
            obj.npix_tot = npix_tot_;
        end
        function is = get_exp_modified(obj)
            % if sqw object is processed, here we want to know unique
            % run_id
            is = ~isempty(obj.img_);
        end
    end
end