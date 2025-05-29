classdef cut_data_from_file_job < JobExecutor
    % Class performs parallel cut of pixel data from file and writes these
    % cuts as binary tmp files.
    %
    % If run in serial, provides methods to cut these data in serial
    % fashion.
    %
    %
    %
    properties
        s_accum;
        e_accum;
        npix_accum;
    end
    properties(Access=protected)
        is_finished_ = false;
    end

    methods
        function obj = cut_data_from_file_job()
            obj = obj@JobExecutor();
        end

        function obj=do_job(obj)
            % Run main accumulation for a worker.
            %

            % unpack input data transferred though MPI channels for
            % runfiles_to_sqw to understand.
            %common_par = this.common_data_;
            sqw_loaders = obj.loop_data_;
            for i=1:numel(sqw_loaders)
                sqw_loaders{i} = sqw_loaders{i}.activate();
            end

            % Do accumulation
            [obj.s_accum,obj.e_accum,obj.npix_accum] = obj.accumulate_headers(sqw_loaders);

        end
        function  obj=reduce_data(obj)
            % method to summarize all particular data from all workers.
            mf = obj.mess_framework;
            if isempty(mf) % something wrong, framework deleted
                error('ACCUMULATE_HEADERS_JOB:runtime_error',...
                    'MPI framework is not initialized');
            end

            if mf.labIndex == 1
                all_messages = mf.receive_all('all','data');
                for i=1:numel(all_messages)
                    obj.s_accum = obj.s_accum + all_messages{i}.payload.s;
                    obj.e_accum = obj.e_accum + all_messages{i}.payload.e;
                    obj.npix_accum = obj.npix_accum+ all_messages{i}.payload.npix;
                end
                % return results
                obj.task_outputs = struct('s',obj.s_accum,...
                    'e',obj.e_accum,'npix',obj.npix_accum);
            else
                %
                the_mess = aMessage('data');
                the_mess.payload = struct('s',obj.s_accum,...
                    'e',obj.e_accum,'npix',obj.npix_accum);

                [ok,err]=mf.send_message(1,the_mess);
                if ok ~= MESS_CODES.ok
                    error('ACCUMULATE_HEADERS_JOB:runtime_error',err);
                end
                obj.task_outputs = [];
            end
            obj.is_finished_ = true;
        end
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end
    end
    methods(Static)
        function [npix,npix1] = calc_npix_distribution(pix_indx,npix)
            % Calculate how many pixel indices belongs to each image bin
            %
            %
            % Inputs:
            % pix_idx  -- array containing bin numbers (pixel bin indices)
            % npix     -- array containing initial numbers of indices in
            %             bins (may be zeros) and defining size and shape
            %             of the lattice to sort indices on.
            %
            % Returns:
            % npix     -- array of bins with numbers modified by adding to
            %             each bin number of indices belonging to this bin
            % npix1    -- the array of bins accumulated at this iteration
            %             (i.e. when all(npix == 0)== true).
            %
            n_bins = size(npix);
            if size(pix_indx,2)==1 && numel(n_bins) == 2 && n_bins(1) == 1
                npix1 = accumarray(pix_indx, ones(1,size(pix_indx,1)), fliplr(n_bins));
            else
                npix1 = accumarray(pix_indx, ones(1,size(pix_indx,1)), n_bins);
            end
            % do we need to do this or it is always a column array in 1D?
            npix = npix+ reshape(npix1,n_bins);
        end

        function pix_comb_info = accumulate_pix(varargin)
            % Accumulate pixel data into memory and if memory full, to
            % temporary files and return a pixfile_combine_info
            % object that manages the files.
            %
            % The pixfile_combine_info object, when saved, will re-combine the temporary
            % files into a single sqw object.
            %
            % Inputs:
            % -------
            % pix_comb_info    A pixfile_combine_info object
            % finish_accum     Boolean flag, set to true to finish accumulation
            % v                PixelData object containing pixel chunk
            % ix_add           The indices of retained pixels in the order they
            %                  appear in output file (used for sorting)
            % npix             The npix array associated with this chunk of pixels
            % max_buf_size     The maximum buffer size for reading/writing
            % npix_retained     Number of pixels retained in this chunk of the cut
            % Optional:
            % log_level        verbosity of the accumulate algorithm as
            %                  defined in hor_config.log_level. If absent,
            %                  hor_config.log_level will be used to
            %                  define the verbosity.
            %
            pix_comb_info = accumulate_pix_(varargin{:});
        end

        function [common_par,loop_par] = pack_job_pars(sqw_loaders)
            % Pack the the job parameters into the form, suitable
            % for division between workers and MPI transfer.
            common_par = [];
            loop_par = cell(size(sqw_loaders));
        end
    end
end


