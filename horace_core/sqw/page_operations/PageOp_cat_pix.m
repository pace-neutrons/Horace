classdef PageOp_cat_pix < PageOpBase
    % Single page pixel operations specific for cat pixels algorithm.
    % This version works with pixels only
    %
    %
    properties
        % cellarrsy of the input objects to process. The objects may be
        % PixelData, sqw objects or list of files, containing sqw objects
        in_objects;
        npix_tot;   % Total number of
        % if set to true, always try to concatenate pixels in memory.
        force_cat_in_memory = false;
    end
    properties(Hidden)
        % access to pix for testing chuncing only
        pix
    end
    properties(Access = private)
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
            % Initialize cat pix operations
            % Inputs:
            % varargin -- comma-separated list of pixel data classes to
            %             concatenate together

            % Initialize cat operation on pixels:
            obj = obj.init_pix_only_data_obj(varargin{:});

            [mem_chunk_size,pf] = config_store.instance().get_value( ...
                'hor_config','mem_chunk_size','fb_scale_factor');
            fb_pix_limit = pf*mem_chunk_size;
            if obj.npix_tot > fb_pix_limit && ~obj.force_cat_in_memory
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
            if isa(obj.pix_,'PixelDataMemory') % if target pixels are in memory
                % they always should be done in one stroke as pix in memory
                % do not append data in common_page_op performed later but
                % replace contents of resulting PixDataMemory.
                npix_chunks = {npix(:)};
                npix_idx    = [1;numel(npix)];
            else
                [npix_chunks, npix_idx,obj] = split_into_pages@PageOpBase(obj,npix,chunk_size);
            end
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
                    pix_idx_start:pix_idx_end,'-raw','-align');

                obj.pix_block_start_(npix_idx(1)) = pix_idx_end+1;
            else % more then one PixelData object per obj.page_data_
                this_chunk = sum(chunks);
                obj.page_data_ = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,this_chunk);
                page_idx_start = 1;
                n_accessor = npix_idx(1):npix_idx(2);
                for i=1:n_chunks
                    pix_idx_start  = obj.pix_block_start_(n_accessor(i));
                    pix_idx_end = pix_idx_start + chunks(i)-1;

                    accessor = obj.in_objects{n_accessor(i)};
                    page_idx_end = page_idx_start + chunks(i)-1;
                    obj.page_data_(:,page_idx_start:page_idx_end) = ...
                        accessor.get_pixels( ...
                        pix_idx_start:pix_idx_end,'-raw','-align');
                    obj.pix_block_start_(n_accessor(i)) = pix_idx_end+1;
                    page_idx_start = page_idx_end+1;
                end
            end
        end

        function obj = apply_op(obj,varargin)
            % cat does not change pixels
        end
        %==================================================================
        function pix = get.pix(obj)
            pix = obj.pix_;
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
        %
    end
    methods(Access=protected)
        function obj = init_pix_only_data_obj(obj,varargin)
            % process and prepare for operations input cell-array of pixel
            % data objects.
            %
            n_inputs = numel(varargin);
            obj.in_objects = cell(1,n_inputs);
            obj.npix = zeros(1,n_inputs);
            obj.pix_block_start_ = ones(1,n_inputs);
            npix_tot_ = 0;
            for i=1:n_inputs
                if ~isa(varargin{i},'PixelDataBase')
                    error('HORACE:PixelDataBase:invalid_argument', ...
                        ['cat requested arguments are PixelDatBase sub-classes.' ...
                        ' Class of the input N%d is: %s'], ...
                        i,class(varargin{i}));
                end
                obj.in_objects{i}  = varargin{i};
                npix = varargin{i}.num_pixels;
                obj.npix(i) = npix ;
                npix_tot_ = npix_tot_ + npix;
            end
            obj.npix_tot = npix_tot_;
        end
        function is = get_exp_modified(obj)
            % is_exp_modified control calculations of unique runid-s
            % during page_op.
            %
            % if sqw object is processed, here we want to know unique
            % run_id
            is = ~isempty(obj.img_);
        end
        function  does = get_changes_pix_only(~)
            % pageOp calculates pixels only using image as source. No point
            % of calculating image from pixels again as it would be in
            % usual PageOp
            does = true;
        end
        % Log frequency
        %------------------------------------------------------------------
        function rat = get_info_split_log_ratio(~)
            rat = config_store.instance().get_value('log_config','cat_pix_split_ratio');
        end
        function obj = set_info_split_log_ratio(obj,val)
            log = log_config;
            log.cat_pix_split_ratio = val;
        end
        
    end
end