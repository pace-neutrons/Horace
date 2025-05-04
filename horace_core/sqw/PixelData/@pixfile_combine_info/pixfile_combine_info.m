classdef pixfile_combine_info < MultipixBase
    % Helper class used to carry out and provide information
    % necessary for pixel combining using write_nsqw_to_sqw algorithm,
    % or similar algorithm, deployed when running cut_sqw in file->file
    % mode
    %
    properties(Dependent)
        %
        % array of starting positions of the npix information in each
        % contributing file
        pos_npixstart;

        % array of starting positions of the pix information in each
        % contributing file
        pos_pixstart;
    end
    %
    properties(Access=public)
        npix_cumsum = [];  % auxiliary property used by cut_sqw operating
        %                   in file->file mode
        %                   and containing cumsum of npix array
        %                   where npix is the common npix image array for
        %                   all contributing files.
        keep_precision = true;  % helper property used to satisfy pix
        %                   interface in PageOp family of operations.
    end
    %
    properties(Access = protected)
        pos_npixstart_ = [];
        pos_pixstart_  = [];
        % cellarray of loaders used to access page data
        loaders_list_ = {};
        % clean-up object closing the file-accessor when class goes out of
        % scope
        clean_obj_;
        % is access to files organized through data loaders or using
        % MATLAB binary access.
        binary_access_ = false;
    end
    methods
        function obj = set_data_range(obj,varargin)
            % method to satisfy pix interface in PageOp family of
            % algorithms. At the moment doing nothing. It looks like it
            % should not do anything.
            %
        end
        function obj = clear_alignment(obj)
            % method to satisfy pix interface in PageOp family of
            % algorithms. At the moment doing nothing. It looks like it
            % should not do anything.
            %
        end
        %
        function obj = pixfile_combine_info(varargin)
            % Build instance of the class, which provides the information
            % for combining pixels obtained from separate sqw(tmp) files.
            %
            % Inputs:
            % infiles -- cellarray of full names of the files to combine
            % Optional:
            % nbins   -- number of bins (number of elements in npix array)
            %            in the tmp files and target sqw file (should be
            %            the same for all components so one number)
            %npix_each_file
            %         -- array containing number of pixels in each
            %            contributing sqw(tmp) file.
            %pos_npixstart
            %         -- array containing the locations of the npix
            %            array in binary sqw files on hdd. Size equal to
            %             number of contributing files.
            %pos_pixstart
            %         -- array containing the locations of the pix
            %            array in binary sqw files on hdd. Size equal to
            %            number of contributing files.
            %run_label
            %     either:
            %          - the string containing information on the
            %            treatment of the run_ids, identifying each
            %            pixel of the PixelData. It may be equal
            %      or:
            %          - 'nochange' the string stating that the pixel id-s
            %             should be kept as provided within contributing
            %             files
            %      or:
            %         -  'fileno' the string stating that the pixels id-s
            %             should be modified and be equal
            %               to the numbers of contributing files
            %      or:
            %         -   array of unique numbers, providing run_id for each
            %             contributing run(file)
            % OPTIONAL:
            % filenum   -- array, defining the numbers for each
            %              contributing file. If not present, the contributing
            %              files are numbered by integers running from 1 to
            %              n-files
            obj = obj@MultipixBase();
            if nargin == 0
                return
            end
            obj = obj.init(varargin{:});
        end
        function obj = init(obj,varargin)
            [obj,remains] = init@MultipixBase(obj,varargin{:});
            flds = {'pos_npixstart','pos_pixstart','run_label','filenum'};
            [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                flds, false, remains{:});
            if ~isempty(remains)
                if isscalar(remains)
                    obj.filenum_ = remains{1};
                else
                    error('HORACE:pixfile_combine_info:invalid_argument',[ ...
                        'pixfile_combine_info accepts up to 7 input arguments.\n' ...
                        'got: %d arguments. Last have not been recognized: %s\n'], ...
                        numel(varargin),disp2str(remains))
                end
            end
        end
        %------------------------------------------------------------------
        function obj = init_pix_access(obj)
            % initialize access to contributing pixels.
            obj = init_pix_access_(obj);
        end

        function [data,npix_chunk] = get_dataset_page(obj, ...
                n_dataset,pix_pos_start,npix_idx)
            % Return pixel data and pixel bin sub-distribution for the
            % particular dataset out of multiple pixel datasets, stored
            % within the class.
            % Inputs:
            % n_dataset -- number of dataset to get data from
            % pix_pos_start
            %           -- the position in pixel array
            %              where requested pixel data are located.
            %              Should be externaly synchronized with npix.
            %              Can be calculated here, but ignored for saving
            %              time and memory.
            % npix_idx  -- two-element array containing first and last
            %              indices of bins containing
            %              distribution of pixels over bins.
            %
            if obj.binary_access_
                npix_chunk = obj.get_npix_block(n_dataset,npix_idx(1),npix_idx(2));
                npix_in_block = sum(npix_chunk);
                pix_pos_end   = pix_pos_start+npix_in_block-1;

                data          = obj.get_raw_pix(n_dataset,pix_pos_start,pix_pos_end);
            else
                ldr = obj.loaders_list_{n_dataset};
                npix_chunk = ldr.get_npix_block(npix_idx(1),npix_idx(2));
                npix_in_block = sum(npix_chunk);
                pix_pos_end   = pix_pos_start+npix_in_block-1;

                data          = ldr.get_raw_pix(pix_pos_start,pix_pos_end);
            end
        end
        %------------------------------------------------------------------
        function pos = get.pos_npixstart(obj)
            pos = obj.pos_npixstart_;
        end
        function obj = set.pos_npixstart(obj,val)
            % Accepts positive array of positions of pix distributon in
            % each file or single value if the position of all pixels in
            % all files is the same
            obj = set_pos_npix_start_(obj,val);
        end
        %
        function pos = get.pos_pixstart(obj)
            pos = obj.pos_pixstart_;
        end
        function obj = set.pos_pixstart(obj,val)
            % Accepts positive array of positions of pixels in each file or
            % single value if the position of all pixels in all files is
            % the same
            obj = set_pos_pixstart_(obj,val);
        end
        %
        function parts_holder= split_into_parts(obj,n_workers)
            % function divided pixfile_combine_info into the specified number
            % of (almost) equal parts to send it for processing
            % on parallel system
            n_tasks = obj.nfiles;
            if n_workers> n_tasks
                n_workers = n_tasks;
            end
            % calculate the indices of an array to divide job array among
            % all workers
            split_ind= calc_job_indexes_(n_tasks,n_workers);
            files   = obj.infiles;
            if isnumeric(files) % its opened files
                files = cell(1,n_tasks);
                for i=1:n_tasks
                    files{i} = fopen(obj.infiles(i));
                    fclose(obj.infiles(i));
                end
            end

            parts_holder = cell(1,n_workers);
            pnbins = obj.nbins;
            filenums = 1:n_tasks;
            for i=1:n_workers
                part_files    = files(split_ind(1,i):split_ind(2,i));
                ppos_npixstart = obj.pos_npixstart(split_ind(1,i):split_ind(2,i));
                ppos_pixstart  = obj.pos_pixstart (split_ind(1,i):split_ind(2,i));
                if ischar(obj.run_label)
                    prun_label  = obj.run_label;
                else
                    prun_label     = obj.run_label(split_ind(1,i):split_ind(2,i));
                end
                pnpixtot   = obj.npix_each_file(split_ind(1,i):split_ind(2,i));
                pfilenums  = filenums(split_ind(1,i):split_ind(2,i));
                %
                parts_holder{i} = pixfile_combine_info(part_files,pnbins,pnpixtot,ppos_npixstart,ppos_pixstart,prun_label,pfilenums);
            end
        end
        %
        %
        function obj = recalc_data_range(obj)
            % recalculate common range for all pixels analysing pix ranges
            % from all contributing files
            %
            obj = recalc_pix_range_(obj);
        end
        %
        function obj=trim_nfiles(obj,nfiles_to_leave)
            % Truncate the number of files and the file information,
            % contained in class by the number of files (nfiles_to_leave)
            % provided.
            %
            % Checks if pixel info in all remaining files remains consistent;
            %
            %Usage:
            %>>obj = obj.trim_nfiles(nfiles_to_leave)
            %
            % reduces the info stored in the file corresponding by the
            % number of files provided
            %
            obj = trim_nfiles_(obj,nfiles_to_leave);
        end
        function obj = close_faccessors(obj)
            % close access to partial input files
            for i=1:numel(obj.loaders_list_)
                if ~isempty(obj.loaders_list_)
                    if obj.binary_access_
                        obj.loaders_list_{i} = fclose(obj.loaders_list_{i});
                    else
                        obj.loaders_list_{i}.delete();
                    end
                end
            end
            obj.loaders_list_ = {};
        end

    end
    %----------------------------------------------------------------------
    methods(Access=protected)
        function is = get_is_filebacked(~)
            is = true;
        end
        function obj = set_npix_each_file(obj,val)
            % accepts the numeric array which defines number of pixels
            % in each file or signle value if total number of pixels
            % in each file is the same
            obj = set_npix_each_file_(obj,val);
        end
        function obj = set_infiles(obj,val)
            % Main method which sets list of input files
            if ~iscellstr(val)
                if istext(val)
                    val = cellstr(val);
                else
                    error('HORACE:pix_combine_info:invalid_argument',...
                        'infiles input should be cellarray of filenames to combine');
                end
            end
            obj.infiles_ = val(:);
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %==================================================================
        % BLOCKS supporing future Re #1436 operations
        function pix_data = get_raw_pix(obj,n_file,pix_pos_start,pix_pos_end)
            % read pixel block of the appropriate size located at the
            % specified position in the binary file
            %Inputs:
            % n_file       -- the number of object to read
            % pos_pixstart -- the initial position of the pix block to read
            % pix_pos_end  -- final poistion of pixels to read

            pix_data = get_raw_pix_(obj,n_file,pix_pos_start,pix_pos_end);
        end
        function npix_block = get_npix_block(obj,ds_num,ibin_start,ibin_end)
            % Read npix block describing the distribution of pixels over
            % image bins
            %
            %   >> npix_block =get_npix_section_(obj,ds_num,ibin_start,ibin_max)
            %
            % Input:
            % ------
            %   ds_num      -- number of dataset to read
            %   ibin_start  -- First bin of data to read
            %   ibin_max    -- last bin of data to read
            %
            % Output:
            % -------
            %   npix_block -- the block npix(ibin_start:ibin_end) for
            %                  n_file's input file
            npix_block = get_npix_block_(obj,ds_num,ibin_start,ibin_end);
        end


    end
    %----------------------------------------------------------------------
    % SERIALIZABLE INTERFACE
    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(obj)
            fld1 = saveableFields@MultipixBase(obj);
            flds = {'pos_npixstart','pos_pixstart',...
                'filenum','npix_cumsum'};
            flds = [fld1(:);flds(:)];
        end

        %
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            if ~isempty(obj.infiles_) && isempty(obj.pos_npixstart_)
                nfls = obj.nfiles;
                obj.pos_npixstart_  = zeros(1,nfls);
                obj.pos_pixstart_   = zeros(1,nfls);
                obj.npix_each_file_ = zeros(1,nfls);
            end
            if numel(obj.infiles_) ~= numel(obj.pos_npixstart_)
                error('HORACE:pixfile_combine_info:invalid_argument',...
                    'number of npixstart positions: %d not equal to the number of files to combine: %d',...
                    numel(obj.pos_npixstart_),numel(obj.infiles_));
            end
            if numel(obj.infiles_) ~= numel(obj.pos_pixstart_)
                error('HORACE:pixfile_combine_info:invalid_argument',...
                    'number of pixstart positions: %d not equal to the number of files to combine: %d',...
                    numel(obj.pos_pixstart_),numel(obj.infiles_));
            end
            if numel(obj.infiles_) ~= numel(obj.npix_each_file_)
                error('HORACE:pixfile_combine_info:invalid_argument',...
                    'numel of npix for each file : %d not equal to the number of files to combine: %d',...
                    numel(obj.npix_each_file_),numel(obj.infiles_));
            end
        end
    end
end
