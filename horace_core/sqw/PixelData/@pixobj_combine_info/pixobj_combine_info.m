classdef pixobj_combine_info < MultipixBase
    % Helper class used to carry out and provide information
    % necessary for pixel combining using join algorithm
    % or similar algorithm, deployed when running cut_sqw in memory->memory
    % or memory->file or filebacked_pixels->file modes
    %
    properties(Dependent)
        % list of distributions of the pixels within the bins
        npix_list
    end
    %
    %
    properties(Access = protected)
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
            %
            % pix_distr
            %         -- single distribution or cellarray of distributions
            %            of pixels within the image bins (distribution is
            %            npix(:) value of npix property of DnD image)
            %            if single value provided, this value is applied
            %            to all pixels datasets.
            % OPTIONAL:
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
            %         -  'filenum' the string stating that the pixels id-s
            %             should be modified and be equal
            %               to the numbers of contributing files
            %      or:
            %         -   array of unique numbers, providing run_id for each
            %             contributing run(file)
            if nargin == 0
                return
            end
            obj = obj.init(varargin{:});
        end
        function obj = init(obj,varargin)
            % Initialize pixobj_combine_info class.
            % Inputs:
            % infiles -- cellarray of full names of the files or objects to combine
            % npix_list
            %         -- single npix array or cellarry of npix arrays,
            %            describing distribution of pixels within bins.
            % Optional:
            %run_label
            %     either:
            %          - the string or array containing information on the
            %            treatment of the run_ids, identifying each
            %            pixel of the PixelData. It may be equal
            %      to:
            %          - 'nochange' the string stating that the pixel id-s
            %             should be kept as provided within contributing
            %             files
            %      or:
            %         -  'filenum' the string stating that the pixels id-s
            %             should be modified and be equal
            %               to the numbers of contributing files
            %      or:
            %         -   array of unique numbers, providing run_id for each
            %             contributing run(file)
            flds = {'infiles','npix_list','run_label'};
            [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                flds, false, varargin{:});
            if ~isempty(remains)
                error('HORACE:pixobj_combine_info:invalid_argument',[ ...
                    'pixobj_combine_info accepts up to 3 input arguments.\n' ...
                    'got: %d arguments. Last have not been recognized: %s\n'], ...
                    numel(varargin),disp2str(remains))
            end
        end
        %------------------------------------------------------------------
        function obj = init_pix_access(obj)
            % initialize access to contributing pixels.

            % as we normally read data and immediately dump them back, what
            % is the point of converting them to double and back to single?
            % Keep precision.
            for i=1:numel(obj.infiles_)
                obj.infiles_{i}.keep_precision = true;
            end
            obj.keep_precision_ = true;
        end

        function [data,npix_chunk] = get_dataset_page(obj, ...
                n_dataset,pix_pos_start,npix_idx)
            % Return pixel data and pixel bin sub-distribution for the
            % particular dataset out of multiple pixel datasets, stored
            % within the class.
            % Inputs:
            % n_dataset -- number of dataset to get data from
            % pix_pos_start
            %           -- the position where pixel data are located.
            %              Should be externaly synchronized with npix.
            %              Can be calculated here, but ignored for saving
            %              time and memory.
            % npix_idx  -- two-element array containing first and last
            %              indices of bins containing
            %              distribution of pixels over bins.
            % Returns:
            % data       -- page of data retrieved from pixels dataset
            % npix_chunk -- part of npix array, responsible for pixels stored
            %               in data page. sum(npix_chun) == size(data,2);
            %
            npix          = obj.npix_list_{n_dataset};
            npix_chunk    = npix(npix_idx(1):npix_idx(2));
            npix_in_block = sum(npix_chunk);
            pix_pos_end   = pix_pos_start+npix_in_block-1;
            pix           = obj.infiles_{n_dataset};
            data          = pix.get_pixels( ...
                pix_pos_start:pix_pos_end,'-raw','-align');
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
        function obj = close_faccessors(obj)
            % close access to partial input files
            for i=1:numel(obj.infiles_)
                obj.infiles_{i} = obj.infiles_{i}.deactivate();
            end
        end
    end
    methods(Access=protected)
        function is = get_is_filebacked(obj)
            is = any(cellfun(@(x)x.is_filebacked,obj.infiles_));
        end

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
            flds = {'infiles','npix_list','run_label'};
        end
        function obj = check_combo_arg(obj)
            % validate consistency of cellarray of pixels data and
            % cellarray of distributions, describing these pixels
            %
            obj = check_combo_arg_(obj);
        end

    end
end
