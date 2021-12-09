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
        function [s, e, npix, pix_range_step, npix_retain, ok, ix] = ...
                accumulate_cut(s, e, npix, pix_range_step, keep_pix, ...
                v, proj, pax,keep_precision)
            % Accumulate signal and pixel if requested into the output arrays
            %
            %>> [s,e,npix,npix_retain] = accumulate_cut s, e, npix, pix_range_step, keep_pix, 
            %                            v, proj, pax,[keep_precision])
            %
            % Input: (* denotes output argument with same name exists - exploits in-place working of Matlab R2007a)
            % ------
            % * s               Array of accumulated signal from all 
            %                   contributing pixels (dimensions match the plot axes)
            % * e               Array of accumulated variance
            % * npix            Array of number of contributing pixels
            % * pix_range_step  Actual range of contributing pixels
            %   keep_pix        Set to true if wish to retain the information
            %                   about individual pixels; set to false if not
            %   v               A PixelData object, containing input pixels
            %                   information
            %   proj            the projection class, used to transform pixels info in
            %                   crystal Cartesian coordinate system
            %                   (as v is into the coordinate system
            %                   of the cut
            %   pax             Indices of plot axes (with two or more bins) 
            %                   [row vector]
            %
            % Optional:
            % ---------
            %   keep_precision  if provided and true, prevents from sinlge
            %                   precision pixels provided as input
            %                   being converted to double precision. 
            %                   Extreamly useful in
            %                   filebased cuts, as the data, read from disk
            %                   as single precision are not converted to
            %                   double, processed as double and written
            %                   back as single again.
            %                   By default, false
            %
            % Output:
            % -------
            %   s               Array of accumulated signal from all 
            %                   contributing pixels (dimensions match the plot axes)
            %   e               Array of accumulated variance
            %   npix            Array of number of contributing pixels
            %   pix_range_step  Actual range of contributing pixels
            %   npix_retain     Number of pixels that contribute to the cut
            %   ok              If keep_pix==true: v(:,ok) are the pixels
            %                   that are retained; otherwise =[]
            %   ix              If keep_pix==true: column vector of single 
            %                   bin index of each retained pixel; otherwise =[]
            %
            %
            if ~exist('keep_precision','var')
                keep_precision = false;
            end
            [s, e, npix, pix_range_step, npix_retain, ok, ix] = ...
                accumulate_cut_ (s, e, npix, pix_range_step, keep_pix, ...
                v, proj, pax,keep_precision);
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
            % ok               Indices of pixels in v that contribute to cut
            % ix_add           The indices of retained pixels in the order they
            %                  appear in output file (used for sorting)
            % npix             The npix array associated with this chunk of pixels
            % max_buf_size     The maximum buffer size for reading/writing
            % del_npix_retain  Number of pixels retained in this chunk of the cut
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


