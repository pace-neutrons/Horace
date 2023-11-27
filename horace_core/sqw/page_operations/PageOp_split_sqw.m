classdef PageOp_split_sqw < PageOpBase
    % Single page pixel operation and main gateway for
    % sqw.split  algorithm.
    %
    %
    properties
        % cellarray of the images for resulting sqw objects to be split into
        out_img;
        % cellarray of the pixels for resulting sqw objects to be split into
        out_pix;
        % cellarray to place target sqw objects to split original sqw
        out_sqw;
        % cellarray of pixel ranges for all contributing objects
        obj_pix_ranges;
        % cell array of write handles, used to store data in target sqw
        % files.
        write_handles;
    end
    properties(Access = protected)
        % the runid map for the initial sqw object to split
        runid_map_;
        % numbers of objects contributing to current page
        n_obj_contrib_to_page_;
        % array containing true if run descriped in experiment contributes
        % to pixels and false if it does not
        run_contributes_;
        % true, if the images also can not fit memory and need to be made
        % filebacked
        img_filebacked_;
    end
    methods
        function obj = PageOp_split_sqw(varargin)
            obj = obj@PageOpBase(varargin{:});
            obj.op_name_ = 'split_sqw';
            obj.split_at_bin_edges = false;
        end

        function obj = init(obj,in_sqw,pix_filebacked,img_filebacked)
            % initialize split_sqw algorithm.
            % Input:
            % in_sqw         -- initial sqw object to split
            % pix_filebacked -- it true, output sqw objects have to be
            %                   filebacked objects
            % img_filebacked -- it true, all split images do not fit memory
            %                   and algorithm should work with image
            %                   chunks.

            % set up inplace== true to not to generate write handle for
            % input sqw object.
            obj.inplace = true;
            % indirect usage of inplace property. When
            % inplace == true write handle is not generated for in_sqw as
            % we do not need write handle for init_sqw

            obj = init@PageOpBase(obj,in_sqw);
            % if write handle was generated for in_sqw due to errors in a
            % future, clear it up. We do not need it here
            obj.write_handle_ = [];
            % we do not need image for this type of operations. Save the
            % memory.
            obj.img_ = [];
            % prepare target sqw objects to split source into
            obj = obj.prepare_split_sqw(in_sqw,pix_filebacked,false,img_filebacked);
            % initialize target pix ranges for evaluation
            n_objects = numel(obj.out_img);
            obj.obj_pix_ranges = arrayfun(@(nobj)PixelDataBase.EMPTY_RANGE, ...
                1:n_objects, 'UniformOutput',false);
            obj.img_filebacked_ = img_filebacked;
            if img_filebacked
                % will operate with whole clusters of bins
                obj.split_at_bin_edges = true;
            end
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
                        obj_npix,obj_pix(obj.signal_idx,:),obj_pix(obj.var_idx,:));

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
                % reevaluate pix ranges for every object contributing to
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
                    obj.write_handles{splitobj_num}.save_img_chunk([], ...
                        obj.out_img{splitobj_num});
                end
            end
        end

        function [out_obj,obj] = finish_op(obj,varargin)
            % Finalize page operations. Specific to split_sqw as the result
            % here is very different from the majority of PageOp
            %
            % Input:
            % obj     -- instance of the page operations
            %
            % Returns:
            % out_obj -- array of output objects or cellarray of output
            %            files
            % obj     -- nullified PageOp object.

            obj.out_img       = obj.out_img(obj.run_contributes_);
            obj.out_sqw       = obj.out_sqw(obj.run_contributes_);
            obj.obj_pix_ranges= obj.obj_pix_ranges(obj.run_contributes_);

            % explicitly delete unused handles and non-contributing files
            % here, as  otherwise the deleteon will be delayed to random
            % moment in time and tests may found unnecessary files.
            cellfun(@wh_delete_,obj.write_handles);

            % this will remove unused  (non-contributed)  handles places
            obj.write_handles = obj.write_handles(obj.run_contributes_);
            % Allocate resulting sqw array or list of sqw files
            n_obj = numel(obj.out_img);
            if obj.img_filebacked_
                out_obj = cell(1,n_obj);
            else
                out_obj = repmat(sqw,[1,n_obj]);
            end
            for i=1:n_obj
                split_img =  obj.out_img{i};
                % Set single split object as the result of page operation
                if ~obj.img_filebacked_
                    obj.npix          = split_img.npix;
                    obj.sig_acc_      = split_img.s;
                    obj.var_acc_      = split_img.e;
                    obj.img_          = obj.out_sqw{i}.data;
                end
                obj.write_handle_ = obj.write_handles{i};
                obj.pix_          = obj.out_sqw{i}.pix;
                obj.pix_data_range_ = obj.obj_pix_ranges{i};
                % finalize result as with single object and store result
                % in the output array of objects.
                if obj.img_filebacked_
                    [out_obj{i},obj] = obj.finalize_fb_obj(obj.out_sqw{i});
                else
                    [out_obj(i),obj] = finish_op@PageOpBase(obj,obj.out_sqw{i});
                end
            end
        end
        %
    end
    % Class specific methods
    methods
        function [out_file,obj] = finalize_fb_obj(obj,in_sqw)
            % special overload used for filebacked operations only when
            % source data are located in file and target data are locate in
            % file because array of resulting filebacked objects does not
            % fit memory.
            % Input:
            % obj      -- initialized instance of this pageOp, containing
            %             the following fields:
            %    obj.write_handle_ = the write_handle class used for
            %                        writing data in target split file
            %    obj.pix_          = Empty instance of filebacked pixels to
            %                        be initialized
            %    obj.pix_data_range_= obj.obj_pix_ranges{i};
            %
            %
            % in_sqw   -- template for target filebacked object which would
            %             be finalized and deleted leaving file, pointint
            %             to it.
            % Returns:
            % out_file -- the name of the file, containing target sqw
            %             object
            pix   = obj.pix_;
            pix   = pix.set_data_range(obj.pix_data_range_);
            out_split_sqw      = in_sqw.copy();
            out_split_sqw.pix  = pix;
            out_split_sqw.data = [];% this will force dump not to write updated
            obj.img_           = [];% image as the image have been already
            % updated
            obj.is_tmp_file  = false;
            out_split_sqw    = out_split_sqw.finish_dump(obj);
            out_file = out_split_sqw.full_filename;

            obj.pix_  = PixelDataMemory();
            obj.npix_ = [];
            obj.write_handle_ = [];
            obj.is_tmp_file   = [];
        end

        function obj = prepare_split_sqw(obj,in_sqw,pix_filebacked,img_filebacked)
            % prepare list of sqw objects to split source object into.
            % Inputs:
            % in_sqw   -- initial sqw object to split into contributiong
            %             sqw objects
            % pix_filebacked
            %          -- if true, output sqw objects have to be filebacked
            %
            % Output:
            %  obj    -- page_op object, containing out_img and out_pix
            %            cellarray for parts of initial sqw object to split
            %
            obj.runid_map_ = in_sqw.runid_map;
            %
            main_header = in_sqw.main_header;
            exp_info    = in_sqw.experiment_info;
            data        = in_sqw.data;
            n_runs      = main_header.nfiles;
            obj.run_contributes_ = false(1,n_runs);
            obj.out_img = cell(1,n_runs);
            obj.out_pix = cell(1,n_runs);
            obj.out_sqw = cell(1,n_runs);

            n_bins = numel(data.s);

            if img_filebacked
                % 3 to calculate block averages
                data = struct('s',[],'e',[],'npix',[]);
            else
                % 1D image with 3 accumulators for calculating image
                data = struct('s',zeros(n_bins,1),'e',zeros(n_bins,1),'npix',zeros(n_bins,1));
            end
            [~,file_in]   = fileparts(in_sqw.data.filename);
            for i = 1:n_runs
                % these objects contain the same copy of image, so
                % would not allocate additional memory for it.
                obj_i = in_sqw;
                obj_i.experiment_info = exp_info.get_subobj(i,'-indexes');

                run_id         = obj_i.experiment_info.expdata(1).run_id;
                split_filename = sprintf('%s_runID%07d.sqw',file_in,run_id );
                if ~isempty(obj.outfile)
                    targ_file           = fullfile(obj.outfile,split_filename);
                    obj_i.full_filename = targ_file;
                else
                    targ_file           = '';
                end

                if pix_filebacked
                    obj_i.pix    = PixelDataFileBacked();
                    obj_i.pix.full_filename = split_filename;
                else
                    obj_i.pix    = PixelDataMemory();
                end
                obj.out_sqw{i}   = obj_i;
                obj.out_img{i}   = data;

                obj.write_handles{i} = obj_i.get_write_handle(targ_file);
            end
        end
    end
    methods(Access =protected)
        function is = get_exp_modified(~)
            % is_exp_modified controls calculations of unique runid-s
            % during page_op.
            %
            % Here we calculate unique run_id differntly, so always false
            is = false;
        end

    end
end

function wh_delete_(wh)
% utility to delete temporary sqw file controlled by write handle provided
% as input if the handle have not been used to write any pixels to this file.
if isempty(wh)
    return;
end
if wh.npix_written == 0
    wh.delete();
end
end
