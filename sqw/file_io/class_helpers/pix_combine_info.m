classdef pix_combine_info
    % Helper class used to carry out and proivde combibe pixels info
    % for write_nsqw_to_sqw algorithm
    %
    properties(Access = protected)
        n_pixels_ = 'undefined';
    end
    
    properties(Access=public)
        % cellarray of filenames to combine
        infiles;
        % array of starting positions of the npix information in each
        % contributing file
        pos_npixstart;
        % array of starting positions of the pix information in each
        % contributing file
        pos_pixstart;
        % cumulative sum of numbers of all pixels, contributing into sqw
        % file as function of bin number. Defines positions of each cell's
        % pixels block in 1D array of pixels
        npix_cumsum;
        % array of numbers of pixels stored in each contributing file
        npixtot;
        %   run_label       Indicates how to re-label the run index (pix(5,...)
        %                       'fileno'        relabel run index as the index of the file in the list infiles
        %                       'nochange'      use the run index as in the input file
        %                        numeric array  offset run numbers for ith file by ith element of the array
        %                   This option exists to deal with three limiting cases:
        %                    (1) The run index is already written to the files correctly indexed into the header
        %                       e.g. as when temporary files have been written during cut_sqw
        %                    (2) There is one file per run, and the run index in the header block is the file
        %                       index e.g. as in the creating of the master sqw file
        %                    (3) The files correspond to several runs in general, which need to
        %                       be offset to give the run indices into the collective list of run parameters
        run_label;
    end
    
    properties(Dependent)
        % total number of pixels to combine
        npixels;
        % numbef of files, contributing into final result
        nfiles;
        % how to interpred labels fild
        relabel_with_fnum;
        %
        change_fileno
    end
    
    
    methods
        function obj = pix_combine_info(infiles,pos_npixstart,pos_pixstart,npix_cumsum,npixtot,run_label)
            obj.infiles = infiles;
            obj.pos_npixstart= pos_npixstart;
            obj.pos_pixstart = pos_pixstart;
            obj.run_label    = run_label;
            obj.npix_cumsum  = npix_cumsum;
            obj.npixtot     = npixtot;
            obj.n_pixels_ = uint64(sum(npixtot));
            if obj.npixels ~= npix_cumsum(end)
                error('SQW_FILE_IO:runtime_error',...
                    'Wrong input for combine mutliple files: Numbef of pixels in all files %d is not equal to number of pixels in their combination %d',...
                    obj.npixtot,npix_cumsum(end));
            end
        end
        %
        function npix = get.npixels(obj)
            npix = obj.n_pixels_;
        end
        function nf   = get.nfiles(obj)
            nf = numel(obj.infiles);
        end
        %
        function is = get.relabel_with_fnum(obj)
            if ischar(obj.run_label)
                if strcmpi(obj.run_label,'fileno')
                    is  = true;
                else
                    is = false;
                end
            else
                is = false;
                if ~(isnumeric(obj.run_label) && numel(obj.run_label)==obj.nfiles)
                    error('SQW_FILE_IO:invalid_argument',...
                        'relabel_with_fnum: Invalid value for run_label')
                end
            end
        end
        %
        function is = get.change_fileno(obj)
            if ischar(obj.run_label)
                if strcmpi(obj.run_label,'nochange')
                    is=false;
                elseif strcmpi(obj.run_label,'fileno')
                    is = true;
                else
                    error('SQW_FILE_IO:invalid_argument',...
                        'change_fileno: Invalid string value for run_label. Can be only "nochange" or "fileno"')
                end
            elseif (isnumeric(obj.run_label) && numel(obj.run_label)==obj.nfiles)
                is=true;
            else
                error('SQW_FILE_IO:invalid_argument','Invalid value for run_label')
            end
            
        end
    end
    
end

