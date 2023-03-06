classdef cut_data_from_file_job < JobExecutor
    % Class performs parallel cut of pixel data from file and writes these
    % cuts as binary tmp files.
    %
    % If run in serial, provides methods to cut these data in serial
    % fashion.
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
        function [s, e, npix, pix_range_step, pix, npix_retain, npix_read] = ...
                cut_data_from_file(fid, nstart, nend, keep_pix, pix_tmpfile_ok,...
                proj,pax, nbin)
            % Accumulates pixels retrieved from sqw file into bins defined by cut parameters
            %
            %   >> [s, e, npix, npix_retain] = cut_data_from_file(fid, nstart, nend, pix_range_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin, keep_pix)
            %
            % Input:
            % ------
            %   fid             File identifier, with current position in the file being the start of the array of pixel information
            %   nstart          Column vector of read start locations in file
            %   nend            Column vector of read end locations in file
            %   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
            %   pix_tmpfile_ok  if keep_pix=false, ignore
            %                   if keep_pix=true, set buffering option:
            %                       pix_tmpfile_ok = false: pix is a PixelData object
            %                       pix_tmpfile_ok = true:  Buffering of pixel info to temporary files if pixels exceed a threshold
            %                                              In this case, output argument pix contains details of temporary files (see below)
            %   pix_range_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
            %                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
            %                  for plotaxes (with more than one bin)
            %   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
            %   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
            %                                             r_step(i) = A(i,j)(r(j) - trans(j))
            %   ebin            Energy bin width (plays role of rot_ustep for energy axis)
            %   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
            %   pax             Indices of plot axes (with two or more bins) [row vector]
            %   nbin            Number of bins along the projection axes with two or more bins [row vector]
            %
            % Output:
            % -------
            %   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
            %   e               Array of accumulated variance
            %   npix            Array of number of contributing pixels (if keep_pix==true, otherwise pix=[])
            %   pix_range_step Actual range of contributing pixels
            %   pix             if keep_pix=false, pix is an empty PixelData object;
            %                   if keep_pix==true, then contents depend on value of pix_tmpfile_ok:
            %                       pix_tmpfile_ok = false: contains PixelData object
            %                       pix_tmpfile_ok = true: structure with fields
            %                           pix.tmpfiles        cell array of filename(s) containing npix and pix
            %                           pix.pos_npixstart   array with position(s) from start of file(s) of array npix
            %                           pix.pos_pixstart    array with position(s) from start of file(s) of array npix
            %   npix_retain     Number of pixels that contribute to the cut
            %   npix_read       Number of pixels read from file
            %
            %
            % Note:
            % - Redundant input variables in that pix_range_step(2,pax)=nbin in implementation of 19 July 2007
            % - Aim to take advantage of in-place working within accumulate_cut

            % T.G.Perring   19 July 2007 (based on earlier prototype TGP code)
            %
            [s, e, npix, pix_range_step, pix, npix_retain, npix_read] = ...
                cut_data_from_file_(fid, nstart, nend, keep_pix, pix_tmpfile_ok,...
                proj,pax, nbin);

        end
        function [npix,varargout] = bin_pixels(proj, ...
                axes,pix_cand,varargin)
            % Convert pixels into the coordinate system, defined by the
            % projection and bin them into the coordinate system, defined
            % by the axes block, specified as input.
            %
            % Inputs:
            % axes -- the instance of AxesBlockBase class, defining the
            %         shape and the binning of the target coordinate system
            % pix_candidates -- the 4xNpix array of pixel coordinates or
            %         PixelData object or pixel data accessor from file
            %         providing access to the full pixel information, or
            %         pixel data in any format the particular projection,
            %         which does transformation from pix_to_img coordinate
            %         system accepts
            % Optional:
            % ---------
            % npix    -- the array, containing the numbers of pixels
            %            contributing into each axes grid cell, calculated
            %            during the previous iteration step. zeros(size(npix))
            %            if this is the first step.
            % s       -- array, containing the accumulated signal for each
            %            axes grid cell calculated during the previous
            %            iteration step. zeros(size(npix)) if this is the
            %            first step.
            % e       -- array, containing the accumulated error for each
            %            axes grid cell calculated during the previous
            %            iteration step. zeros(size(npix)) if this is the
            %            first step.
            % Optional arguments transferred without any change to
            % AxesBlockBase.bin_pixels()
            %
            % '-nomex'    -- do not use mex code even if its available
            %               (usually for testing)
            %
            % '-force_mex' -- use only mex code and fail if mex is not available
            %                (usually for testing)
            % '-force_double'
            %              -- if provided, the routine changes type of pixels
            %                 it gets on input, into double. if not, output
            %                 pixels will keep their initial type
            % -nomex and -force_mex options can not be used together.
            %
            % Outputs:
            % npix    -- the npix array
            %  The same npix, s, e arrays as inputs modified with added
            %  information from pix_candidates if npix, s, e arrays were
            %  present or axes class - shaped arrays of this information
            %  if there were no inputs.
            % Optional:
            % pix_ok -- the pixel coordinate array or
            %           PixelData object (as input pix_candidates) containing
            %           pixels contributing to the grid and sorted according
            %           to the axes block grid.
            % unique_runid -- the runid (tags) for the runs, which
            %           contributed into the cut
            % pix_indx--indexes of the pix_ok coordinates according to the
            %           bin. If this index is requested, the pix_ok object
            %           remains unsorted according to the bins and the
            %           follow up sorting of data by the bins is expected
            %
            [npix,s,e,argi] = normalize_bin_pixels_inputs_(axes,varargin{:});

            switch(nargout)
                case(1)
                    npix=proj.bin_pixels(axes,pix_cand,...
                        axes,pix_cand,npix,s,e,argi{:});
                case(3)
                    [npix,varargout{1},varargout{2}]= ...
                        proj.bin_pixels(axes,pix_cand, ...
                        npix,s,e,argi{:});
                case(4)
                    [npix,varargout{1},varargout{2},varargout{3}]=...
                        proj.bin_pixels(axes,pix_cand, ...
                        npix,s,e,argi{:});
                case(5)
                    [npix,varargout{1},varargout{2},varargout{3},varargout{4}]=...
                        proj.bin_pixels(axes,pix_cand, ...
                        npix,s,e,argi{:});
                case(6)
                    [npix,varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}] =...
                        proj.bin_pixels(axes,pix_cand, ...
                        npix,s,e,argi{:});
                otherwise
                    error('HORACE:cut_data_from_file_job:invalid_argument',...
                        'This function requests 1,3,4,5 or 6 output arguments');
            end

        end

        function pix_comb_info = accumulate_pix_to_file(varargin)
            % Accumulate pixel data into temporary files and return a pix_combine_info
            % object that manages the files
            %
            % The pix_combine_info object, when saved, will re-combine the temporary
            % files into a single sqw object.
            %
            % Inputs:
            % -------
            % pix_comb_info    A pix_combine_info object
            % finish_accum     Boolean flag, set to true to finish accumulation
            % v                PixelData object containing pixel chunk
            % ix_add           The indices of retained pixels in the order they
            %                  appear in output file (used for sorting)
            % npix             The npix array associated with this chunk of pixels
            % max_buf_size     The maximum buffer size for reading/writing
            % npix_retained     Number of pixels retained in this chunk of the cut
            %
            pix_comb_info = accumulate_pix_to_file_(varargin{:});
        end

        function [common_par,loop_par] = pack_job_pars(sqw_loaders)
            % Pack the the job parameters into the form, suitable
            % for division between workers and MPI transfer.
            common_par = [];
            loop_par = cell(size(sqw_loaders));
        end
    end
end


