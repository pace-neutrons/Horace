classdef PageOp_cat_join < PageOpBase
    % Single page pixel operation and main gateway for
    % cat/join/combine_sqw algorithms.
    %
    %
    properties
        % list of the input objects to process. The objects may be
        % PixelData, sqw objects or list of files, containing sqw objects
        in_objects;
    end
    properties(Access = protected)
        % cellarray of npix distributions, every input object has
        in_npix
        % cellarray of chunk arrays every object is split into
        in_ob_chunks_;
        % array of initial positions of each pix block
        pix_idx_starts_
        % what cat type should be performed (Should it be just PageOp
        % overload?)
        cat_type_
    end
    properties(Constant,Access=private)
        cat_types = containers.Map({'pix_only'},{1});
    end
    properties(Dependent)
        %==================================================================
        % Pixels are normally distributed on file and in memory according
        % to image bins and the distribution is described by npix array.
        % These properties, if defined, describe the npix array location
        % within the binary file and used for concatenating pixels
        % located in mutiple files into single block of data using external
        % C++ application (or MATLAB mex code)
        npix_block_pos    % location in bytes from the beginning of binary file
    end

    methods
        function obj = PageOp_cat_join(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'cat|join';
            obj.split_at_bin_edges = true;
        end

        function obj = init(obj,targ_img,varargin)
            % Initialize cat operation:
            %
            if isempty(targ_img)
                [pf,mem_chunk_size] = config_store.instance().get_value( ...
                    'hor_config','mem_chunk_size','fb_scale_factor');
                fb_pix_limit = pf*mem_chunk_size;
                if sum(obj.npix(:)) > fb_pix_limit
                    in_obj = PixelDataFileBacked();
                else
                    in_obj = PixelDataMemory();
                end
                obj = obj.init_pix_only_data_obj(varargin{:});
            elseif isnumeric(targ_img) % cat for pixels only, may be with
                % npix distribution
                obj.npix = targ_img(:);
                obj = obj.set_pix_data_obj(varargin{:});
            end
            obj = init@PageOpBase(obj,in_obj);

            if ~isempty(obj.img_)
                obj.var_acc_ = zeros(numel(obj.img_.npix),1);
            else
                % if we work with pixels only, we do not need to check
                % runid.
                obj.check_runid = false;
            end
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,~,chunk_size)
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
            switch obj.cat_types_
                case(1)
                    npix_idx = [];
                    pf = config_store.instance().get_value( ...
                        'hor_config','fb_scale_factor');
                    big_chunk = pf*chunk_size;

                    n_obj = numel(obj.in_npix);
                    npix_chunks = cell(1,n_obj);
                    % cellarray of chunk arrays every object is split into
                    obj.in_ob_chunks_ = cell(1,n_obj) ;
                    class_chunk = floor(big_chunk/n_obj);
                    max_split = -1;
                    for i=1:n_obj
                        obj.in_ob_chunks_{i} = split_vector_fixed_sum(obj.in_npix{i}, class_chunk);
                        max_split = max(max_split,numel(obj.in_ob_chunks_{i}));
                    end
                    for i = 1:max_split
                        the_split_blocks = sum(cellfun(@(idx)obj.in_obj_chumks)

                    end
                otherwise
                    error('HORACE:not_implemented','not yet implemented')
            end

        end


        function obj = get_page_data(obj,idx,npix_blocks)
            % return block of data used in page operation
            %
            % This is most common form of the operation. Some operations
            % will request overloading
            npix_tot = sum(npix_blocks(idx));
            obj.page_data_ = zeros(,npix_tot);
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
            obj.in_npix = cell(1,n_inputs);
            obj.pix_idx_starts_ = ones(1,n_inputs);
            npix_tot = 0;
            for i=1:n_inputs
                obj.in_objects{i}  = varargin{i};
                npix = varargin{i}.num_pixels;
                obj.in_npix{i} = npix ;
                npix_tot = npix_tot + npix;
            end
            obj.npix = npix_tot;
        end

    end
end