classdef pixobj_combine_info < MultipixBase
    % Helper class used to carry out and provide information
    % necessary for pixel combining using join algorithm
    % or similar algorithm, deployed when running cut_sqw in memory->memory
    % or memory->file or filebacked_pixels->file modes
    %
    properties(Dependent)
        pixobj_list
    end
    %
    %
    properties(Access = protected)
        pixobj_list_ = {}
    end
    methods
        %
        function obj = pixobj_combine_info(varargin)
            % Build instance of the class, which provides the information
            % for combining pixels obtained from separate sqw(tmp) files.
            %
            % Inputs:
            % inobj   -- cellarray of PixelData objects containing pixels
            % Optional:
            % nbins   -- number of bins (number of elements in npix array)
            %            in the tmp files and target sqw file (should be
            %            the same for all components so one number)
            %            number of contributing files.
            % npix_each_file
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
            [obj,remains] = init@MultipixBase(obj,varargin{:});
            flds = {'run_label','filenum'};
            [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                flds, false, remains{:});
            if ~isempty(remains)
                if numel(remains)==1
                    obj.filenum_ = remains{1};
                else
                    error('HORACE:pixobj_combine_info:invalid_argument',[ ...
                        'pixobj_combine_info accepts up to 5 input arguments.\n' ...
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
        %
    end
    methods(Access=protected)
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
        function  flds = saveableFields(obj)
            fld1 = saveableFields@MultipixBase(obj);
            flds = {'filenum'};
            flds = [fld1(:);flds(:)];
        end

    end
end
