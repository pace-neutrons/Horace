classdef MultipixBase < serializable
    % The class-base for helper classes, used to keep information about multiple
    % pixels datasets before they are combined together.
    %
    properties(Dependent)
        nfiles;       % number of files or objects contributing into final
        %               result
        infiles;      % cellarray of filenames or objects to combine.
        %
        num_pixels;   % total number of pixels to combine in all
        %               contributing pixels datasets or files
        npix_each_file; % array defining numbers of pixels stored in each
        %                contributing file or datasets
        %
        % number of bins (number of elements in npix array) in the
        % contributing sqw(tmp) files. Should be the same for all
        % files to be able to combine them together
        nbins;

        pix_range    % Global range of all pixels, intended for combining
        data_range   % Global range of all pixel data, i.e. coordinates, signal error and other pixel parameters

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
    properties(Dependent,Hidden)
        %------------------------------------------------------------------
        % The properties to support PixelDataBase interface:
        %
        % The property, which describes the pixel data layout on disk or in
        % memory and all additional properties describing pix array
        metadata;
        % returns data_wrap as for PixelDataFilebacked class, but the data
        % are insufficient to recover the class
        data_wrap;
        % Unlike PixelDataBase contains name of target file to save
        % all combined data together
        full_filename
        % always true, as the data are filebacked
        is_filebacked
        % Always false, as this kind of data are never misaligned and
        % if components are misaligned, they will be aligned while retrieved
        % from components during join/combine operation.
        is_misaligned
        %------------------------------------------------------------------
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
        %
        run_label_ = 'nochange';
        %
        filenum_ = [];
    end
    methods
        %
        function obj = MultipixBase(varargin)
            % Build instance of the class, which provides the information
            % for combining pixels obtained from separate sqw(tmp) files.
            %
            % Inputs:
            % infiles -- cellarray of full names of the files or objects to combine
            % Optional:
            % nbins   -- number of bins (number of elements in npix array)
            %            in the tmp files and target sqw file (should be
            %            the same for all components so one number)
            % npix_each_file
            %         -- array containing number of pixels in each
            %            contributing sqw(tmp) file.
            if nargin == 0
                return
            end
            obj = obj.init(varargin{:});
        end
        function [obj,remains] = init(obj,varargin)
            if nargin == 1
                return;
            end
            flds = {'infiles','nbins','npix_each_file'};
            nfld = numel(flds);
            if nargin> nfld
                remains = varargin(nfld+1:end);
            else
                remains = {};
            end
            obj.do_check_combo_arg_= false;
            n_inp = min(nfld,numel(varargin));
            for i=1:n_inp
                obj.(flds{i})  = varargin{i};
            end
            obj.do_check_combo_arg_= true;
        end
        %------------------------------------------------------------------
        function nf   = get.nfiles(obj)
            % number of contributing files
            present = cellfun(@(x)~isempty(x),obj.infiles_);
            nf = sum(present);
        end
        function infls = get.infiles(obj)
            infls = obj.infiles_;
        end
        function obj = set.infiles(obj,val)
            obj = set_infiles(obj,val);
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
            % If defined, accepts a numeric array which defines number
            % of pixels in each file or single value if total number of
            % pixels in each file is the same
            obj = set_npix_each_file(obj,val);
        end
        %------------------------------------------------------------------
        function nb = get.nbins(obj)
            nb = obj.nbins_;
        end
        function obj = set.nbins(obj,val)
            % set number of bins property
            % val -- single positive value, describing number of bins in
            %        the images to be combined. Single value as have to be
            %        same for all images
            obj = set_nbins_(obj,val);
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
        function fn = get.full_filename(obj)
            fn = obj.full_filename_;
        end
        function obj = set.full_filename(obj,val)
            if ~istext(val)
                error('HORACE:MultipixBase:invalid_argument', ...
                    'fill_filename should be a string, describing full name of the file on disk. It is %s', ...
                    disp2str(val));
            end
            obj.full_filename_ = val;
        end
        %
        function is = get.is_filebacked(obj)
            is = get_is_filebacked(obj);
        end
        function is = get.is_misaligned(~)
            is = false;
        end
        %
        function is = get.relabel_with_fnum(obj)
            % true if pixel id from each contributing file
            % should be replaced by contributing file number
            if istext(obj.run_label)
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
            is = get_change_fileno_(obj);
        end
        %
        function fn = get.filenum(obj)
            if isempty(obj.filenum_)
                fn = 1:obj.nfiles;
            else
                fn = obj.filenum_;
            end
        end
        function obj = set.filenum(obj,val)
            if ~isnumeric(val)
                error('HORACE:MultipixBase:invalid_argument', ...
                    'filenum property should be numeric array with number of elements equal to number of files')
            end
            obj.filenum_ = val(:)';
        end
        function rl= get.run_label(obj)
            rl = obj.run_label_;
        end
        function obj = set.run_label(obj,val)
            obj = set_runlabel_(obj,val);
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
    methods(Abstract)
        obj = recalc_data_range(obj)
        % initialize access to contributing pixel data.
        obj = init_pix_access(obj)
        % close (finalize) access to contributing pixel data.
        obj = close_faccessors(obj)
    end
    %----------------------------------------------------------------------
    methods(Abstract,Access=protected)
        obj = set_infiles(obj,val);
        obj = set_npix_each_file(obj,val);
        is = get_is_filebacked(obj);
    end
    % SERIALIZABLE INTERFACE
    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(~)
            flds = {'infiles','nbins','npix_each_file','run_label'};
        end
        %
    end
end
