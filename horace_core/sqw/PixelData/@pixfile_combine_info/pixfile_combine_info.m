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

        %   run_label   Indicates how to re-label the run index (pix(5,...)
        %          'fileno'      relabel run index as the index of the file
        %                        in the list infiles
        %          'nochange'    use the run index as in the input file
        %                        numeric array  offset run numbers for ith
        %                        file by ith element of the array
        %          This option exists to deal with three limiting cases:
        %      (1) The run index is already written to the files correctly indexed into the header
        %          e.g. as when temporary files have been written during cut_sqw
        %      (2) There is one file per run, and the run index in the header block is the file
        %          index e.g. as in the creating of the master sqw file
        %      (3) The files correspond to several runs in general, which need to
        %          be offset to give the run indices into the collective list of run parameters
        run_label;

        % numbers of files used as run_label for pixels if relabel_with_fnum
        % and change_fileno are set to true
        filenum
        %
        % true if pixel id from each contributing file should be replaced by contributing file number
        relabel_with_fnum;
        % true if pixel id for each pixel from contributing files should be changed.
        change_fileno
    end
    %
    properties(Access=public)
        npix_cumsum = [];  % auxiliary property used by cut_sqw operating
        %                   in file->file mode
        %                   and containing cumsum of npix array
        %                   where npix is the common npix image array for
        %                   all contributing files.
    end
    %
    properties(Access = protected)

        pos_npixstart_ = [];
        pos_pixstart_  = [];

        %
        run_label_ = 'nochange';
        %
        filenum_ = [];
    end
    methods
        %
        function obj = pixfile_combine_info(varargin)
            % Build instance of the class, which provides the information
            % for combining pixels obtained from separate sqw(tmp) files.
            %
            % Inputs:
            % infiles -- cellarray of full names of the files to combine
            % nbins   -- number of bins (number of elements in npix array)
            %            in the tmp files and target sqw file (should be
            %            the same for all components so one number)
            %pos_npixstart
            %         -- array containing the locations of the npix
            %            array in binary sqw files on hdd. Size equal to
            %             number of contributing files.
            %pos_pixstart
            %         -- array containing the locations of the pix
            %            array in binary sqw files on hdd. Size equal to
            %            number of contributing files.
            %npix_each_file
            %         -- array containing number of pixels in each
            %            contributing sqw(tmp) file.
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
            % filenums  -- array, defining the numbers for each
            %              contributing file. If not present, the contributing
            %              files are numbered by integers running from 1 to
            %              n-files
            if nargin == 0
                return
            end
            flds = obj.saveableFields();
            [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                flds(1:end-1), false, varargin{:});
            if ~isempty(remains)
                if numel(remains)==1
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
        function pos = get.pos_npixstart(obj)
            pos = obj.pos_npixstart_;
        end
        function obj = set.pos_npixstart(obj,val)
            if ~isnumeric(val)
                error('HORACE:pixfile_combine_info:invalid_argument',...
                    'pos_npixstart has to be numeric array containing information about npix location on hdd')
            end
            obj.pos_npixstart_ = val(:)';
            if numel(val) == 1 % each contributing file has npix array
                % located at the same position
                obj.pos_npixstart_ = ones(1,obj.nfiles)*val;
            end
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function pos = get.pos_pixstart(obj)
            pos = obj.pos_pixstart_;
        end
        function obj = set.pos_pixstart(obj,val)
            if ~isnumeric(val)
                error('HORACE:pixfile_combine_info:invalid_argument',...
                    'pos_pixstart has to be numeric array containing information about pix location on hdd')
            end
            obj.pos_pixstart_ = val(:)';
            if numel(val) == 1 % each contributing file has pixels data
                % located at the same position
                obj.pos_pixstart_  = ones(1,obj.nfiles)*val;
            end
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end
        end
        %
        function rl= get.run_label(obj)
            rl = obj.run_label_;
        end
        function obj = set.run_label(obj,val)
            if ischar(val)
                if ~(strcmpi(val,'nochange') || strcmpi(val,'fileno'))
                    error('HORACE:pixfile_combine_info:invalid_argument',...
                        'Invalid string value "%s" for run_label. Can be only "nochange" or "fileno"',...
                        val)
                end
                obj.run_label_ = val;
            elseif (isnumeric(val) && numel(val)==obj.nfiles)
                obj.run_label_ = val(:)';
            else
                error('HORACE:pixfile_combine_info:invalid_argument',...
                    ['Invalid value for run_label. Array of run_id-s should be either specific string' ...
                    'or array of unique numbers, providing run_id for each contributing file'])
            end
        end

        %
        function is = get.relabel_with_fnum(obj)
            % true if pixel id from each contributing file
            % should be replaced by contributing file number
            if ischar(obj.run_label)
                if strcmpi(obj.run_label,'fileno')
                    is  = true;
                else
                    is = false;
                end
            else
                is = false;
            end
        end
        %
        function is = get.change_fileno(obj)
            % true if pixel id for each pixel from contributing
            % files should be changed.
            if ischar(obj.run_label)
                if strcmpi(obj.run_label,'nochange')
                    is=false;
                elseif strcmpi(obj.run_label,'fileno')
                    is = true;
                end
            elseif isnumeric(obj.run_label)
                is=true;
            end
        end
        %
        function fn = get.filenum(obj)
            if isempty(obj.filenum_)
                fn = 1:obj.nfiles;
            else
                fn = obj.filenum_;
            end
        end
        function parts_carr= split_into_parts(obj,n_workers)
            % function divided pixfile_combine_info into the specified number
            % of (almost) equal parts to send it for processing
            % on parallel system
            n_tasks = obj.nfiles;
            if n_workers> n_tasks
                n_workers = n_tasks;
            end
            % calculate the indexes of an array to divide job array among
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

            parts_carr = cell(1,n_workers);
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
                pnpixtot       = obj.npix_each_file(split_ind(1,i):split_ind(2,i));
                pfilenums    = filenums(split_ind(1,i):split_ind(2,i));
                %
                parts_carr{i} = pixfile_combine_info(part_files,pnbins,ppos_npixstart,ppos_pixstart,pnpixtot,prun_label,pfilenums);
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
            % Constrain the number of files and the file information,
            % contained in class by the number of files (nfiles_to_leave) provided.
            %
            % Checks if pixel info in all remaining files remains consistent;
            %
            %Usage:
            %>>obj = obj.trim_nfiles(nfiles_to_leave)
            %
            % leaves the info stored in the file corresponding to the
            % number of files provided
            %
            if nfiles_to_leave >= obj.nfiles
                return;
            end
            obj.do_check_combo_arg = false;
            obj.infiles = obj.infiles(1:nfiles_to_leave);
            %
            obj.pos_npixstart = obj.pos_npixstart(1:nfiles_to_leave);
            % array of starting positions of the pix information in each
            % contributing file
            obj.pos_pixstart = obj.pos_pixstart(1:nfiles_to_leave);
            obj.npix_each_file= obj.npix_each_file(1:nfiles_to_leave);

            obj.num_pixels_ = uint64(sum(obj.npix_each_file));
            if ~isempty(obj.filenum_)
                obj.filenum_ = obj.filenum_(1:nfiles_to_leave);
            end
            obj.do_check_combo_arg = true;
            obj = obj.check_combo_arg();
        end
    end
    %----------------------------------------------------------------------
    methods(Static)
        function data_range = recalc_data_range_from_loaders(ldrs,keep_runid)
            % Recalculate pixels range using list of defined loaders
            if nargin == 1
                keep_runid = true;
            end
            n_files = numel(ldrs);
            ldr = ldrs{1};
            data_range= ldr.get_data_range();
            for i=2:n_files
                ldr = ldrs{i};
                loc_range  = ldr.get_data_range();
                data_range = minmax_ranges(loc_range,data_range);
            end
            % the run_id will be recalculated according to the file names
            if ~keep_runid
                idx = PixelDataBase.field_index('run_idx');
                data_range(:,idx) = [1;n_files];
            end
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
                'run_label','npix_cumsum'};
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
