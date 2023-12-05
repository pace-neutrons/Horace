classdef MultipixBase < serializable
    % The class-base for helper classes, used to keep information about multiple
    % pixels datasets before they are combined together.
    %
    properties(Dependent)
        nfiles;       % number of files or objects contributing into final
        %               result
        infiles;      % cellarray of filenames to combine.
        %
        num_pixels;   % total number of pixels to combine in all
        %                contributing pixels datasets or files
        npix_each_file; % array defining numbers of pixels stored in each
        %                contributing file or datasets
        %
        % number of bins (number of elements in npix array) in the
        % contributing sqw(tmp) files. Should be the same for all
        % files to be able to combine them together
        nbins;

        pix_range    % Global range of all pixels, intended for combining
        data_range   % Global range of all pixel data, i.e. coordinates, signal error and other pixel parameters

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
    %
    properties(Access = protected)
        num_pixels_ = 0
        %
        infiles_ = {}  % cellarray of filenames or objects to combine

        % array of numbers of pixels stored in each contributing file or
        % objects
        npix_each_file_ = []

        %
        nbins_ = 0;

        % Global range of all pixels, intended for combining
        data_range_ = PixelDataBase.EMPTY_RANGE;
        full_filename_;
    end
    methods
        %
        function obj = MultipixBase(varargin)
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
                    error('HORACE:pix_combine_info:invalid_argument',[ ...
                        'pix_combine_info accepts up to 7 input arguments.\n' ...
                        'got: %d arguments. Last have not been recognized: %s\n'], ...
                        numel(varargin),disp2str(remains))
                end
            end
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
        function fn = get.full_filename(obj)
            fn = obj.full_filename_;
        end
        function obj = set.full_filename(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HORACE:MultipixBase:invalid_argument', ...
                    'fill_filename should be a string, describing full name of the file on disk. It is %s', ...
                    disp2str(val));
            end
            obj.full_filename_ = val;
        end
        %
        function is = get.is_filebacked(~)
            is = true;
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
        function  flds = saveableFields(~)
            flds = {'infiles','nbins','npix_each_file'};
        end
        %
    end
end
