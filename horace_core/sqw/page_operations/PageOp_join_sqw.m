classdef PageOp_join_sqw < PageOpBase
    % Single page pixel operation and main driver for
    % sqw.join and write_nsqw_to_sqw  algorithms.
    %
    properties
        % property which contains MultipixBase class, describing
        % pixels in multiple datasets to be combined
        pix_combine_info;
        % if provided, the new runid array to set as pixels runid for each
        % contributing run
        new_runid;
        % true if mex code should be used for combining pixels
        use_mex;
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
        % array of values how many pixels already retrieved from each
        % contributing dataset.
        npix_page_read_;
        % Used in mex-combining only and contains the position counted
        % from the start of the target binary file, which pixel data occupy
        % (expressed in bytes)
        pixout_start_pos_;
    end
    methods
        function obj = PageOp_join_sqw(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'join_sqw';
            obj.split_at_bin_edges = true;
        end

        function [obj,in_sqw] = init(obj,in_sqw,new_runid,use_mex)
            % initialize join_sqw algorithm.
            % Input:
            % in_sqw         -- special sqw object to join, prepared by
            %                   collect_sqw_metadata algorithm.
            if ~isa(in_sqw.pix,'MultipixBase')
                error('HORACE:PageOp_join_sqw:invalid_argument', ...
                    'Input sqw object does not contain information on how to combine input data')
            end
            % Set input MultipxBase object as source of data in the
            % operation
            obj.pix_combine_info = in_sqw.pix;
            % and set target sqw object with target pixels as the target.
            [mcs,fb] = config_store.instance().get_value('hor_config','mem_chunk_size','fb_scale_factor');
            % select if we want/need filebacked or memory based result
            if obj.pix_combine_info.num_pixels > mcs*fb || ...
                    ~isempty(obj.outfile) || isa(obj.pix_combine_info,'pixfile_combine_info')
                pix = PixelDataFileBacked();
                obj.init_filebacked_output = true;
            else
                pix = PixelDataMemory();
            end
            % set up pix earlier to build correct filename
            obj.pix_ = pix;
            if isempty(obj.outfile)
                obj.outfile = obj.build_file_name_for_join();
            end

            % only pixfile_combine_info class can currently provide data
            % for mex combining.
            obj.use_mex = use_mex && isa(obj.pix_combine_info,'pixfile_combine_info');
            %
            % set pixel data range to avoid warning about old file format
            % which does not have one.
            in_sqw.pix = pix.set_data_range(obj.pix_combine_info.data_range);
            %
            obj = init@PageOpBase(obj,in_sqw);

            obj.new_runid = new_runid;
            % clear signal accumulator to save memory; it will not be used
            % here.
            obj.sig_acc_  = [];
            if  ~obj.use_mex
                % initialize input datasets for read access
                obj.pix_combine_info  = obj.pix_combine_info.init_pix_access();
                obj.npix_page_read_ = zeros(1,obj.pix_combine_info.nfiles);
            else
                obj.pixout_start_pos_ = obj.write_handle_.pixout_start;
            end
        end
        function [npix_chunks, npix_idx,obj] = split_into_pages(obj,npix,chunk_size)
            % Overload of split method allowing to define large target chunk
            % and store npix_idx for internal usage.
            %
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
            if obj.use_mex
                npix_chunks = {npix};
                npix_idx = [1;numel(npix)];
                return;
            end
            fb = config_store.instance().get_value( ...
                'hor_config','fb_scale_factor');
            % do large chunk to decrease number of sub-calls to each data
            % pixels
            large_chunk = chunk_size*fb;
            [npix_chunks, npix_idx,obj] = split_into_pages@PageOpBase(obj,npix,large_chunk);
            obj.block_idx_ = npix_idx;
            page_sizes = cellfun(@sum,npix_chunks);
            page_pos = cumsum(page_sizes);
            obj.page_start_pos_ = [1,page_pos(1:end-1)];
        end

        function obj = get_page_data(obj,idx,npix_blocks)
            % join-specific access to block of page data
            %
            % reads data from multiple sources and combines them together
            % into single page of data.
            %
            obj.page_num = idx;
            if obj.use_mex % mex will pull all data by itself
                return
            end

            bin_start = cumsum(npix_blocks{idx});
            page_size = bin_start(end);
            % the positions of empty bins to place pixels
            bin_start = [0,bin_start(1:end-1)] + 1;
            page_data = zeros(PixelDataBase.DEFAULT_NUM_PIX_FIELDS,page_size);
            multi_data   = obj.pix_combine_info;
            n_datasets = multi_data.nfiles;
            for i=1:n_datasets
                % get particular dataset's page data
                [contr_page_data,page_bin_distr] = multi_data.get_dataset_page( ...
                    i,obj.npix_page_read_(i)+1,obj.block_idx_(:,idx));
                % advance initial page position for the particular dataset
                n_page_pix = size(contr_page_data,2);
                obj.npix_page_read_(i) = ...
                    obj.npix_page_read_(i)+n_page_pix;
                %
                if ~isempty(obj.new_runid)
                    contr_page_data(obj.run_idx_,:) = obj.new_runid(i);
                end

                % find indices of i-th dataset's page pixels in the target's
                % dataset page
                targ_bin_idx = fill_idx(bin_start,page_bin_distr);
                % TODO: Is this quicker?
                % targ_bin_pos   = repelem(bin_start,page_bin_distr);
                % cell_ind = accumarray(targ_bin_pos,1:n_page_pix,[],@(x){x});
                % targ_bin_idx   = targ_bin_pos+[cell_idx{:}]';

                % place page pixel data into appropriate places of combined
                % dataset
                page_data(:,targ_bin_idx) = contr_page_data;
                % advance empty bin positions to point to free bin spaces
                bin_start = bin_start+page_bin_distr(:)';
            end
            obj.page_data_ = page_data;
        end

        function obj = apply_op(obj,varargin)
            % used only in mex mode
            if obj.use_mex
                if isempty(obj.new_runid)
                    change_fileno = false;
                else
                    change_fileno = true;
                end
                combine_files_using_mex(obj.outfile,obj.pix_combine_info, ...
                    obj.pixout_start_pos_,...
                    obj.new_runid,change_fileno,false);
                % correct number of pixels written is verified by mex
                % routine. Here we rely on mex to calculate it correctly
                % and set expected value as the result.
                obj.write_handle_.npix_written =  obj.pix_combine_info.num_pixels;
            end
        end
        function obj = common_page_op(obj)
            if obj.use_mex
                obj.pix_data_range_ = obj.pix_combine_info.data_range;
                return; % all done in apply_op
            else
                obj = common_page_op@PageOpBase(obj);
            end
        end
        function [out_obj,obj] = finish_op(obj,in_obj)
            % external range is normally calculated with double precision
            % and here -- with single precision. Use external if possible
            extern_range = obj.pix_combine_info.data_range;
            valid = extern_range == PixelDataBase.EMPTY_RANGE;
            if all(valid)
                obj.pix_data_range_ = obj.pix_combine_info.data_range;
            end

            % overload of generic finis_op, which allow close access to
            % contributing file accessors
            obj.pix_combine_info = obj.pix_combine_info.close_faccessors();
            % Do common things things with resulting object
            [out_obj,obj] = finish_op@PageOpBase(obj,in_obj);
        end
        %
    end
    %======================================================================
    methods(Access =protected)
        function  np = get_page_num(obj)
            np = obj.pix_combine_info.page_num;
        end
        function  obj = set_page_num(obj,val)
            obj.pix_combine_info.page_num = val;            
        end
        
        function is = get_exp_modified(~)
            % is_exp_modified controls calculations of unique runid-s
            % during page_op.
            %
            % Here we calculate unique run_id differently, so always false
            is = false;
        end
        function  is = get_changes_pix_only(~)
            % this operation changes pixels only regardless of image
            is = true;
        end
        function  outfile = build_file_name_for_join(obj)
            % build file-name for join operation using one of the
            % contributing files name.
            %
            % uses obj.pix_ field contents to identify filename type
            % so needs this filed defined
            %
            % if target object is filebacked, it will be tmp filename, but
            % if result is memorybased, the extension would be sqw.
            %
            hc = hor_config;
            wkdir = hc.working_directory;
            if istext(obj.pix_combine_info.infiles{1})
                part_file = obj.pix_combine_info.infiles{1};
            else
                part_file = obj.pix_combine_info.infiles{1}.full_filename;
            end
            [~,fb] = fileparts(part_file);
            fb = strsplit(fb,'_runID');
            if iscell(fb)
                fb = ['combined_',fb{1}];
            end
            if isempty(fb)
                fb = 'combined_form_mem';
            end
            if obj.pix_.is_filebacked
                outfile = build_tmp_file_name(fb,wkdir);
            else % if result is memory based and does not have filenabe, its name
                % should be defined here.
                outfile = fullfile(wkdir,[fb,'.sqw']);
            end
        end
        % Log frequency
        %------------------------------------------------------------------
        function rat = get_info_split_log_ratio(~)
            rat = config_store.instance().get_value('log_config','join_sqw_split_ratio');
        end
        function obj = set_info_split_log_ratio(obj,val)
            log = log_config;
            log.join_sqw_split_ratio = val;
        end
    end
end
function idx = fill_idx(bin_start,page_bin_distr)
% find indices of sub-page within large page with the same binning
%
% Generates sequence of kind:
% bin_start
%  1,    10,  20, 30
% page_bin_distr:
%  3,    2,   0,    5          -- sum(page_bin_distr) == 10;
% idx:
% 1,2,3, 10,11, 30,31,32,33,34 -- numel(idx) == 10
%
% should be better way of generating such sequence

to_use = page_bin_distr ~= 0;
page_bin_distr = page_bin_distr(to_use);
bin_start      = bin_start(to_use);

idx = zeros(sum(page_bin_distr),1);
ic = 0;
for i=1:numel(bin_start)
    idx((1:page_bin_distr(i))+ic) = bin_start(i):bin_start(i)+page_bin_distr(i)-1;
    ic = ic+page_bin_distr(i);
end
end
