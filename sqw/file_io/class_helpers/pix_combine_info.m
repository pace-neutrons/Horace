classdef pix_combine_info
    % Helper class used to carry out and provide information
    % necessary for pixel combining using write_nsqw_to_sqw algorithm.
    %
    %
    % $Revision$ ($Date$)
    %
    properties(Access = protected)
        n_pixels_ = 'undefined';
        filenum_ = [];
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
        % number of bins in the contributing sqw(tmp) files. Should be the
        % same for all  files to be combined together.
        nbins;
        % array of numbers of pixels stored in each contributing file
        npix_file_tot;
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
        
        % auxiliary propery used by cut_sqw
        npix_cumsum;
    end
    
    properties(Dependent)
        % total number of pixels to combine
        npixels;
        % number of files, contributing into final result
        nfiles;
        % true if pixel id from each contributing file should be replaced by contributing file number
        relabel_with_fnum;
        % true if pixel id for each pixel from contributing files should be changed.
        change_fileno
        % numbers of files used as runlabel for pixels if relabel_with_fnum
        % and change_fileno are set to true
        filenum
    end
    
    
    methods
        %
        function obj = pix_combine_info(infiles,nbins,pos_npixstart,pos_pixstart,npixtot,run_label,filenums)
            obj.infiles = infiles;
            if ~exist('pos_npixstart','var') % pre-initialization for file-based combining of the cuts.
                nfiles = obj.nfiles;
                obj.pos_npixstart = zeros(1,nfiles);
                obj.pos_pixstart  = zeros(1,nfiles);
                obj.npix_file_tot       = zeros(1,nfiles);
                obj.nbins   = 0;
                obj.run_label     = 'nochange';
                return;
            end
            obj.pos_npixstart= pos_npixstart;
            obj.pos_pixstart = pos_pixstart;
            obj.run_label    = run_label;
            obj.nbins        = nbins;
            obj.npix_file_tot    = npixtot;
            obj.n_pixels_ = uint64(sum(npixtot));
            
            if exist('filenums','var')
                obj.filenum_ = filenums;
            end
        end
        %
        function npix = get.npixels(obj)
            % total number of pixels in all contributing files
            npix = obj.n_pixels_;
        end
        %
        function nf   = get.nfiles(obj)
            % number of contributing files
            nf = numel(obj.infiles);
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
                if ~(isnumeric(obj.run_label) && numel(obj.run_label)==obj.nfiles)
                    error('SQW_FILE_IO:invalid_argument',...
                        'relabel_with_fnum: Invalid value for run_label')
                end
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
        function fn = get.filenum(obj)
            if isempty(obj.filenum_)
                fn = 1:obj.nfiles;
            else
                fn = obj.filenum_;
            end
        end
        function parts_carr= split_into_parts(obj,n_workers)
            % function divided pix_combine_info into the specified number
            % of parts to send it for processing on parallel system
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
                prun_label     = obj.run_label(split_ind(1,i):split_ind(2,i));
                pnpixtot       = obj.npix_file_tot(split_ind(1,i):split_ind(2,i));
                pfilenums    = filenums(split_ind(1,i):split_ind(2,i));
                %
                parts_carr{i} = pix_combine_info(part_files,pnbins,ppos_npixstart,ppos_pixstart,pnpixtot,prun_label,pfilenums);
            end
            
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
            obj.npix_file_tot= obj.npix_file_tot(1:nfiles_to_leave);
            
            obj.n_pixels_ = uint64(sum(obj.npix_file_tot));
            if ~isempty(obj.filenum_)
                obj.filenum_ = obj.filenum_(1:nfiles_to_leave);
            end
            
        end
    end
    
end

