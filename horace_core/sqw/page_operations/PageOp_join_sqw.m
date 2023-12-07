classdef PageOp_join_sqw < PageOpBase
    % Single page pixel operation and main gateway for
    % sqw.split  algorithm.
    %
    %
    properties
        % Multipix info class containing information about 
        pix_combine_info 
    end
    properties(Access = protected)
    end
    methods
        function obj = PageOp_join_sqw(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'join_sqw';
            obj.split_at_bin_edges = false;
        end

        function obj = init(obj,in_sqw)
            % initialize split_sqw algorithm.
            % Input:
            % in_sqw         -- initial sqw object to split

            obj = init@PageOpBase(obj,in_sqw);

            %obj.img_filebacked_ = img_filebacked;
            % prepare target sqw objects to split source into
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % Overload for standard split to ensure parts of split images
            % do not exceed available memory.
            %
            % Inputs:
            % npix  -- image npix array, which defines the number of pixels
            %           contributing into each image bin and the pixels
            %           ordering in the linear array
            % chunk_size
            %       -- sized of chunks to split pixels.
            % Returns:
            % npix_chunks -- cellarray, containing the npix parts
            % npix_idx    -- [2,n_chunks] array of indices of the chunks in
            %                the npix array.
            [npix_chunks, npix_idx,obj] = split_into_pages@PageOpBase(obj,npix,chunk_size);
            % if ~obj.img_filebacked_
            %     return;
            % end
            % % Ensure sum of all partial images do not exceed available memory
            % % during the split.
            % 
            % % The size of a split chunk is equal to size of 3 double arrays
            % % for each chunks multiplied by the number of chunks
            % n_chunks = numel(obj.out_sqw);
            % n_elements_in_chunks = cellfun(@(x)(numel(x)),npix_chunks);
            % % One multiple image element occupies 3*8*n_chunks bytes
            % % and all image chunks occupy the following memory:
            % chunk_byte_sizes = (3*8*n_chunks)*n_elements_in_chunks;
            % mem_avail = config_store.instance().get_value('hpc_config','phys_mem_available');
            % if all(chunk_byte_sizes<mem_avail)
            %     return;
            % end
            % % split chunks additionaly to ensure sum of them do not contain
            % % more bins that would fit to memory.
            % n_elements_fit_memory = floor(mem_avail/(3*8*n_chunks));
            % if n_elements_fit_memory <1
            %     n_elements_fit_memory = 1; % will be very very very slow.
            %     warning('HORACE:slow_operation', ...
            %         [' split_sqw algorithm suggests starts page operation operating single image bin at a time.\n' ...
            %         ' This will be extreamly slow operation.\n' ...
            %         ' Validate your settings'])
            % end
            % [npix_chunks, npix_idx] = split_vector_max_sum_or_numel( ...
            %     npix, chunk_size,n_elements_fit_memory);
        end

        function obj = apply_op(obj,npix_block,npix_idx)
            run_id = obj.page_data_(obj.run_idx_,:);
            % run id contributed into this page
            unique_id = unique(run_id);
            obj.n_obj_contrib_to_page_ = zeros(numel(unique_id),1);

            % pixel over bin distribution
            nbins   = numel(npix_block);
            ibin  = repelem(1:nbins, npix_block(:))';
            % sort pixels over objects
            for n_obj = 1:numel(unique_id) %
                this_id    = unique_id(n_obj);
                % number of current object in Experiment.IX_dataset array.
                splitobj_num = obj.runid_map_(this_id);
                obj.run_contributes_(splitobj_num) = true;
                obj.n_obj_contrib_to_page_(n_obj) = splitobj_num;
                % extract data belonging to single split sqw
                this_img   = obj.out_img{splitobj_num};
                this_pix   = run_id == this_id;
                obj_pix    = obj.page_data_(:,this_pix);

                % calculate object accumulators:
                % pixel distribution over bins:
                obj_npix   = accumarray(ibin(this_pix), ones(1, sum(this_pix)), [nbins, 1]);
                if obj.img_filebacked_
                    % calculate chunk of final image
                    [s_ar, e_ar] = compute_bin_data( ...
                        obj_npix,obj_pix(obj.signal_idx,:),obj_pix(obj.var_idx,:));
                    this_img.s   =  s_ar(:);
                    this_img.e   =  e_ar(:);
                    this_img.npix= obj_npix(:);
                else
                    % accumulate non-normalized chunks to finalize them
                    % later
                    [s_ar, e_ar] = compute_bin_data( ...
                        obj_npix,obj_pix(obj.signal_idx,:), ...
                        obj_pix(obj.var_idx,:),true);

                    this_img.s(npix_idx(1):npix_idx(2))    = ...
                        this_img.s(npix_idx(1):npix_idx(2)) + s_ar(:);
                    this_img.e(npix_idx(1):npix_idx(2))    = ...
                        this_img.e(npix_idx(1):npix_idx(2)) + e_ar(:);
                    this_img.npix(npix_idx(1):npix_idx(2))    = ...
                        this_img.npix(npix_idx(1):npix_idx(2)) + obj_npix(:);

                end
                % assign modified data back to the holder
                obj.out_img{splitobj_num}  = this_img;
                obj.out_pix{splitobj_num}  = obj_pix;
            end
        end

        function obj = common_page_op(obj)
            % Method contains split_sqw-specific code which runs for any
            % page operation.
            %
            % Input:
            % obj   -- pageOp object, containing pixel_data page
            %          to split into sub-pages.
            %

            % number of objects which contain pixels
            n_contr = numel(obj.n_obj_contrib_to_page_);

            for i=1:n_contr
                splitobj_num = obj.n_obj_contrib_to_page_(i);
                % re-evaluate pix ranges for every object contributing to
                % page
                pix_obj_data = obj.out_pix{splitobj_num};
                obj.obj_pix_ranges{splitobj_num} = ...
                    PixelData.pix_minmax_ranges(pix_obj_data, ...
                    obj.obj_pix_ranges{splitobj_num});
                % store split result into places, specific for each split object
                obj.out_sqw{splitobj_num}.pix = ...
                    obj.out_sqw{splitobj_num}.pix.store_page_data( ...
                    pix_obj_data,obj.write_handles{splitobj_num});
                % if image is filabacked, also store recalculated piece of
                % image
                if obj.img_filebacked_
                    obj.write_handles{splitobj_num}.save_img_chunk(...
                        obj.out_img{splitobj_num});
                end
            end
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

        %
    end
end
