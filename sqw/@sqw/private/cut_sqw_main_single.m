function wout = cut_sqw_main_single (data_source,...
    main_header, header, detpar, data, npixtot, pix_position,...
    proj, pbin, pin, en, opt, hor_log_level)
% Take a cut from an sqw object by integrating over one or more axes.


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


% Initialise output
return_cut = (nargout==1);

% Start timer
if hor_log_level>=1
    bigtic
end

% Get bin boundaries for plot axes and integration ranges
[iax, iint, pax, p, urange] = proj.calc_ubins (data.urange, pbin, pin, en);

% Set matrix and translation vector to express plot axes with two or more bins
% as multiples of step size from lower limits
proj = proj.set_proj_binning(urange,pax,iax,p);

% Get indexes of pixels contributing into projection
[nstart,nend] = proj.get_nbin_range(data.npix);

% *** T.G.Perring 5 Sep 2018:*********************
% Eliminate the following check as the algorithms now made valid for no retained pixels
% if isempty(nstart) || isempty(nend)
%     error('CUT_SQW:invalid_arguments','no pixels found within the range of the cut');
% end
% ************************************************

if ~return_cut  % can buffer only if no output cut object
    pix_tmpfile_ok = true;
else
    pix_tmpfile_ok = false;
end


% Get accumulated signal
% -----------------------
% Read data and accumulate signal and error
targ_pax = proj.target_pax;
targ_nbin = proj.target_nbin;
keep_workers_running = false;

if ischar(data_source)
    % Pixel information to be read from a file
    if opt.parallel
        % Parallel cut algorithm
%         error('CUT_SQW:not_implemented',...
%             ' Parallel cut is not yet implemented. Do not use it');
        [~,fn] = fileparts(outfile);
        if numel(fn) > 8
            fn = fn(1:8);
        end
        job_name = ['cut_sqw_to_',fn];
        job_disp = JobDispatcher(job_name);
        
        [comb_using,n_workers] = config_store.instance().get_value...
            ('hpc_config','combine_sqw_using','parallel_workers_number');
        if strcmp(comb_using,'mpi_code') && opt.keep_pix % keep cluster running for combining procedure
            keep_workers_running = true;
        else
            keep_workers_running = false;
        end
        
        [common_par,loop_par] = cut_data_from_file_job.pack_job_pars...
            (data_source, opt.keep_pix, pix_tmpfile_ok, proj, nstart, nend);
        
        [outputs,n_failed,~,job_disp]=job_disp.start_job...
            ('accumulate_headers_job', common_par, loop_par, true, n_workers, keep_workers_running);
        
        if n_failed == 0
            s    = outputs{1}.s;
            e    = outputs{1}.e;
            npix = outputs{1}.npix;
            urange_step_pix = outputs{1}.urange_step_pix;
            pix = outputs{1}.pix;
            npix_retain = outputs{1}.npix_retain;
        else
            job_disp.display_fail_job_results(outputs,n_failed,n_workers,'CUT_SQW:runtime_error');
        end
        
    else
        % Original cut algorithm
        fid=fopen(data_source,'r');
        if fid<0
            error('CUT_SQW:runtime_error',...
                'Unable to open source file: %s',data_source)
        end
        clobInput = onCleanup(@()fclose(fid));
        
        status=fseek(fid,pix_position,'bof');    % Move directly to location of start of pixel data block
        if status<0;  fclose(fid);
            error('CUT_SQW:runtime_error',...
                ['Error finding location of pixel data in file ',data_source]);
        end
        [s, e, npix, urange_step_pix, pix, npix_retain, npix_read] = ...
            cut_data_from_file_job.cut_data_from_file (fid, nstart, nend,...
            opt.keep_pix, pix_tmpfile_ok, proj, targ_pax, targ_nbin);
        clear clobInput;
    end
    
else
    % Pixel information taken from object
    [s, e, npix, urange_step_pix, pix, npix_retain, npix_read] = cut_data_from_array...
        (data.pix, nstart, nend, opt.keep_pix, proj, targ_pax, targ_nbin);
end

% For convenience later on, set a flag that indicates if pixel info buffered in files
if isa(pix,'pix_combine_info')
    pix_tmpfile_ok=true;
    tmpFilesClob = onCleanup(@()delete_tmp_pix_files(pix));
else
    pix_tmpfile_ok=false;
    tmpFilesClob = [];
end

% Convert range from steps to actual range with respect to output uoffset:
urange_pix = urange_step_pix.*repmat(proj.usteps,[2,1]) + repmat(proj.urange_offset,[2,1]);

% Get size of output signal, error and npix arrays
% (Account for singleton dimensions i.e. plot axes with just one bin, and look after case
% of zero or one dimension)
ppax = p(1:length(pax));
if isempty(ppax)
    nbin_as_size = [1,1];
elseif length(ppax)==1
    nbin_as_size = [length(ppax{1})-1,1];
else
    nbin_as_size = cellfun(@(nd)(length(nd)-1),ppax);
end

% Prepare ouput data
data_out = data;

s = reshape(s,nbin_as_size);
e = reshape(e,nbin_as_size);
npix = reshape(npix,nbin_as_size);


% Parcel up data as the output sqw data structure
% -------------------------------------------------
% Store output parameters relevant for future cuts and correct displaying
% of sqw object

[data_out.uoffset,data_out.ulabel,data_out.dax,data_out.u_to_rlu,...
    data_out.ulen,axis_caption] = proj.get_proj_param(data,pax);
%HACK! Any projections is converted into standard projection at this point
data_out.axis_caption = axis_caption;

data_out.iax = iax;
data_out.iint = iint;
data_out.pax = pax;
data_out.p = p;

data_out.s = s./npix;
data_out.e = e./(npix.^2);
data_out.npix = npix;
no_pix = (npix==0);     % true where there are no pixels contributing to the bin
data_out.s(no_pix)=0;   % want signal to be zero where there are no contributing pixels, not +/- Inf
data_out.e(no_pix)=0;

if opt.keep_pix
    data_out.urange = urange_pix;
    data_out.pix = pix;
end

% Collect fields to make those for a valid sqw object
if opt.keep_pix
    w.main_header=main_header;
    w.header=header;
    w.detpar=detpar;
    w.data=data_out; % will be missing the field 'pix' if pix_tmpfile_ok=true
else
    [w,mess]=make_sqw(true,data_out);   % make dnd-type sqw structure
    if ~isempty(mess), error(mess), end
end


% Save to file if requested
% ---------------------------
if ~isempty(opt.outfile)
    if hor_log_level>=0, disp(['Writing cut to output file ',opt.outfile,'...']), end
    try
        ls = sqw_formats_factory.instance().get_pref_access();
        ls = ls.init(w,opt.outfile);
        if keep_workers_running && opt.parallel % save time on starting parallel pool and use the existing one
            ls = ls.put_sqw(job_disp);
        else
            ls = ls.put_sqw();
        end
        ls.delete();
        
        if pix_tmpfile_ok
            clear tmpFilesClob;
        end
    catch Err  % catch just in case there is an error writing that is not caught - don't want to waste all the cutting output
        warning('CUT_SQW_MAIN:io_error','Error writing to file:ID %s, Message  %s',Err.identifier,Err.message);
    end
    if hor_log_level>=0, disp(' '), end
end

if exist('tmpFilesClob','var') && ~isempty(tmpFilesClob) %to satisfy Matlab code analyzer who complain about 
    clear tmpFilesClob    % tmpFilesClob missing
end

% Create output argument if requested
% -----------------------------------
if return_cut
    wout=sqw(w);
    if ~opt.keep_pix
        wout=dnd(sqw(w));
    end
end

% Output cut information to screen
% --------------------------------
if hor_log_level>=1
    if ischar(data_source)
        disp(['Number of points in input file: ',num2str(npixtot)])
        disp(['         Fraction of file read: ',num2str(100*npix_read/double(npixtot),'%8.4f'),' %   (=',num2str(npix_read),' points)'])
        disp(['     Fraction of file retained: ',num2str(100*npix_retain/double(npixtot),'%8.4f'),' %   (=',num2str(npix_retain),' points)'])
    else
        disp(['    Number of points in object: ',num2str(npixtot)])
        disp(['  Fraction of object processed: ',num2str(100*npix_read/double(npixtot),'%8.4f'),' %   (=',num2str(npix_read),' points)'])
        disp(['   Fraction of object retained: ',num2str(100*npix_retain/double(npixtot),'%8.4f'),' %   (=',num2str(npix_retain),' points)'])
    end
    disp(' ')
    bigtoc('Total time in cut_sqw:',hor_log_level)
    disp('--------------------------------------------------------------------------------')
end

%==================================================================================================
function delete_tmp_pix_files(pix_info)
% delete temporary pix info files, created by file-based cut;
for ifile=1:pix_info.nfiles   % delete the temporary files
    delete(pix_info.infiles{ifile});
end
