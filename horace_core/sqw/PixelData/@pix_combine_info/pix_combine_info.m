classdef pix_combine_info < serializable
    % Helper class used to carry out and provide information
    % necessary for pixel combining using write_nsqw_to_sqw algorithm,
    % or similar algorithm, deployed when running cut_sqw in file->file
    % mode
    %
    properties(Dependent)
        nfiles;       % number of files, contributing into final result
        infiles;      % cellarray of filenames to combine.
        %
        num_pixels;    % total number of pixels to combine
        npix_each_file; % array defining numbers of pixels stored in each
        %                contributing file
        %
        % number of bins (number of elements in npix array) in the
        % contributing sqw(tmp) files. Should be the same for all
        % files to be able to combine them together
        nbins;


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


        pix_range    % Global range of all pixels, intended for combining
        data_range   % Global range of all pixel data, i.e. coordinates, signal error and other pixel parameters

        % numbers of files used as run_label for pixels if relabel_with_fnum
        % and change_fileno are set to true
        filenum
        %
        % true if pixel id from each contributing file should be replaced by contributing file number
        relabel_with_fnum;
        % true if pixel id for each pixel from contributing files should be changed.
        change_fileno
    end
    properties(Dependent,Hidden)
        % The property, which describes the pixel data layout on disk or in
        % memory and all additional properties describing pix array
        metadata;
        data_wrap;
        % PixelDataBase interface
        full_filename
        is_filebacked
        % the property here to support PixelData interface. Never false, as
        % this kind of data should be never (knowingly) misaligned
        is_misaligned
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
        num_pixels_ = 0
        %
        infiles_ = {}  % cellarray of filenames to combine
        pos_npixstart_ = [];
        pos_pixstart_  = [];
        % array of numbers of pixels stored in each contributing file
        npix_each_file_ = []

        %
        run_label_ = 'nochange';
        %
        nbins_ = 0;
        %
        filenum_ = [];
        % Global range of all pixels, intended for combining
        data_range_ = PixelDataBase.EMPTY_RANGE;
        full_filename_;
    end
    methods
        %
        function obj = pix_combine_info(infiles,nbins,pos_npixstart, ...
                pos_pixstart,npix_each_file,run_label,filenums)
            % Build instance of the class, which provides the information
            % for combining pixels obtained from separate sqw(tmp) files.
            %
            % Inputs:
            % infiles -- cellarray of full names of the files to combine
            % nbins   -- number of bins (number of elements in npix array)
            %            in the tmp files and target sqw file (should be
            %            the same for all components so one number)
            %pos_npixstart -- array containing the locations of the npix
            %            array in binary sqw files on hdd. Size equal to
            %             number of contributing files.
            %pos_pixstart -- array containing the locations of the pix
            %            array in binary sqw files on hdd. Size equal to
            %            number of contributing files.
            %npix_each_file -- array containing number of pixels in each
            %            contributing sqw(tmp) file.
            %run_label
            %      --either
            %            the string containing information on the
            %            treatment of the run_ids, identifying each each
            %            pixel of the PixelData. As string it may be equal
            %      either:
            % 'nochange' - the pixel id-s should be kept as provided within
            %              contributing files
            %      or:
            % 'fileno'   -- the pixels id-s should be modified and be equal
            %               to the numbers of contributing files
            %     -- or
            %            array of unique numbers, providing run_id for each
            %            contributing run(file)
            % OPTIONAL:
            % filenums  -- array, defining the numbers for each
            %              contributing file. If not present, the contributing
            %              files are numbered by integers running from 1 to
            %              n-files
            if nargin == 0
                return
            end
            obj.do_check_combo_arg_ = false;
            obj.infiles = infiles;
            if ~exist('pos_npixstart','var') % pre-initialization for file-based combining of the cuts.
                nfiles = obj.nfiles;
                obj.pos_npixstart = zeros(1,nfiles);
                obj.pos_pixstart  = zeros(1,nfiles);
                obj.npix_each_file = zeros(1,nfiles);
                if exist('nbins','var')
                    obj.nbins   = nbins;
                end
                return;
            end
            obj.nbins         = nbins;
            obj.pos_npixstart = pos_npixstart;
            obj.pos_pixstart  = pos_pixstart;
            obj.npix_each_file = npix_each_file;
            if exist('run_label','var')
                obj.run_label     = run_label;
            end
            if exist('filenums','var')
                obj.filenum_ = filenums;
            end
            obj.do_check_combo_arg_= true;
            obj = check_combo_arg(obj);

        end
        %------------------------------------------------------------------
        function nf   = get.nfiles(obj)
            % number of contributing files
            nf = numel(obj.infiles);
        end
        function infls = get.infiles(obj)
            infls = obj.infiles_;
        end
        function obj = set.infiles(obj,val)
            if ~iscellstr(val)
                if isstring(val)
                    val = {val};
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
        %
        %------------------------------------------------------------------
        function npix = get.num_pixels(obj)
            % total number of pixels in all contributing files
            npix = obj.num_pixels_;
        end
        function npix_tot = get.npix_each_file(obj)
            npix_tot = obj.npix_each_file_;
        end
        function obj= set.npix_each_file(obj,val)
            if ~isnumeric(val)
                error('HORACE:pix_combine_info:invalid_argument',...
                    'npix_each_file has to be numeric array containing information about number of pixels in each contributing file')
            end
            obj.npix_each_file_ = val(:)';
            if numel(val) == 1 % the number of pixels per each file is the same
                obj.npix_each_file_  = ones(1,obj.nfiles)*val;
            end
            obj.num_pixels_ = uint64(sum(obj.npix_each_file_));
            if obj.do_check_combo_arg_
                obj = check_combo_arg(obj);
            end

        end
        %------------------------------------------------------------------
        function nb = get.nbins(obj)
            nb = obj.nbins_;
        end
        function obj = set.nbins(obj,val)
            if ~isnumeric(val) || val < 1
                error('HORACE:pix_combine_info:invalid_argument', ...
                    'number of bins for pix_combine info should be positive number. It is: %s',...
                    evalc('disp(val)'));
            end
            obj.nbins_ = val;
        end
        %------------------------------------------------------------------
        function pos = get.pos_npixstart(obj)
            pos = obj.pos_npixstart_;
        end
        function obj = set.pos_npixstart(obj,val)
            if ~isnumeric(val)
                error('HORACE:pix_combine_info:invalid_argument',...
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
                error('HORACE:pix_combine_info:invalid_argument',...
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
        function range = get.pix_range(obj)
            range = obj.data_range_(:,1:4);
        end
        function obj = set.pix_range(obj,val)
            if ~(isnumeric(val) && isequal(size(val),[2,4]) )
                error('HORACE:pix_combine_info:invalid_argument',...
                    'pix_range size has to be a numeric array of 2x4 elements. It is:\n %s', ...
                    disp2str(val));
            end
            obj.data_range_(:,1:4) = val;

        end
        %
        function range = get.data_range(obj)
            range = obj.data_range_;
        end
        function obj = set.data_range(obj,val)
            if ~(isnumeric(val) && isequal(size(val),[2,9]) )
                error('HORACE:pix_combine_info:invalid_argument',...
                    'data_range size has to be numeric array of 2x9 elements. It is: %s', ...
                    disp2str(val));
            end
            obj.data_range_ = val;
        end
        %
        function rl= get.run_label(obj)
            rl = obj.run_label_;
        end
        function obj = set.run_label(obj,val)
            if ischar(val)
                if ~(strcmpi(val,'nochange') || strcmpi(val,'fileno'))
                    error('HORACE:pix_combine_info:invalid_argument',...
                        'Invalid string value "%s" for run_label. Can be only "nochange" or "fileno"',...
                        val)
                end
                obj.run_label_ = val;
            elseif (isnumeric(val) && numel(val)==obj.nfiles)
                obj.run_label_ = val(:)';
            else
                error('HORACE:pix_combine_info:invalid_argument',...
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
            % function divided pix_combine_info into the specified number
            % of (almost) equal parts to send it for processing
            % on parallel system
            n_tasks = obj.nfiles;
            if n_workers> n_tasks
                n_workers = n_tasks;
            end
            % caclulate the indexes of an array to divide job array among
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
                parts_carr{i} = pix_combine_info(part_files,pnbins,ppos_npixstart,ppos_pixstart,pnpixtot,prun_label,pfilenums);
            end
        end
        function md = get.metadata(obj)
            md = pix_metadata(obj);
        end
        function dw = get.data_wrap(obj)
            dw = pix_data(obj);
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
        end
        function fn = get.full_filename(obj)
            fn = obj.full_filename_;
        end
        function obj = set.full_filename(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:pix_combine_info:invalid_argument', ...
                    'fill_filename should be a string, describing full name of the file on disk. It is %s', ...
                    disp2str(val));
            end
            obj.full_filename_ = val;
        end
        %
        function is = get.is_filebacked(~)
            is = false;
        end
        function is = get.is_misaligned(~)
            is = false;
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
                loc_range = ldr.get_data_range();
                data_range = [min([loc_range(1,:);data_range(1,:)],[],1);
                    max([loc_range(2,:);data_range(2,:)],[],1)];
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
    properties(Constant,Access=protected)
        fields_to_save_ = {'infiles','npix_each_file',...
            'pos_npixstart','pos_pixstart','run_label','nbins',...
            'npix_cumsum'};
    end

    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(~)
            flds = pix_combine_info.fields_to_save_;
        end
        %
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            if numel(obj.infiles_) ~= numel(obj.pos_npixstart_)
                error('HORACE:pix_combine_info:invalid_argument',...
                    'number of npixstart positions: %d not equal to the number of files to combine: %d',...
                    numel(obj.pos_npixstart_),numel(obj.infiles_));
            end
            if numel(obj.infiles_) ~= numel(obj.pos_pixstart_)
                error('HORACE:pix_combine_info:invalid_argument',...
                    'number of pixstart positions: %d not equal to the number of files to combine: %d',...
                    numel(obj.pos_pixstart_),numel(obj.infiles_));
            end
            if numel(obj.infiles_) ~= numel(obj.npix_each_file_)
                error('HORACE:pix_combine_info:invalid_argument',...
                    'numel of npix for each file : %d not equal to the number of files to combine: %d',...
                    numel(obj.npix_each_file_),numel(obj.infiles_));
            end
        end
    end
end
