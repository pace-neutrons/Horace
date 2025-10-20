classdef PageOp_section < PageOpBase
    % Single pixel page operation used by section algorithm
    %
    properties
        % initial positions of pixels to transfer to the section
        block_starts_;
        % size of the  blocks to transfer to the section
        block_sizes_;
        % cellarray of block_start,block_size arrays, divided into pages by
        % page size.
        block_chunks_;

        unique_runid_holder;
        % if some run_id do not contribute to pixels any more,
        % they also should not contribute to experiment
        check_runid;
    end
    methods
        function obj = PageOp_section(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'section';
        end
        function obj = init(obj,sqw_obj,new_img,ind_ranges)
            obj           = init@PageOpBase(obj,sqw_obj);
            %
            [obj.block_starts_,obj.block_sizes_]  = ...
                obj.find_section(obj.img_.npix,ind_ranges);

            obj.block_chunks_ = {{obj.block_starts_;obj.block_sizes_}};
            % assign new image as final image
            obj.img_ = new_img;
            obj.unique_runid_holder = [];
            obj.check_runid = true;
        end
        %
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,~,chunk_size)
            % Method used to split input npix array into pages
            % Inputs:
            % obj   -- initialized PageOp_section object containing obj.block_chunks_
            %          which contribute to section
            % chunk_size
            %       -- sized of chunks to split pixels
            % Returns:
            % npix_chunks -- cellarray, containing the npix parts
            %
            % See split procedure for more details
            npix_chunks = split_data_blocks(obj.block_starts_,obj.block_sizes_, chunk_size);
            npix_idx = ones(2,numel(npix_chunks));
            obj.block_chunks_ = npix_chunks;
        end
        %
        function obj = get_page_data(obj,idx,varargin)
            % return block of data used in page operation
            %
            % Overload specific for section. It takes various pieces of
            % pixel data.
            obj.page_num =  idx;
            bl_chunk   = obj.block_chunks_{idx};
            bl_start   = bl_chunk{1};
            bl_size    = bl_chunk{2};
            ind = get_ind_from_ranges(bl_start, bl_size);
            obj.page_data_ = obj.pix_.get_pixels(ind ,'-raw','-align');
        end

        function obj = apply_op(obj,varargin)
            % Nothing happens here. Selected pixels blocks are
            % transferred to target without modifications
        end
        function [out_obj,obj] = finish_op(obj,out_obj)
            if numel(obj.unique_run_id_) == out_obj.experiment_info.n_runs
                obj.check_runid = false; % this will not write experiment info again
            else
                % it always have to be less or equal, but some tests do not
                % have consistent Experiment
                if numel(obj.unique_run_id_) < out_obj.experiment_info.n_runs
                    out_obj.experiment_info = ...
                        out_obj.experiment_info.get_subobj(obj.unique_run_id_);
                end
            end
            % transfer modifications to the target object
            [out_obj,obj] = finish_op@PageOpBase(obj,out_obj);
        end
    end
    methods(Access=protected)
        function is = get_exp_modified(obj)
            % getter for exp_modified property, which saves modified
            % Experiment
            is = obj.old_file_format_||obj.check_runid;
        end
        function  does = get_changes_pix_only(~)
            % pageOp calculates pixels only using image as source. No point
            % of calculating image from pixels again as it would be in
            % usual PageOp
            does = true;
        end

    end
    methods(Static)
        function [block_starts,block_sizes] = find_section(npix,ind_range)
            % using npix which defines number of pixels in an image cell
            % and ind_range array, which specify what n-d indexes of the image
            % we want to keep, identify the ranges of pixels to keep.
            %
            block_sizes = npix;
            block_ends  = cumsum(block_sizes(:));
            pix_start   = reshape([0;block_ends(1:end-1)],size(block_sizes));
            block_ends  = reshape(block_ends,size(block_sizes));
            i = 1:size(ind_range,2);
            sel_ranges = arrayfun(@(ii)ind_range(1,ii):ind_range(2,ii),i,'UniformOutput',false);
            sel_blocks = block_sizes(sel_ranges{:});
            sel_pos    = pix_start(sel_ranges{:});
            sel_ends   = block_ends(sel_ranges{:});
            non_empty  = sel_blocks(:)>0;

            block_starts = sel_pos(non_empty);
            block_ends   = sel_ends(non_empty);
            % compress adjacent elements
            edges = diff(block_starts)>1;
            start = [true;edges(:)];
            endi  = [edges(:);true];
            block_starts = block_starts(start);
            block_ends   = block_ends(endi);
            %
            block_sizes  = block_ends-block_starts;
            % Matlab starts counting from 1
            block_starts = block_starts+1;
        end
    end
    methods(Access=protected)
        % Log frequency
        %------------------------------------------------------------------
        function rat = get_info_split_log_ratio(~)
            rat = config_store.instance().get_value('log_config','section_split_ratio');
        end
        function obj = set_info_split_log_ratio(obj,val)
            log = log_config;
            log.section_split_ratio = val;
        end
    end
end
