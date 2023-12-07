classdef pixobj_combine_info < MultipixBase
    % Helper class used to carry out and provide information
    % necessary for pixel combining using join algorithm
    % or similar algorithm, deployed when running cut_sqw in memory->memory
    % or memory->file or filebacked_pixels->file modes
    %
    properties(Dependent)
        % list of pixel data objects to combine together
        pixobj_list
        % list of distributions of the pixels within the bins
        npix_list
    end
    %
    %
    properties(Access = protected)
        pixobj_list_ = {}
        npix_list_ = {};
    end
    methods
        %
        function obj = pixobj_combine_info(varargin)
            % Build instance of the class, which provides the information
            % for combining pixels obtained from separate sqw(tmp) files.
            %
            % Inputs:
            % inobj   -- cellarray of PixelData objects containing pixels
            % pix_distr
            %         -- cellarray of distribution of pixels within the
            %            image bins (distribution is npix(:) value of npix
            %            property of DnD image)
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
            % filenum  -- array, defining the numbers for each
            %              contributing file. If not present, the contributing
            %              files are numbered by integers running from 1 to
            %              n-files
            if nargin == 0
                return
            end
            obj = obj.init(varargin{:});
        end
        function obj = init(obj,varargin)
            flds = {'infiles','npix_list','run_label','filenum'};
            [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                flds, false, varargin{:});
            if ~isempty(remains)
                if numel(remains)==1
                    obj.filenum_ = remains{1};
                else
                    error('HORACE:pixobj_combine_info:invalid_argument',[ ...
                        'pixobj_combine_info accepts up to 4 input arguments.\n' ...
                        'got: %d arguments. Last have not been recognized: %s\n'], ...
                        numel(varargin),disp2str(remains))
                end
            end
        end
        %------------------------------------------------------------------
        %
        function obj = recalc_data_range(obj)
            % recalculate common range for all pixels analysing pix ranges
            % from all contributing objects
            %
            obj = recalc_pix_range_(obj);
        end
        function npix_lst = get.npix_list(obj)
            npix_lst = obj.npix_list_;
        end
        function obj = set.npix_list(obj,val)
            % Accepts single npix array or cellarry of npix arrays,
            % describing distribution of pixels within bins.
            %
            % All heed to have the same number of elements.
            obj = set_npix_list_(obj,val);
        end
        %
    end
    methods(Access=protected)
        function obj = set_npix_each_file(varargin)
            error('HORACE:pixobj_combine_info:runtime_error', ...
                'npix_each_file is calculated from list of input files and can not be set on this object')
        end

        function obj = set_infiles(obj,val)
            obj = set_infiles_(obj,val);
        end
    end
    %----------------------------------------------------------------------
    % SERIALIZABLE INTERFACE
    methods
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(~)
            flds = {'infiles','npix_list','run_label','filenum'};
        end
        function obj = check_combo_arg(obj)
            % validate consistency of cellarray of pixels data and
            % cellarray of distributions, describing these pixels
            %
            obj = check_combo_arg_(obj);
        end

    end
end
